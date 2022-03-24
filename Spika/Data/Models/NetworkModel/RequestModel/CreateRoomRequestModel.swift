//
//  CreateRoomRequestModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation

struct CreateRoomRequestModel: Codable {
    var name: String?
    var avatarUrl: String?
    var userIds: [Int]?
    var adminUserIds: [String]?
}