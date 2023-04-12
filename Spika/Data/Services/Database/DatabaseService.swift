//
//  DatabaseService.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//
import CoreData
import Combine

enum DatabaseError: Error {
    case requestFailed, noSuchRecord, unknown, moreThanOne, savingError
    
    var description : String {
        switch self {
        case .requestFailed: return "Request Failed."
        case .noSuchRecord: return "Record do not exists."
        case .unknown: return "Unknown error."
        case .moreThanOne: return "More than one record."
        case .savingError: return "Saving error."
        }
    }
}

class DatabaseService {
    let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}

// MARK: -  User

extension DatabaseService {
    func getLocalUsers() -> Future<[User], Error> {
        return Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                let fetchRequest = UserEntity.fetchRequest()
                do {
                    let userEntities = try context.fetch(fetchRequest)
                    let users = userEntities.map{ User(entity: $0) }
                    promise(.success(users.compactMap{ $0 }))
                } catch {
                    print("Error loading: ", error)
                    promise(.failure(DatabaseError.requestFailed))
                }
            }
        }
    }
    
    func saveUsers(_ users: [User]) -> Future<[User], Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                for user in users {
                    if user.displayName == nil {
                        continue // TODO: check
                    }
                    let _ = UserEntity(user: user, context: context)
                }
                do {
                    try context.save()
                    promise(.success(users))
                } catch {
                    print("Error saving: ", error)
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    func saveContacts(_ contacts: [FetchedContact]) -> Future<[FetchedContact], Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                for contact in contacts {
                    let _ = ContactEntity(phoneNumber: contact.telephone,
                                          givenName: contact.firstName,
                                          familyName: contact.lastName,
                                          context: context)
                }
                do {
                    try context.save()
                    promise(.success(contacts))
                } catch {
                    print("Error saving: ", error)
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    // TODO: - check
    func updateUsersWithContactData(_ users: [User]) -> Future<[User], Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                for var user in users {
//                    saveUsers(users)
                    let fetchRequest = ContactEntity.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "phoneNumber = %@", user.telephoneNumber ?? "") // check =
                    do {
                        let fetchResult = try context.fetch(fetchRequest)
                        if let contactEntity = fetchResult.first {
                            let contact = FetchedContact(firstName: contactEntity.givenName,
                                                         lastName: contactEntity.familyName,
                                                         telephone: contactEntity.phoneNumber)
                            user.contactsName = contact.firstName ?? ""
                            + " "
                            + (contact.lastName ?? "")
                        }
                        _ = self?.saveUsers([user])
                    } catch {
                        print("Error loading: ", error)
                        promise(.failure(DatabaseError.requestFailed))
                    }
                    
                }
                promise(.success(users))
            }
        }
    }
    
    func getLocalUser(withId id: Int64) -> Future<User, Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let fetchRequest = UserEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", "\(id)")
                do {
                    let dbUsers = try context.fetch(fetchRequest)
                    if dbUsers.count == 0 {
                        promise(.failure(DatabaseError.noSuchRecord))
                    } else if dbUsers.count > 1 {
                        promise(.failure(DatabaseError.moreThanOne))
                    } else {
                        guard let userEntity = dbUsers.first else {
                            print("GUARD getLocalUser(withId id: Int64) error: ")
                            promise(.failure(DatabaseError.unknown))
                            return
                        }
                        let user = User(entity: userEntity)
                        promise(.success(user))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}

// MARK: - Room

extension DatabaseService {
    func getPrivateRoom(forUserId id: Int64) -> Future<Room, Error> {
        Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                guard let self else { return }

                // find all roomUsers
                let roomUsersFR = RoomUserEntity.fetchRequest()
                roomUsersFR.predicate = NSPredicate(format: "userId == %d", id)
                guard let roomUsers = try? context.fetch(roomUsersFR)
                else {
                    promise(.failure(DatabaseError.noSuchRecord)) // check
                    return
                }
                
                // find all private rooms with this users, should always be only one
                let possibleRoomsIds = roomUsers.map { $0.roomId }
                let roomFR = RoomEntity.fetchRequest()
                roomFR.predicate = NSPredicate(format: "type == 'private' AND id IN %@",
                                               possibleRoomsIds)
                guard let rooms = try? context.fetch(roomFR),
                      rooms.count == 1,
                      let roomEntity = rooms.first,
                      let roomUsers = self.getRoomUsers(roomId: roomEntity.id, context: context) // get all RoomUsers for room, should be always be 2, roomUserEntity and my user
                else {
                    promise(.failure(DatabaseError.moreThanOne)) // check zero
                    return
                }
                
                let room = Room(roomEntity: roomEntity, users: roomUsers)
                promise(.success(room))
            }
        }
    }
    
    func getRoom(forRoomId id: Int64) -> Future<Room, Error> {
        Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                guard let self else { return }
                let roomsFR = RoomEntity.fetchRequest()
                roomsFR.predicate = NSPredicate(format: "id == %d", id)
                guard let roomEntities = try? context.fetch(roomsFR),
                      roomEntities.count == 1,
                      let roomEntity = roomEntities.first,
                      let roomUsers = self.getRoomUsers(roomId: roomEntity.id, context: context)
                else {
                    promise(.failure(DatabaseError.moreThanOne)) // check zero
                    return
                }
                let room = Room(roomEntity: roomEntity, users: roomUsers)
                promise(.success(room))
            }
        }
    }
    
    func saveRooms(_ rooms: [Room]) -> Future<[Room], Error> {
        Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                for room in rooms {
                    let roomEntity = RoomEntity(room: room, context: context)
                    for roomUser in room.users {
                        _ = RoomUserEntity(roomUser: roomUser, insertInto: context)
                        _ = UserEntity(user: roomUser.user, context: context)
                    }
                    // this is because mute or unmute will update room and reset it to zero
                    // TODO: - maybe add functions for update pin, mute
                    roomEntity.lastMessageTimestamp = self?.getLastMessage(roomId: room.id, context: context)?.createdAt ?? 0
                }
                do {
                    try context.save()
                    promise(.success(rooms))
                } catch {
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    func updateRoomUsers(_ room: Room) -> Future<Room, Error> {
        Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                let roomUserFR = RoomUserEntity.fetchRequest()
                roomUserFR.predicate = NSPredicate(format: "roomId == %d", room.id)

                do {
                    let roomUsers = try context.fetch(roomUserFR)
                    for roomUser in roomUsers {
                        context.delete(roomUser)
                    }
                    try context.save()
                    
                    room.users.forEach { rU in
                        _ = RoomUserEntity(roomUser: rU, insertInto: context)
                    }
                    try context.save()
                    promise(.success(room))
                } catch {
                    print("Error deleting RoomUsers: \(error)")
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
    
    func deleteRoom(roomId: Int64) -> Future<Bool, Error> {
        Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                let fr = RoomEntity.fetchRequest()
                fr.predicate = NSPredicate(format: "id == %d", roomId)
                guard let roomEntity = try? context.fetch(fr).first else { return }
                
                context.delete(roomEntity)
                do {
                    try context.save()
                    promise(.success(true))
                } catch {
                    promise(.failure((DatabaseError.savingError)))
                }
            }
        }
    }
}

// MARK: - Message

extension DatabaseService {
    func saveMessages(_ messages: [Message]) -> Future<Bool, Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                var uniqueRoomIds = Set<Int64>()
                for message in messages {
                    _ = MessageEntity(message: message, context: context)
                    
                    if let file = message.body?.file {
                        _ = FileEntity(file: file, context: context)
                    }
                    
                    if let thumb = message.body?.thumb {
                        _ = FileEntity(file: thumb, context: context)
                    }
                    
                    if let records = message.records {
                        records.forEach { record in
                            _ = MessageRecordEntity(record: record, context: context)
                        }
                    }
                    uniqueRoomIds.insert(message.roomId)
                }
                
                // if save is from sync, refresh every room lastMessageTimestamp
                for roomId in uniqueRoomIds {
                    if let lastMessage = messages.filter({ $0.roomId == roomId }).max(by: {$0.createdAt < $1.createdAt}) {
                        self?.updateRoomLastMessageTimestamp(roomId: lastMessage.roomId, timestamp: lastMessage.createdAt)
                    }
                }
                
                do {
                    try context.save()
                    promise(.success(true))
                } catch {
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
        
    func saveMessageRecords(_ messageRecords: [MessageRecord]) -> Future<Bool, Error> {
        return Future { [weak self] promise in
            guard let self else { return }
            self.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                for messageRecord in messageRecords {
                    _ = MessageRecordEntity(record: messageRecord, context: context)
                }
                
                self?.updateMessagesDummyValue(ids: messageRecords.map({ $0.messageId }))
              
                do {
                    try context.save()
                    promise(.success(true))
                } catch {
                    promise(.failure(DatabaseError.savingError))
                }
            }
        }
    }
     // TODO: - refactorIt
    func getNotificationInfoForMessage(message: Message) -> Future<MessageNotificationInfo, Error> {
        return Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                guard let self else { return }
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                // fetch room from database
                let roomEntiryFR = RoomEntity.fetchRequest()
                roomEntiryFR.predicate = NSPredicate(format: "id == %d", message.roomId)
                
                guard let rooms = try? context.fetch(roomEntiryFR),
                      rooms.count == 1,
                      let room = rooms.first,
                      let user = self.getUsers(id: [message.fromUserId], context: context)?.first
                else {
                    promise(.failure(DatabaseError.unknown))
                    return
                }
                
                let info: MessageNotificationInfo
                
                if room.type == RoomType.privateRoom.rawValue {
                    info = MessageNotificationInfo(title: user.getDisplayName(),
                                                   photoUrl: user.avatarFileId?.fullFilePathFromId(),
                                                   messageText: message.pushNotificationText,
                                                   roomId: room.id,
                                                   isRoomMuted: room.muted)
                } else {
                    info = MessageNotificationInfo(title: room.name ?? "no name",
                                                   photoUrl: room.avatarFileId.fullFilePathFromId(),
                                                   messageText: "\(user.getDisplayName()): " +  message.pushNotificationText,
                                                   roomId: room.id,
                                                   isRoomMuted: room.muted)
                }
                promise(.success(info))
                
                
            }
        }

    }
}

