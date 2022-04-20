//
//  MessageTest.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation

struct Message: Codable {
    let createdAt: Int?      // TODO: all optionals????????
    let fromDeviceId: Int?   // MARK: we dont need this?
    let fromUserId: Int?
    let id: Int?
    let totalDeviceCount: Int?
    let deliveredCount: Int?
    let seenCount: Int?
    let roomId: Int?
    let type: String?
    let body: MessageBody?
}

extension Message {
    init(createdAt: Int, fromUserId: Int, roomId: Int, type: MessageType, body: MessageBody) {
        self.body = body
        self.id = -1
        self.fromUserId = fromUserId
        self.fromDeviceId = nil
        self.totalDeviceCount = nil
        self.deliveredCount = -1
        self.seenCount = -1
        self.roomId = roomId
        self.type = type.rawValue
        self.createdAt = createdAt
    }
    
    init(messageEntity: MessageEntity) {
        self.init(createdAt: Int(messageEntity.createdAt),
                  fromDeviceId: Int(messageEntity.fromDeviceId),
                  fromUserId: Int(messageEntity.fromUserId),
                  id: Int(messageEntity.id),
                  totalDeviceCount: Int(messageEntity.totalDeviceCount),
                  deliveredCount: Int(messageEntity.deliveredCount),
                  seenCount: Int(messageEntity.seenCount),
                  roomId: Int(messageEntity.roomId),
                  type: messageEntity.type ?? "todo check",
                  body: MessageBody(text: messageEntity.bodyText ?? ""))
    }
    
    func getMessageState() -> MessageState {
        // TODO: check first seen, then delivered, then sent, waiting, error, (check fail)
        if seenCount == 0 {
            return .sent
        }
        
//        if deliveredCount == totalDeviceCount {
//            return .delivered
//        }
//
        return .waiting
    }
}

struct MessageBody: Codable {
    let text: String?
}

enum MessageType: String, Codable {
    case text
    case photo
    case video
    case voice
}

enum MessageState {
    case sent
    case delivered
    case seen
    case fail
    case waiting
}
