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

    // A property ignored by ActiveRealm.

    @objc var shortID: String {
        return String(uid.split(separator: "-").first!)
    }

    override class func ignoredProperties() -> [String] {
        return ["shortID"]
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
        return asJSONString()
    }
}

extension Author {

    @objc func generation(_ obj: Author) -> NSNumber {
        return NSNumber(integerLiteral: Int(age.doubleValue / 10.0) * 10)
    }

    @objc func works(_ obj: Author) -> [String] {
        return articles.map { article -> String in article.asJSONString() }
    }
}
