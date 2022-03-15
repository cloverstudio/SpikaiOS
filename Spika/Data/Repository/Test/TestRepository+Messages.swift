//
//  TestRepository+Messages.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import Combine

extension TestRepository {
    func saveMessage(_ message: LocalMessage) -> Future<LocalMessage, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func getMessagesForChat(chat: LocalChat) -> Future<[LocalMessage], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func sendTextMessage(message: MessageBody, roomId: Int) -> AnyPublisher<SendMessageResponse, Error> {
       return Fail<SendMessageResponse, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
    }
        
}
