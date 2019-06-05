//
// Created by Masaki Ando on 2019-06-05.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

import Foundation

import ActiveRealm

class ActiveRealmUserSettings: ARMObject {

    @objc dynamic var authorID                      = ""
    @objc dynamic var notificationEnabled: NSNumber = false
}

class UserSettings: ARMActiveRealm {

    @objc var authorID                      = ""
    @objc var notificationEnabled: NSNumber = false

    // A relation property. This property is just alias.

    var author: Author {
        return relations["author"]?.object as! Author
    }

    // A property ignored by ActiveRealm.

    var isNotificationEnabled: Bool {
        return notificationEnabled.boolValue
    }

    override class func ignoredProperties() -> [String] {
        return ["isNotificationEnabled"]
    }

    override class func definedRelationships() -> [String: ARMRelationship] {
        return ["author": ARMInverseRelationship(with: Author.self, type: .belongsTo)]
    }

    override class func validateBeforeSaving(_ obj: Any) -> Bool {
        let userSettings = obj as! UserSettings

        return !userSettings.authorID.isEmpty
    }

    override var description: String {
        let dict = dictionaryWithValues(forKeys: [
            "uid",
            "authorID",
            "notificationEnabled",
            "createdAt",
            "updatedAt"
        ])

        return "\(dict)"
    }
}
