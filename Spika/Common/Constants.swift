//
//  Constants.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation

struct Constants {
    struct Strings {
        static let appName = "Spika"
        static let cancel = "Cancel"
    }
    
    struct Networking {
        static let baseUrl = "https://spika3dev.spika.chat/"
    }
    
    struct Endpoints {
        static let getPosts = "posts"
        static let authenticateUser = "api/messenger/auth"
        static let verifyCode = "api/messenger/auth/verify"
        static let uploadFiles = "api/upload/files"
        static let userInfo = "api/messenger/me"
        static let contacts = "api/messenger/contacts"
    }
    
    struct Database {
        static let databaseName = "CoreDatabase"
        static let userEntity = "UserEntity"
        static let chatEntity = "ChatEntity"
        static let messageEntity = "MessageEntity"
    }
    
    struct UserDefaults {
        static let userId = "userId"
        static let userPhoneNumber = "userPhoneNumber"
        static let deviceId = "deviceId"
        static let accessToken = "accessToken"
        
//        struct settings {
//            static let autoDownload = "autodownload"
//        }
    }
    
}
