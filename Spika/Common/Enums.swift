//
//  Enums.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.10.2022..
//

import Foundation

enum SyncType {
    case users
    case rooms
    case messageRecords
}

enum SSEEventType: String, Codable {
    case newMessage = "NEW_MESSAGE"
    case newMessageRecord = "NEW_MESSAGE_RECORD"
    case deletedMessageRecord = "DELETED_MESSAGE_RECORD"
    case newRoom = "NEW_ROOM"
    case updateRoom = "UPDATE_ROOM"
    case deleteRoom = "DELETE_ROOM"
    case userUpdate = "USER_UPDATE"
}
