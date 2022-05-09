//
//  MessageEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.05.2022..
//
//

import Foundation
import CoreData


extension MessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    }

    @NSManaged public var bodyText: String?
    @NSManaged public var createdAt: Int64
    @NSManaged public var deliveredCount: Int64
    @NSManaged public var fromUserId: Int64
    @NSManaged public var id: String?
    @NSManaged public var localId: String?
    @NSManaged public var roomId: Int64
    @NSManaged public var seenCount: Int64
    @NSManaged public var totalUserCount: Int64
    @NSManaged public var type: String?
    
    @NSManaged public var room: RoomEntity?

}

extension MessageEntity : Identifiable {

}
