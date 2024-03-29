//
//  MessageDetailSection.swift
//  Spika
//
//  Created by Vedran Vugrin on 09.05.2023..
//

import Foundation
import UIKit

enum MessageDetailsSectionType {
    case senderActions, readBy, deliveredTo, sentTo
    
    func titleString() -> String {
        switch self {
        case .senderActions:
            return .getStringFor(.senderActions)
        case .readBy:
            return .getStringFor(.readBy)
        case .deliveredTo:
            return .getStringFor(.deliveredTo)
        case .sentTo :
            return .getStringFor(.sentTo)
        }
    }
    
    func sectionIcon() -> UIImage {
        switch self {
        case .senderActions:
            return UIImage(safeImage: .senderAction)
        case .readBy:
            return UIImage(safeImage: .seen)
        case .deliveredTo:
            return UIImage(safeImage: .delivered)
        case .sentTo :
            return UIImage(safeImage: .sent)
        }
    }
}

class MessageDetailsSection {
    
    typealias Record = (record: MessageRecord, user: User)
    
    let type: MessageDetailsSectionType
    let message: Message
    var user: User

    var sentContacts: [User]
    
    
    init(type: MessageDetailsSectionType,
         message: Message,
         user: User,
         sentContacts: [User]) {
        self.type = type
        self.message = message
        self.user = user
        self.sentContacts = sentContacts
    }
    
    func numberOfRows() -> Int {
        if type == .senderActions { return 1 }
        return sentContacts.count
    }
    
    
    func getDataForCell(at indexPath: IndexPath) -> (avatarUrl: URL?, name: String, time: String, editedTime: String?, telephoneNumber: String?)? {
        var time = "-"
        var editedTime: String? = nil
        
        var user: User!
        if type == .senderActions {
            user = self.user
            time = message.createdAt.convert(to: .messageDetailsTimeFormat)
            editedTime = message.modifiedAt.convert(to: .messageDetailsTimeFormat)
        } else {
            user = sentContacts[indexPath.row]
        }
        
        return (user.avatarFileId?.fullFilePathFromId() ?? nil,
                user.getDisplayName(),
                time, editedTime, user.telephoneNumber)
    }
    
}
