//
//  MessageEntity+CoreDataProperties.swift
//  
//
//  Created by Nikola Barbarić on 28.09.2022..
//
//

import Foundation
import CoreData


extension MessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    }

    @NSManaged public var bodyText: String?
    @NSManaged public var bodyFileId: Int64
    @NSManaged public var bodyFileMimeType: String?
    @NSManaged public var bodyFileName: String?
    @NSManaged public var bodyFileSize: Int64
    @NSManaged public var bodyFileMetaDataWidth: Int64
    @NSManaged public var bodyFileMetaDataHeight: Int64
    @NSManaged public var bodyFileMetaDataDuration: Int64
    @NSManaged public var bodyThumbMimeType: String?
    @NSManaged public var bodyThumbId: Int64
    @NSManaged public var bodyThumbMetaDataWidth: Int64
    @NSManaged public var bodyThumbMetaDataHeight: Int64
    @NSManaged public var bodyThumbMetaDataDuration: Int64
    @NSManaged public var percentUploaded: Int64
    @NSManaged public var createdAt: Int64
    @NSManaged public var isRemoved: Bool
    @NSManaged public var deliveredCount: Int64
    @NSManaged public var fromUserId: Int64
    @NSManaged public var id: String?
    @NSManaged public var replyId: String?
    @NSManaged public var localId: String?
    @NSManaged public var roomId: Int64
    @NSManaged public var seenCount: Int64
    @NSManaged public var totalUserCount: Int64
    @NSManaged public var type: String?
    @NSManaged public var createdDate: Date?
    
    @objc public var sectionName: String {
        guard let createdDate = createdDate else {
            return ""
        }
        let dateFormatter = DateFormatter()
        if createdDate.isInToday {
            return "Today"
        } else if createdDate.isInYesterday {
            return "Yesterday"
        } else if createdDate.isInThisWeek {
            dateFormatter.dateFormat = "EEEE"
        }
        else if createdDate.isInThisYear {
            dateFormatter.dateFormat = "dd MM"
        } else {
            dateFormatter.dateFormat = "dd MM YYYY"
        }
        return dateFormatter.string(from: createdDate)
    }
}
