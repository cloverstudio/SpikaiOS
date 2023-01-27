//
//  Enums.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.10.2022..
//

import UIKit

enum RoomType: String, Codable {
    case privateRoom = "private"
    case groupRoom = "group"
}

enum MessageRecordType: String, Codable {
    case seen = "seen"
    case delivered = "delivered"
    case reaction = "reaction"
    case unknown = "unknown"
    
    public init(from decoder: Decoder) throws {
        self = try MessageRecordType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

struct MessageNotificationInfo {
    let title: String
    let photoUrl: URL?
    let messageText: String
    let room: Room
}

enum SyncType {
    case users
    case rooms
    case messages
    case messageRecords
}

enum DeleteMessageTarget: String, Codable {
    case all
    case user
}

enum ImagePickerError: Error {
    case badQuality, wrongDimensions

    var description : String {
        switch self {
        case .badQuality:
            return "Please use better quality"
        case .wrongDimensions:
            return "Please select a square"
        }
  }
}

enum WarningOrResult<Success> {
    case warning(String)
    case result(Success)
}
