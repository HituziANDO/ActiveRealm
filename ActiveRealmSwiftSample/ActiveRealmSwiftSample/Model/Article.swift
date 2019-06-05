//
// Created by Masaki Ando on 2019-06-04.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

import Foundation

import ActiveRealm

class ActiveRealmArticle: ARMObject {

    @objc dynamic var title              = ""
    @objc dynamic var text               = ""
    @objc dynamic var revision: NSNumber = 0
}

class Article: ARMActiveRealm {

    @objc var title              = ""
    @objc var text               = ""
    @objc var revision: NSNumber = 0

    var author: Author? {
        guard let author = relations["author"]?.object as? Author else { return nil }
        return author
    }

    var tags: [Tag] {
        guard let tags = relations["tags"]?.objects as? [Tag] else { return [] }
        return tags
    }

    override class func definedRelationships() -> [String: ARMRelationship] {
        return ["author": ARMRelationship(with: Author.self, type: .hasOne),
                "tags": ARMRelationship(with: Tag.self, type: .hasMany)]
    }

    override class func validateBeforeSaving(_ obj: Any) -> Bool {
        let article = obj as! Article

        return !article.title.isEmpty && !article.text.isEmpty
    }

    override var description: String {
        let dict = dictionaryWithValues(forKeys: [
            "uid",
            "title",
            "text",
            "revision",
            "createdAt",
            "updatedAt"
        ])

        return "\(dict)"
    }
}
