//
//  CurrentPrivateChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import Combine
import CoreData
import IKEventSource
import AVFoundation
import PhotosUI

class CurrentChatViewModel: BaseViewModel {
    
    let friendUser: User?
    var room: Room?
    let roomPublisher = PassthroughSubject<Room, Error>()
    let uploadProgressPublisher = PassthroughSubject<(percentUploaded: CGFloat, selectedFile: SelectedFile?), Never>()
    
    let isBlocked = CurrentValueSubject<Bool,Never>(false)
    let userRepliedInChat = CurrentValueSubject<Bool,Never>(true)
    let offerToBlock = CurrentValueSubject<Bool,Never>(false)
    
    let selectedMessageToReplyPublisher = CurrentValueSubject<Message?, Never>(nil)
    
    init(repository: Repository, coordinator: Coordinator, friendUser: User) {
        self.friendUser = friendUser
        super.init(repository: repository, coordinator: coordinator)
        self.setupBinding()
    }
    
    init(repository: Repository, coordinator: Coordinator, room: Room) {
        self.room = room
        
        self.friendUser = room.getFriendUserInPrivateRoom(myUserId: repository.getMyUserId())
        super.init(repository: repository, coordinator: coordinator)
        self.setupBinding()
    }
    
    func setupBinding() {
        self.repository.blockedUsersPublisher()
            .receive(on: DispatchQueue.main)
            .map { [weak self] blockedUsers in
                guard let blockedUsers = blockedUsers,
                      self?.room?.type == .privateRoom else { return false }
                
                let roomUserIds = self?.room?.users.map { $0.userId } ?? []
                return Set(blockedUsers).intersection(Set(roomUserIds)).count > 0
            }
            .subscribe(self.isBlocked)
            .store(in: &self.subscriptions)
        
        self.setupShouldOfferBlockBinding()
    }
    
    func setupShouldOfferBlockBinding() {
        guard self.room?.users.count == 2 else { return }
        
        let ownId = self.repository.getMyUserId()
        guard let contact = self.room?.users.first(where: { roomUser in
            roomUser.userId != ownId
        }) else { return }
        
        let contactId = contact.userId
        
        // Check if Contact is already blocked = false
        let contactBlocked = self.repository.blockedUsersPublisher()
            .map { $0?.contains(contactId) ?? false }
            .map { !$0 }
        
        // Check if Contact in Confirmed = false
        let contactConfirmed = self.repository.confirmedUsersPublisher()
            .map { $0.contains(contactId) }
            .map { !$0 }
        
        // Check if User replied at some point = false
        let userRepliedInChat = self.userRepliedInChat.map { !$0 }
        
        contactBlocked.combineLatest(contactConfirmed, userRepliedInChat)
            .map { $0 && $1 && $2 }
            .subscribe(self.offerToBlock)
            .store(in: &self.subscriptions)
    }
    
    func unblockUser() {
        let ownId = self.repository.getMyUserId()
        guard let contact = self.room?.users.first(where: { roomUser in
            roomUser.userId != ownId
        }) else { return }
        self.repository.unblockUser(userId: contact.userId)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.updateBlockedList()
                case .failure(_):
                    break
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func blockUser() {
        let ownId = self.repository.getMyUserId()
        guard let contact = self.room?.users.first(where: { roomUser in
            roomUser.userId != ownId
        }) else { return }
        self.repository.blockUser(userId: contact.userId)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.updateBlockedList()
                case .failure(_):
                    ()
                }
            } receiveValue: { _ in }
            .store(in: &self.subscriptions)
    }
    
    func userConfirmed() {
        let ownId = self.repository.getMyUserId()
        guard let contact = self.room?.users.first(where: { roomUser in
            roomUser.userId != ownId
        }) else { return }
        
        self.repository.updateConfirmedUsers(confirmedUsers: [contact.user])
    }
    
    func updateBlockedList() {
        repository.getBlockedUsers()
            .sink { _ in
            } receiveValue: { [weak self] response in
                self?.repository.updateBlockedUsers(users: response.data.blockedUsers)
            }.store(in: &subscriptions)
    }
    
    var userIsMember: Bool {
        let ids = self.room?.users.map { $0.userId } ?? []
        let ownId = self.getMyUserId()
        return ids.contains(ownId)
    }
    
}

// MARK: - Navigation
extension CurrentChatViewModel {
    func popTopViewController() {
        getAppCoordinator()?.popTopViewController()
    }
    
    func presentMessageDetails(records: [MessageRecord]) {
        guard let roomUsers = room?.users else {
            return
        }
        let users = roomUsers.compactMap { roomUser in
            roomUser.user
        }
        getAppCoordinator()?.presentMessageDetails(users: users, records: records)
    }
    
