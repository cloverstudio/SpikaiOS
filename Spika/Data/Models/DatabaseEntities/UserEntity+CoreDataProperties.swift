//
//  UserEntity+CoreDataProperties.swift
//  Spika
//
//  Created by Nikola Barbarić on 15.04.2022..
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var avatarUrl: String?
    @NSManaged public var createdAt: Int64
    @NSManaged public var displayName: String?
    @NSManaged public var emailAddress: String?
    @NSManaged public var familyName: String?
    @NSManaged public var givenName: String?
    @NSManaged public var id: Int64
    @NSManaged public var telephoneNumber: String?
    @NSManaged public var roomUsers: RoomUserEntity?

}

extension UserEntity : Identifiable {

}
