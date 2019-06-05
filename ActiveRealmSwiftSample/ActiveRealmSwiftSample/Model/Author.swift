//
// Created by Masaki Ando on 2019-06-04.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

import Foundation

import ActiveRealm

class ActiveRealmAuthor: ARMObject {

    @objc dynamic var articleID     = ""
    @objc dynamic var name          = ""
    @objc dynamic var age: NSNumber = 0
}

class Author: ARMActiveRealm {

    @objc var articleID     = ""
    @objc var name          = ""
    @objc var age: NSNumber = 0
    @objc var country       = ""

    var article: Article {
        return relations["article"]?.object as! Article
    }

    override class func ignoredProperties() -> [String] {
        return ["country"]
    }

    override class func definedRelationships() -> [String: ARMRelationship] {
        return ["article": ARMInverseRelationship(with: Article.self, type: .belongsTo)]
    }

    override class func validateBeforeSaving(_ obj: Any) -> Bool {
        let author = obj as! Author

        return !author.articleID.isEmpty && !author.name.isEmpty
    }

    override var description: String {
        let dict = dictionaryWithValues(forKeys: [
            "uid",
            "articleID",
            "name",
            "age",
            "createdAt",
            "updatedAt"
        ])

        return "\(dict)"
    }
}