    func presentMoreActions() -> PassthroughSubject<MoreActions, Never>? {
        return getAppCoordinator()?.presentMoreActionsSheet()
    }
    
    func playVideo(message: Message) {
        guard let url = message.body?.file?.id?.fullFilePathFromId(),
              let mimeType = message.body?.file?.mimeType
        else { return }
        let asset = AVURLAsset(url: url, mimeType: mimeType)
        getAppCoordinator()?.presentAVVideoController(asset: asset)
    }
    
    func showImage(message: Message) {
        getAppCoordinator()?.presentImageViewer(message: message)
    }
    
    func showReactions(records: [MessageRecord]) {
        guard let roomUsers = room?.users else { return }
        let users = roomUsers.compactMap { roomUser in
            roomUser.user
        }
        getAppCoordinator()?.presentReactionsSheet(users: users, records: records)
    }
    
    func showMessageActions(_ message: Message) {
        getAppCoordinator()?
            .presentMessageActionsSheet()
            .sink(receiveValue: { [weak self] action in
                self?.getAppCoordinator()?.dismissViewController()
                guard let id = message.id else { return }
                switch action {
                case .reaction(emoji: let emoji):
                    self?.sendReaction(reaction: emoji, messageId: id)
                case .reply:
                    self?.selectedMessageToReplyPublisher.send(message)
                case .copy:
                    UIPasteboard.general.string = message.body?.text
                    self?.showOneSecAlert(type: .copy)
                case .details:
                    self?.presentMessageDetails(records: message.records ?? [])
                case .delete:
                    self?.showDeleteConfirmDialog(message: message)
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
    
    func showDeleteConfirmDialog(message: Message) {
        guard let id = message.id else { return }
        var actions: [AlertViewButton] = [.destructive(title: .getStringFor(.deleteForMe))]
        if message.fromUserId == getMyUserId() {
            actions.append(.destructive(title: .getStringFor(.deleteForEveryone)))
        }
        getAppCoordinator()?
            .showAlert(actions: actions)
            .sink(receiveValue: { [weak self] tappedIndex in
                switch tappedIndex {
                case 0:
                    self?.deleteMessage(id: id, target: .user)
                case 1:
                    self?.deleteMessage(id: id, target: .all)
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
    
    func deleteMessage(id: Int64, target: DeleteMessageTarget) {
        repository.deleteMessage(messageId: id, target: target).sink { c in
            
        } receiveValue: { [weak self] response in
            guard let message = response.data?.message else { return }
            self?.saveMessage(message: message)
        }.store(in: &subscriptions)
    }
}

extension CurrentChatViewModel {
    
    func checkLocalRoom() {
        if let room = room {
            roomPublisher.send(room)
        } else if let friendUser = friendUser {
            repository.checkLocalRoom(forUserId: friendUser.id).sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    print("no local room")
                    self.checkOnlineRoom()
                }
            } receiveValue: { [weak self] room in
                guard let self = self else { return }
                self.room = room
                self.roomPublisher.send(room)
            }.store(in: &subscriptions)
        }
    }
    
    func checkOnlineRoom()  {
        guard let friendUser = friendUser else { return }
        networkRequestState.send(.started())
        
        repository.checkOnlineRoom(forUserId: friendUser.id).sink { [weak self] completion in
            guard let self = self else { return }
            switch completion {
            case .finished:
                print("online check finished")
            case .failure(let error):
                self.showError(error.localizedDescription)
                self.networkRequestState.send(.finished)
                // TODO: publish error
            }
        } receiveValue: { [weak self] response in
            
            guard let self = self else { return }
            
            if let room = response.data?.room {
                print("There is online room.")
                self.saveLocalRoom(room: room)
                self.networkRequestState.send(.finished)
            } else {
                print("There is no online room, creating started...")
                self.createRoom(userId: friendUser.id)
            }
        }.store(in: &subscriptions)
    }
    
    func saveLocalRoom(room: Room) {
        repository.saveLocalRooms(rooms: [room]).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
                
            case .finished:
                print("saved to local DB")
            case .failure(_):
                print("saving to local DB failed")
            }
        } receiveValue: { [weak self] rooms in
            guard let self = self,
                  let room = rooms.first
            else { return }
            self.room = room
            self.roomPublisher.send(room)
        }.store(in: &subscriptions)
    }
    
    func createRoom(userId: Int64) {
        networkRequestState.send(.started())
        repository.createOnlineRoom(userId: userId).sink { [weak self] completion in
            guard let self = self else { return }
            self.networkRequestState.send(.finished)
            
            switch completion {
            case .finished:
                print("private room created")
            case .failure(let error):
                self.showError(error.localizedDescription)
                // TODO: present dialog and return? publish error
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            print("creating room response: ", response)
            if let errorMessage = response.message {
                //                PopUpManager.shared.presentAlert(with: (title: "Error", message: errorMessage), orientation: .horizontal, closures: [("Ok", {
                //                    self.getAppCoordinator()?.popTopViewController()
                //                })]) // TODO: - check
            }
            guard let room = response.data?.room else { return }
            self.saveLocalRoom(room: room)
        }.store(in: &subscriptions)
    }
    
    func roomVisited(roomId: Int64) {
        repository.roomVisited(roomId: roomId)
    }
}

extension CurrentChatViewModel {
    func trySendMessage(text: String) {
        guard let room = self.room else { return }
        print("ROOM: ", room)
        let uuid = UUID().uuidString
        let message = Message(createdAt: Date().currentTimeMillis(),
                              fromUserId: getMyUserId(),
                              roomId: room.id,
                              type: .text,
                              body: MessageBody(text: text, file: nil, thumb: nil),
                              replyId: selectedMessageToReplyPublisher.value?.id,
                              localId: uuid)
        
        repository.saveMessages([message]).sink { c in
            
        } receiveValue: { [weak self] messages in
            let body = RequestMessageBody(text: message.body?.text,
                                          fileId: nil,
                                          thumbId: nil)
            self?.selectedMessageToReplyPublisher.send(nil)
            self?.sendMessage(body: body, localId: uuid, type: .text, replyId: message.replyId)
        }.store(in: &subscriptions)
    }
    
    
    func sendMessage(body: RequestMessageBody, localId: String, type: MessageType, replyId: Int64?) {
        guard let room = self.room else { return }
        
        self.repository.sendMessage(body: body, type: type, roomId: room.id, localId: localId, replyId: replyId).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
                
            case .finished:
                print("finished")
            case let .failure(error):
                print("send text message error: ", error)
            }
        } receiveValue: { [weak self] response in
            print("SendMessage response: ", response)
            guard let self = self,
                  let message = response.data?.message
            else { return }
            self.saveMessage(message: message)
        }.store(in: &self.subscriptions)
    }
    
    func saveMessage(message: Message) {
        repository.saveMessages([message]).sink { c in
            print(c)
        } receiveValue: { _ in
            
        }.store(in: &subscriptions)
    }
}

extension CurrentChatViewModel {
    func getUser(for id: Int64) -> User? {
        return room?.users.first(where: { roomUser in
            roomUser.userId == id
        })?.user
    }
}

extension CurrentChatViewModel {
    func sendSeenStatus() {
        guard let roomId = room?.id else { return }
        repository.sendSeenStatus(roomId: roomId).sink { c in
            
        } receiveValue: { [weak self] response in
            guard let messageRecords = response.data?.messageRecords else { return }
            self?.repository.saveMessageRecords(messageRecords)
        }.store(in: &subscriptions)
    }
}

// MARK: - sending pictures/video

extension CurrentChatViewModel {
    
    func upload(file: SelectedFile) {
        switch file.fileType {
        case .image, .video:
            guard let thumbURL = file.thumbUrl,
                  let thumbMetadata = file.thumbMetadata
            else { return }
            uploadProgressPublisher.send((percentUploaded: 0.01, selectedFile: file))
            repository
                .uploadWholeFile(fromUrl: thumbURL, mimeType: "image/*", metaData: thumbMetadata)
                .sink { c in
                    
                } receiveValue: { [weak self] filea, percent in
                    guard let filea = filea else { return }
                    guard let self = self else { return }
                    self.repository
                        .uploadWholeFile(fromUrl: file.fileUrl, mimeType: file.mimeType, metaData: file.metaData)
                        .sink { c in
                            
                        } receiveValue: { [weak self] fileb, percent in
                            guard let self = self else { return }
                            self.uploadProgressPublisher.send((percentUploaded: percent, selectedFile: file))
                            guard let fileb = fileb else { return }
                            self.sendMessage(body: RequestMessageBody(text: nil, fileId: fileb.id, thumbId: filea.id), localId: file.localId, type: file.fileType, replyId: nil)
                        }.store(in: &self.subscriptions)
                }.store(in: &subscriptions)
        default:
            uploadProgressPublisher.send((percentUploaded: 0.01, selectedFile: nil))
            repository
                .uploadWholeFile(fromUrl: file.fileUrl,
                                 mimeType: file.mimeType,
                                 metaData: file.metaData)
                .sink { c in
                    
                } receiveValue: { [weak self] filea, percent in
                    self?.uploadProgressPublisher.send((percentUploaded: percent, selectedFile: nil))
                    self?.sendMessage(body: RequestMessageBody(text: nil, fileId: filea?.id, thumbId: nil),
                                      localId: file.localId,
                                      type: file.fileType,
                                      replyId: nil)
                }.store(in: &subscriptions)
        }
        
    }
    
    func sendFile(file: SelectedFile) {
        guard let room = room else { return }
        let uuid = file.localId
        
        let message = Message(createdAt: Date().currentTimeMillis(),
                              fromUserId: getMyUserId(),
                              roomId: room.id,
                              type: file.fileType,
                              body: MessageBody(text: nil,
                                                file: FileData(id: nil,
                                                               fileName: file.name,
                                                               mimeType: file.mimeType,
                                                               size: file.size,
                                                               metaData: file.metaData),
                                                thumb: nil),
                              replyId: nil,
                              localId: uuid)
        
        repository.saveMessages([message]).sink { c in
            
        } receiveValue: { [weak self] messages in
            self?.upload(file: file)
        }.store(in: &subscriptions)
    }
    
    func sendResized(resizedImage: UIImage) {
        let uuid = UUID().uuidString
        guard let jpgData = resizedImage.jpegData(compressionQuality: 1),
              let fileURL = repository.saveDataToFile(jpgData, name: uuid),
              let thumbData = fileURL.downsample(isForThumbnail: true)?.jpegData(compressionQuality: 1),
              let thumbURL = repository.saveDataToFile(thumbData, name: "\(uuid)thumb"),
              let fileMetadata = fileURL.imageMetaData(),
              let thumbMetadata = thumbURL.imageMetaData()
        else { return }
        
        let file = SelectedFile(fileType: .image, name: uuid,
                                fileUrl: fileURL, thumbUrl: thumbURL,
                                thumbMetadata: thumbMetadata, metaData: fileMetadata,
                                mimeType: "image/*", size: nil, localId: uuid)
        sendFile(file: file)
    }
    
    func sendMultimedia(_ results: [PHPickerResult]) {
        for result in results {
            
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
                    guard let url = url,
                          let downsampledImage = url.downsample()
                    else { return }
                    self?.sendResized(resizedImage: downsampledImage)
                }
            }
            
//            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
//                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
//                    
//                    let uuid = UUID().uuidString
//                    let thumbImage = UIImage(safeImage: .playVideo)
//                    guard let url = url,
//                          let fileUrl = self?.repository.copyFile(from: url, name: uuid),
//                          let videoMetadata = fileUrl.videoMetaData(),
//                          //                          let thumbImage = fileUrl.videoThumbnail(),
//                          let resizedData = self?.resizeImage(thumbImage)?.jpegData(compressionQuality: 1),
//                          let thumbUrl = self?.repository.saveDataToFile(resizedData, name: "\(uuid)thumb"),
//                          let thumbMetadata = thumbUrl.imageMetaData()
//                            
//                    else { return }
//                    
//                    let file = SelectedFile(fileType: .video,
//                                            name: uuid,
//                                            fileUrl: fileUrl,
//                                            thumbUrl: thumbUrl, thumbMetadata: thumbMetadata, metaData: videoMetadata, mimeType: "video/mp4", size: nil, localId: uuid)
//                    self?.sendFile(file: file)
//                }
//            }
        }
    }
    
    func sendDocuments(urls: [URL]) {
        //        for url in urls {
        //            guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent),
        //                  url.copyFileFromURL(to: targetURL) == true,
        //                  let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey, .nameKey, .fileSizeKey]),
        //                  let type = resourceValues.contentType,
        //                  let size = resourceValues.fileSize
        //            else { return }
        //            let fileName = resourceValues.name ?? "unknownName"
        //
        //            print("TYPEE: ", type)
        //            let file = SelectedFile(fileType: .file,
        //                                    name: fileName,
        //                                    fileUrl: targetURL,
        //                                    thumbnail: nil,
        //                                    metaData: MetaData(width: 0, height: 0, duration: 0),
        //                                    mimeType: "\(type)",
        //                                    size: Int64(size))
        //            sendFile(file: file)
        //        }
    }
    
    func sendCameraImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1),
              let resizedImage = repository.saveDataToFile(data, name: "tempFile")?.downsample()
        else { return }
        sendResized(resizedImage: resizedImage)
    }
    
    
}

// MARK: - Reactions

extension CurrentChatViewModel {
    func sendReaction(reaction: String, messageId: Int64) {
        repository.sendReaction(messageId: messageId, reaction: reaction)
            .sink { c in
            } receiveValue: { [weak self] response in
                guard let records = response.data?.messageRecords else { return }
                self?.repository.saveMessageRecords(records)
            }.store(in: &subscriptions)
    }
}
