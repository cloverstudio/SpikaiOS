//
//  ChatsViewModel.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import Foundation
import Combine
import CoreData

class AllChatsViewModel: BaseViewModel {
    
    var frc: NSFetchedResultsController<RoomEntity>?
    
    var defaultChatsPredicate: NSPredicate = {
        let predicate1 =  NSPredicate(format: "type == '\(RoomType.groupRoom.rawValue)' OR lastMessageTimestamp > 0")
        let predicate2 = NSPredicate(format: "roomDeleted == false")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
    } ()
    
    func presentSelectUserScreen() {
        getAppCoordinator()?.presentSelectUserScreen()
    }
    
    func presentCurrentChatScreen(room: Room) {
        getAppCoordinator()?.presentCurrentChatScreen(room: room)
    }
}

extension AllChatsViewModel {
    func setRoomsFetch() {
        let fetchRequest = RoomEntity.fetchRequest()
        fetchRequest.predicate = self.defaultChatsPredicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(RoomEntity.pinned), ascending: false),
                                        NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp), ascending: false),
                                        NSSortDescriptor(key: #keyPath(RoomEntity.createdAt), ascending: true)]
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                              managedObjectContext: self.repository.getMainContext(), sectionNameKeyPath: nil, cacheName: nil)
        do {
            try self.frc?.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
            // TODO: handle error and change main context to func
        }
    }
    
    func changePredicate(to newString: String) {
        let searchPredicate = newString.isEmpty ? defaultChatsPredicate : NSPredicate(format: "name CONTAINS[c] '\(newString)' and roomDeleted = false")
        self.frc?.fetchRequest.predicate = searchPredicate
        self.frc?.fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(RoomEntity.pinned), ascending: false),
                                                  NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp), ascending: false),
                                                  NSSortDescriptor(key: #keyPath(RoomEntity.createdAt), ascending: true)]
        try? frc?.performFetch()
    }
    
    func getRoom(for indexPath: IndexPath) -> Room? {
        guard let entity = frc?.object(at: indexPath),
              let context = entity.managedObjectContext,
              let roomUsers = repository.getRoomUsers(roomId: entity.id, context: context)
        else { return nil }
        return Room(roomEntity: entity, users: roomUsers)
    }
    
    func getLastMessage(for indexPath: IndexPath) -> Message? {
        guard let entity = frc?.object(at: indexPath),
              let context = entity.managedObjectContext
        else { return nil }
        return repository.getLastMessage(roomId: entity.id, context: context)
    }
    
    func description(message: Message?, room: Room) -> String {
        // TODO: - add strings to loc. strings?
        guard let message = message else { return "(No messages)"}
        let desc: String
        if room.type == .privateRoom {
            desc = (message.fromUserId == getMyUserId() ? "Me: " : "")
            + (message.body?.text ?? message.type.pushNotificationText)
        } else {
            desc = (message.fromUserId == getMyUserId() ? "Me" : ((room.users.first(where: { $0.userId == message.fromUserId })?.user.getDisplayName() ?? "_")))
                    + ": " + (message.body?.text ?? message.type.pushNotificationText)
        }
        return desc
    }
    
    func getDataForCell(at indexPath: IndexPath) -> (avatarUrl: URL?, name: String,
                                                     description: String, time: String,
                                                     badgeNumber: Int64, muted: Bool, pinned: Bool)?
    {
        guard let room = getRoom(for: indexPath) else { return nil }
        let lastMessage = getLastMessage(for: indexPath)
        
        if room.type == .privateRoom,
           let friendUser = room.getFriendUserInPrivateRoom(myUserId: getMyUserId()) {
            
            return (avatarUrl: friendUser.avatarFileId?.fullFilePathFromId(),
                                name: friendUser.getDisplayName(),
                                description: description(message: lastMessage, room: room),
                                time: lastMessage?.createdAt.convert(to: .allChatsTimeFormat) ?? "",
                                badgeNumber: room.unreadCount,
                                muted: room.muted,
                                pinned: room.pinned)
            
        } else {
            
            return (avatarUrl: room.avatarFileId?.fullFilePathFromId(),
                                name: room.name ?? .getStringFor(.noName),
                                description: description(message: lastMessage, room: room),
                                time: lastMessage?.createdAt.convert(to: .allChatsTimeFormat) ?? "",
                                badgeNumber: room.unreadCount,
                                muted: room.muted,
                                pinned: room.pinned)
        }
    }
}

extension AllChatsViewModel {
    func refreshUnreadCounts() {
        repository.getUnreadCounts().sink { c in
            
        } receiveValue: { [weak self] response in
            guard let unreadCounts = response.data?.unreadCounts else { return }
            self?.repository.updateUnreadCounts(unreadCounts: unreadCounts)
        }.store(in: &subscriptions)

    }
}
