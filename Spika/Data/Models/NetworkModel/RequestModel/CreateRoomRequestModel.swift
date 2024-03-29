//
//  CreateRoomRequestModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation

struct CreateRoomRequestModel: Codable {
    var name: String?
    var avatarFileId: Int64?
    var userIds: [Int64]?
    var adminUserIds: [String]?
}

struct EditRoomUsersRequestModel: Codable {
    var userIds: [Int64]?
}

struct EditRoomAdminsRequestModel: Codable {
    var adminUserIds: [Int64]?
}

struct EditRoomAvatarRequestModel: Codable {
    var avatarFileId: Int64?
}

struct EditRoomNameRequestModel: Codable {
    var name: String
}
