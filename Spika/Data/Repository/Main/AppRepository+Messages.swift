//
//  AppRepository+Messages.swift
//  Spika
//
//  Created by Marko on 19.10.2021..
//

import CoreData
import Combine

// MARK: Network
extension AppRepository {
    func sendMessage(body: RequestMessageBody, type: MessageType, roomId: Int64, localId: String, replyId: Int64?) -> AnyPublisher<MessageResponse, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<MessageResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<MessageResponse, SendMessageRequest>(
            path: Constants.Endpoints.sendMessage,
            requestType: .POST,
            bodyParameters: SendMessageRequest(roomId: roomId,
                                               type: type.rawValue,
                                               body: body,
                                               localId: localId,
                                               replyId: replyId),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func deleteMessage(messageId: Int64, target: DeleteMessageTarget) -> AnyPublisher<MessageResponse, Error> {
        guard let accessToken = getAccessToken()
        else {return Fail<MessageResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<MessageResponse, EmptyRequestBody>(
            path: Constants.Endpoints.sendMessage + "/\(messageId)",
            requestType: .DELETE,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken],
            queryParameters: ["target" : target.rawValue])
        
        return networkService.performRequest(resources: resources)
    }
    
    func updateMessage(messageId: Int64, text: String) -> AnyPublisher<MessageResponse, Error> {
        guard let accessToken = getAccessToken()
        else {
            return Fail<MessageResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<MessageResponse, UpdateMessageRequest>(
            path: Constants.Endpoints.sendMessage + "/\(messageId)",
            requestType: .PUT,
            bodyParameters: UpdateMessageRequest(text: text),
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    private func sendDeliveredIds(_ messageIds: [Int64]) -> AnyPublisher<DeliveredResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else { return Fail<DeliveredResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<DeliveredResponseModel, DeliveredRequestModel>(
            path: Constants.Endpoints.deliveredStatus,
            requestType: .POST,
            bodyParameters: DeliveredRequestModel(messagesIds: messageIds),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    private func sendSeenRoomId(_ roomId: Int64) -> AnyPublisher<SeenResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else {
            return Fail(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SeenResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.seenStatus.replacingOccurrences(of: "roomId", with: "\(roomId)"),
            requestType: .POST,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
        
    func sendReaction(messageId: Int64, reaction: String) -> AnyPublisher<SendReactionResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else {
            return Fail(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<SendReactionResponseModel, SendReactionRequestModel>(
            path: Constants.Endpoints.messageRecords,
            requestType: .POST,
            bodyParameters: SendReactionRequestModel(messageId: messageId,
                                                     type: .reaction,
                                                     reaction: reaction),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func getReactionRecords(messageId: String?, context: NSManagedObjectContext) -> [MessageRecord]? {
        databaseService.getReactionRecords(messageId: messageId, context: context)
    }
    
    func updateMessageSeenDeliveredCount(messageId: Int64, seenCount: Int64, deliveredCount: Int64) {
        databaseService.updateMessageSeenDeliveredCount(messageId: messageId, seenCount: seenCount, deliveredCount: deliveredCount)
    }
        
    // MARK: Database
    
    func saveMessages(_ messages: [Message]) -> Future<Bool, Error> {
        return databaseService.saveMessages(messages)
    }
    
    func getLastMessage(roomId: Int64, context: NSManagedObjectContext) -> Message? {
        return databaseService.getLastMessage(roomId: roomId, context: context)
    }
    
    func saveMessageRecords(_ messageRecords: [MessageRecord]) -> Future<Bool, Error> {
        self.databaseService.saveMessageRecords(messageRecords)
    }
    
    // first push missing room problem is solved, be careful
    func getNotificationInfoForMessage(_ message: Message) -> Future<MessageNotificationInfo, Error> {
        Future { [weak self] promise in
            guard let self else { return }
            self.databaseService.missingRoomIds(ids: [message.roomId]).sink { _ in
                
            } receiveValue: { [weak self] missingIds in
                guard let self else { return }
                if missingIds.isEmpty {
                    self.databaseService.getNotificationInfoForMessage(message: message).sink { c in
                        
                    } receiveValue: { [weak self] info in
                        promise(.success(info))
                    }.store(in: &self.subs)
                } else {
                    self.checkOnlineRoom(forRoomId: message.roomId).sink { _ in
                        
                    } receiveValue: { [weak self] response in
                        guard let self else { return }
                        guard let room = response.data?.room else { return }
                        self.saveLocalRooms(rooms: [room]).sink { _ in
                            
                        } receiveValue: { [weak self] rooms in
                            guard let self else { return }
                            self.databaseService.getNotificationInfoForMessage(message: message).sink { _ in
                                
                            } receiveValue: { [weak self] info in
                                promise(.success(info))
                            }.store(in: &self.subs)
                        }.store(in: &self.subs)
                    }.store(in: &self.subs)
                }
            }.store(in: &self.subs)
        }
    }

}

// MARK: - public
extension AppRepository {
    func sendDeliveredStatus(messageIds: [Int64]) -> Future<Bool, Never> {
        Future { [weak self] promise in
            guard let self else { return }
            self.sendDeliveredIds(messageIds).sink { _ in
                
            } receiveValue: { [weak self] response in
                guard let records = response.data?.messageRecords else { return }
                _ = self?.saveMessageRecords(records)
                promise(.success(true))
            }.store(in: &self.subs)
        }
    }
    
    func sendSeenStatus(roomId: Int64) {
        sendSeenRoomId(roomId).sink { _ in
        
        } receiveValue: { [weak self] response in
            guard let records = response.data?.messageRecords else { return }
            _ = self?.saveMessageRecords(records)
            self?.updateUnreadCountToZeroFor(roomId: roomId)
            self?.removeNotificationsWith(roomId: roomId)
        }.store(in: &subs)
    }
}
