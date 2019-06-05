//
// Created by Masaki Ando on 2019-06-04.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

import Foundation

import ActiveRealm

class ActiveRealmAuthor: ARMObject {

    @objc dynamic var name          = ""
    @objc dynamic var age: NSNumber = 0
}

class Author: ARMActiveRealm {

    @objc var name          = ""
    @objc var age: NSNumber = 0

    // Relation properties. These properties are just aliases.

    var userSettings: UserSettings? {
        guard let userSettings = relations["userSettings"]?.object as? UserSettings else { return nil }
        return userSettings
    }

    var articles: [Article] {
        guard let articles = relations["articles"]?.objects as? [Article] else { return [] }
        return articles
    }

    override class func definedRelationships() -> [String: ARMRelationship] {
        return [
            "userSettings": ARMRelationship(with: UserSettings.self, type: .hasOne),
            "articles": ARMRelationship(with: Article.self, type: .hasMany)]
    }

    override class func validateBeforeSaving(_ obj: Any) -> Bool {
        let author = obj as! Author

        return !author.name.isEmpty
    }

    override var description: String {
        let dict = dictionaryWithValues(forKeys: [
            "uid",
            "name",
            "age",
            "createdAt",
            "updatedAt"
        ])

        return "\(dict)"
    }
}