// MARK: - helper functions, be carefull with threads

extension DatabaseService {
    func getRoomUsers(roomId: Int64, context: NSManagedObjectContext) -> [RoomUser]? {
        var roomUsers: [RoomUser]?
        context.performAndWait {
            // fetch all [RoomUserEntity] from database
            let roomUsersFR = RoomUserEntity.fetchRequest()
            roomUsersFR.predicate = NSPredicate(format: "roomId == %d", roomId)
            
            guard let roomUserEntities = try? context.fetch(roomUsersFR) else { return }
            
            // fetch all [User] from database
            let users = getUsers(id: roomUserEntities.map({ $0.userId }), context: context)
            
            // return [RoomUser], should be same count as [RoomUserEntity]
            
            roomUsers = roomUserEntities.compactMap { roomUserEntity in
                guard let user = users?.first(where: { $0.id == roomUserEntity.userId})
                else {
                    return nil
                }
                return RoomUser(roomUserEntity: roomUserEntity, user: user)
            }
        }
        return roomUsers
    }
    
    private func getUsers(id: [Int64], context: NSManagedObjectContext) -> [User]? {
        let usersFR = UserEntity.fetchRequest()
        usersFR.predicate = NSPredicate(format: "id IN %@", id) // check
        guard let userEntities = try? context.fetch(usersFR)
        else {
            return nil
        }
        return userEntities.map {
            User(entity: $0)
        }
    }
    
