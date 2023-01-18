//
//  TestRepository+Messages.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import CoreData
import Combine

extension TestRepository {
    func saveMessages(_ messages: [Message]) -> Future<[Message], Error> {
        Future { promise in
            promise(.failure(DatabseError.savingError))
        }
    }
    
    func sendMessage(body: RequestMessageBody, type: MessageType, roomId: Int64, localId: String, replyId: Int64?) -> AnyPublisher<SendMessageResponse, Error> {
       return Fail<SendMessageResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
    }
    
    func sendDeliveredStatus(messageIds: [Int64]) -> AnyPublisher<DeliveredResponseModel, Error> {
        return Fail<DeliveredResponseModel, Error>(error: NetworkError.noAccessToken)
                 .receive(on: DispatchQueue.main)
                 .eraseToAnyPublisher()
    }
    
    func sendSeenStatus(roomId: Int64) -> AnyPublisher<SeenResponseModel, Error> {
        return Fail<SeenResponseModel, Error>(error: NetworkError.noAccessToken)
                 .receive(on: DispatchQueue.main)
                 .eraseToAnyPublisher()
    }
    
    func getMessages(forRoomId: Int64) -> Future<[Message], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func updateLocalMessage(message: Message, localId: String) -> Future<Message, Error> {
        Future { p in
            p(.failure(DatabseError.requestFailed))
        }
    }
    
    func saveMessageRecords(_ messageRecords: [MessageRecord]) -> Future<[MessageRecord], Error> {
        Future { p in
            p(.failure(DatabseError.unknown))
        }
    }
    
    func printAllMessages() {
        databaseService.messageEntityService.printAllMessages()
    }
    
    func getNotificationInfoForMessage(_ message: Message) -> Future<MessageNotificationInfo, Error> {
        Future { p in
            p(.failure(DatabseError.requestFailed))
        }
    }
    
    func sendReaction(messageId: Int64, reaction: String) -> AnyPublisher<SendReactionResponseModel, Error> {
        return Fail<SendReactionResponseModel, Error>(error: NetworkError.noAccessToken)
                 .receive(on: DispatchQueue.main)
                 .eraseToAnyPublisher()
    }
}
