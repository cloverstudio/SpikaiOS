//
//  MessageTest.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation

struct Message: Codable {
    let createdAt: Int64
    let fromUserId: Int64
    let roomId: Int64
    let id: Int64?
    let localId: String?
    let totalUserCount: Int64?
    let deliveredCount: Int64?
    let seenCount: Int64?
    let replyId: Int64?
    let type: MessageType
    let body: MessageBody?
    let records: [MessageRecord]?
}

extension Message {
    init(createdAt: Int64, fromUserId: Int64, roomId: Int64, type: MessageType, body: MessageBody, replyId: Int64?, localId: String) {
        self.body = body
        self.id = nil
        self.localId = localId
        self.fromUserId = fromUserId
        self.totalUserCount = -1
        self.deliveredCount = -1
        self.seenCount = -1
        self.replyId = replyId
        self.roomId = roomId
        self.type = type
        self.createdAt = createdAt
        self.records = nil
    }
    
    init(messageEntity: MessageEntity) {
        var messageRecords: [MessageRecord] = []
        
        if let records = messageEntity.records?.allObjects as? [MessageRecordEntity] {
            messageRecords = records.map({ entity in
                MessageRecord(messageRecordEntity: entity)
            })
        }
        self.init(createdAt: messageEntity.createdAt,
                  fromUserId: messageEntity.fromUserId,
                  roomId: messageEntity.roomId,
                  id: Int64(messageEntity.id ?? "-2"), // TODO: - check
                  localId: messageEntity.localId,
                  totalUserCount: messageEntity.totalUserCount,
                  deliveredCount: messageEntity.deliveredCount,
                  seenCount: messageEntity.seenCount,
                  replyId: Int64(messageEntity.replyId ?? "-1"),
                  type: MessageType(rawValue: messageEntity.type ?? "") ?? .unknown, // check
                  body: MessageBody(text: messageEntity.bodyText ?? "",
                                    file: FileData(fileName: messageEntity.bodyFileName,
                                                   mimeType: messageEntity.bodyFileMimeType,
                                                   path: messageEntity.bodyFilePath,
                                                   size: messageEntity.bodyFileSize,
                                                   metaData: MetaData(width: messageEntity.bodyThumbMetaDataWidth,
                                                                      height: messageEntity.bodyThumbMetaDataHeight,
                                                                      duration: messageEntity.bodyThumbMetaDataDuration)),
                                    thumb: FileData(fileName: "thumb name",
                                                    mimeType: messageEntity.bodyThumbMimeType,
                                                    path: messageEntity.bodyThumbPath,
                                                    size: 0,
                                                    metaData: MetaData(width: messageEntity.bodyThumbMetaDataWidth,
                                                                       height: messageEntity.bodyThumbMetaDataHeight,
                                                                       duration: messageEntity.bodyThumbMetaDataDuration)),
                                    fileId: nil,
                                    thumbId: nil),
                  records: messageRecords)
    }
    
    func getMessageState(myUserId: Int64) -> MessageState {
        // TODO: check first seen, then delivered, then sent, waiting, error, (check fail)
        guard let records = records,
              let totalUserCount = totalUserCount
        else {
            print("there is no records")
            return .fail
        }
        
        print("RECORDS: ", records)
        
        if records.filter({ $0.type == .seen}).count == totalUserCount {
            return .seen
        }
        
        let deliveredCount = records.filter({ $0.type == .delivered}).count
        
        if deliveredCount == totalUserCount {
            return .delivered
        }
        
        if deliveredCount > 0 {
            return .sent
        }
        
        return .waiting
    }
}

struct MessageBody: Codable {
    let text: String?
    let file: FileData?
    let thumb: FileData?
    let fileId: Int64?
    let thumbId: Int64?
}

struct FileData: Codable {
    let fileName: String?
    let mimeType: String?
    let path: String?
    let size: Int64?
    let metaData: MetaData?
}

struct MetaData: Codable {
    let width: Int64
    let height: Int64
    let duration: Int64
}

enum MessageType: String, Codable {
    // Type is used for MessageCells reuseIdentifier too
    case text
    case image
    case video
    case file
    case audio
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try MessageType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum MessageState {
    case sent
    case delivered
    case seen
    case fail
    case waiting
}