    func updateMessageSeenDeliveredCount(messageId: Int64, seenCount: Int64, deliveredCount: Int64) {
        coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            let messageFR = MessageEntity.fetchRequest()
            messageFR.predicate = NSPredicate(format: "id == %d", messageId)
            guard let entity = try? context.fetch(messageFR).first else { return }
            
            if seenCount > entity.seenCount {
                entity.seenCount = seenCount
            }
            
            if deliveredCount > entity.deliveredCount {
                entity.deliveredCount = deliveredCount
            }
            do {
                try context.save()
            } catch {
                
            }
        }
    }
    
    private func updateMessagesDummyValue(ids: [Int64]) {
        coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
            let messagesFR = MessageEntity.fetchRequest()
            messagesFR.predicate = NSPredicate(format: "id IN %@", ids)
            
            guard let messageEntities = try? context.fetch(messagesFR) else { return }
            
            messageEntities.forEach { $0.dummyValue = $0.dummyValue + 1 }
            try? context.save()
        }
    }
    
    private func updateRoomLastMessageTimestamp(roomId: Int64, timestamp: Int64) {
        coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
            let roomsFR = RoomEntity.fetchRequest()
            roomsFR.predicate = NSPredicate(format: "id == %d", roomId)
            guard let roomEntities = try? context.fetch(roomsFR),
                  roomEntities.count == 1,
                  let entity = roomEntities.first
            else {
                // TODO: - add warning
                return
            }
            if entity.lastMessageTimestamp < timestamp {
                entity.lastMessageTimestamp = timestamp
            }
            try? context.save()
        }
    }
    
    func getReactionRecords(messageId: String?, context: NSManagedObjectContext) -> [MessageRecord]? {
        var records: [MessageRecord]?
        context.performAndWait {
            guard let id = Int64(messageId ?? "failIsOk") else { return }
            let recordsFR = MessageRecordEntity.fetchRequest()
            recordsFR.predicate = NSPredicate(format: "messageId == %d AND type == %@", id, MessageRecordType.reaction.rawValue)
            guard let entities = try? context.fetch(recordsFR),
                  !entities.isEmpty
            else { return }
            records = entities.map { MessageRecord(messageRecordEntity: $0) }
        }
        return records
    }
    
    func updateUnreadCounts(_ counts: [UnreadCount]) {
        coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
            let roomsFR = RoomEntity.fetchRequest()

            guard let entities = try? context.fetch(roomsFR) else { return }
            entities.forEach { $0.unreadCount = 0 }
            for count in counts {
                entities.first { $0.id == count.roomId }?.unreadCount = count.unreadCount
            }
            try? context.save()
        }
    }
    
    func resetUnreadCount(_ roomId: Int64) {
        coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
            let roomsFR = RoomEntity.fetchRequest()
            roomsFR.predicate = NSPredicate(format: "id = %d", roomId)
            guard let entities = try? context.fetch(roomsFR) else { return }
            entities.forEach { $0.unreadCount = 0 }
            try? context.save()
        }
    }
    
    func getLastMessage(roomId: Int64, context: NSManagedObjectContext) -> Message? {
        var message: Message?
        context.performAndWait {
            let fr = MessageEntity.fetchRequest()
            fr.predicate = NSPredicate(format: "roomId == %d", roomId)
            fr.fetchLimit = 1
            fr.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            guard let entity = try? context.fetch(fr).first else { return }
            
            message = Message(messageEntity: entity,
                              fileData: getFileData(id: entity.bodyFileId, context: context),
                              thumbData: getFileData(id: entity.bodyThumbId, context: context),
                           records: [])
        }
        return message
    }
    
    func getFileData(id: String?, context: NSManagedObjectContext) -> FileData? {
        var fileData: FileData?
        context.performAndWait {
            guard let id = id else { return }
            let fr = FileEntity.fetchRequest()
            fr.predicate = NSPredicate(format: "id == %@", id)
            guard let entity = try? context.fetch(fr).first else { return }
            fileData = FileData(entity: entity)
        }
        return fileData
    }
}

extension DatabaseService {
    func missingRoomIds(ids: Set<Int64>) -> Future<Set<Int64>, Error> {
        Future { [weak self] promise in
            self?.coreDataStack.persistentContainer.performBackgroundTask { [weak self] context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                let roomsFR = RoomEntity.fetchRequest()
                roomsFR.predicate = NSPredicate(format: "id IN %@", ids)
                
                guard let roomsEntities = try? context.fetch(roomsFR) else {
                    promise(.failure(DatabaseError.requestFailed))
                    return
                }
                let fetchedIds = Set(roomsEntities.map { $0.id })                
                let dif = ids.subtracting(fetchedIds)
                promise(.success(dif))
            }
        }
    }
}
