//
// Created by Masaki Ando on 2019-06-04.
// Copyright (c) 2019 Hituzi Ando. All rights reserved.
//

import Foundation

import ActiveRealm

class ActiveRealmTag: ARMObject {

    @objc dynamic var articleID = ""
    @objc dynamic var name      = ""
}

class Tag: ARMActiveRealm {

    @objc var articleID = ""
    @objc var name      = ""

    // A relation property. This property is just alias.

    var article: Article {
        return relations["article"]?.object as! Article
    }

    override class func definedRelationships() -> [String: ARMRelationship] {
        return ["article": ARMInverseRelationship(with: Article.self, type: .belongsTo)]
    }

    override class func validateBeforeSaving(_ obj: Any) -> Bool {
        let tag = obj as! Tag

        return !tag.articleID.isEmpty && !tag.name.isEmpty
    }

    override var description: String {
        return asJSONString()
    }
}
