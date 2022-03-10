//
//  CommonModels.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.02.2022..
//

import Foundation

// MARK: - User
struct AppUser: Codable {
    let id: Int?
    let displayName: String?
    let avatarUrl: String?
    let telephoneNumber: String?
    let telephoneNumberHashed: String?
    let emailAddress: String?
    let createdAt: Int?
    
    func getAvatarUrl() -> String? {
        if let avatarUrl = avatarUrl {
            if avatarUrl.starts(with: "http") {
                return avatarUrl
            } else {
                return Constants.Networking.baseUrl + avatarUrl
            }
        } else {
            return nil
        }
    }
}

extension AppUser: Comparable {
    static func < (lhs: AppUser, rhs: AppUser) -> Bool {
        return lhs.displayName! < rhs.displayName!
    }
    
    static func == (lhs: AppUser, rhs: AppUser) -> Bool {
        return lhs.displayName! == rhs.displayName!
    }
}


