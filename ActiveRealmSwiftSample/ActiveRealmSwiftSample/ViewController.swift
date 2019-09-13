//
//  ViewController.swift
//  ActiveRealmSwiftSample
//
//  Created by Masaki Ando on 2019/06/04.
//  Copyright © 2019 Hituzi Ando. All rights reserved.
//

import UIKit

import ActiveRealm

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure your Realm configuration as default Realm.
        let configuration = RLMRealmConfiguration.default()
        // Something to do
        RLMRealmConfiguration.setDefault(configuration)

        // Delete all data for sample.
        let realm = RLMRealm.default()
        try! realm.transaction { realm.deleteAllObjects() }

        // Initialize an instance.
        let alice = Author()
        alice.name = "Alice"
        alice.age = 28

        // Insert to Realm DB. `save` means INSERT if the record does not exists in the DB, otherwise UPDATE it.
        alice.save()

        // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters. NOT save yet.
        let userSettings = UserSettings.findOrInitialize(["authorID": alice.uid, "notificationEnabled": true])
        userSettings.save()

        // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters and insert it to the DB.
        let article1 = Article.findOrCreate(["authorID": alice.uid,
                                             "title": "ActiveRealm User Guide",
                                             "text": "ActiveRealm is a library for iOS.",
                                             "revision": 0])
        let article2 = Article.findOrCreate(["authorID": alice.uid,
                                             "title": "ActiveRealm API Reference",
                                             "text": "ActiveRealm API (Swift).",
                                             "revision": 0])
        Tag.findOrCreate(["articleID": article1.uid, "name": "Programming"])
        Tag.findOrCreate(["articleID": article1.uid, "name": "iOS"])
        Tag.findOrCreate(["articleID": article2.uid, "name": "Programming"])
        Tag.findOrCreate(["articleID": article2.uid, "name": "iOS"])

        // Relations.
        // One-to-One
        if let settings = alice.relations["userSettings"]?.object as? UserSettings {
            print("author.relations['userSettings']: \(settings)")
        }
        // One-to-Many
        if let articles = alice.relations["articles"]?.objects as? [Article] {
            print("author.relations['articles']: \(articles)")

            let article = articles.first!

            if let tags = article.relations["tags"]?.objects as? [Tag] {
                print("article.relations['tags']: \(tags)")
            }

            // Inverse relationship
            if let author = article.relations["author"]?.object as? Author {
                print("article.relations['author']: \(author)")
            }

            let tag = Tag.findOrCreate(["articleID": article.uid, "name": "Realm"])

            if let author = tag.relations["article"]?.object?.relations["author"]?.object as? Author {
                print("tag.relations['article']['author']: \(author)")
            }
        }

        // Update.
        article1.revision = 1
        article1.save()

        let bob         = Author.findOrCreate(["name": "Bob", "age": 55])
        let bobsArticle = Article.findOrCreate(["authorID": bob.uid,
                                                "title": "Computer Science Vol.1",
                                                "text": "The programming is ...",
                                                "revision": 0])
        Tag.findOrCreate(["articleID": bobsArticle.uid, "name": "Computer Science"])
        Tag.findOrCreate(["articleID": bobsArticle.uid, "name": "Paper"])

        // Select all objects.
        var authors = Author.all()
        print("Author.all: \(authors)")

        // Select all objects ordered by specified property.
        authors = Author.all(orderedBy: "age", ascending: false)
        print("Author.all(orderedBy:): \(authors)")

        // Find an object by specified ID.
        if let author = Author.find(ID: alice.uid) {
            print("Author.find(ID:): \(author)")
        }

        // Find an object by specified parameters. When multiple objects are found, select first object.
        if let author = Author.find(["name": "Bob"]) {
            print("Author.find: \(author)")
        }

        // Select first created object.
        if let tag = Tag.first() {
            print("Tag.first: \(tag)")
        }

        // Select specified number of objects from the head.
        if let tags = Tag.first(limit: 2) as? [Tag] {
            print("Tag.first(limit:): \(tags)")
        }

        // Select specified number of objects ordered by specified property from the head.
        if let tags = Tag.first(orderedBy: "name", ascending: false, limit: 2) as? [Tag] {
            print("Tag.first(orderedBy:): \(tags)")
        }

        // Select last created object.
        if let tag = Tag.last() {
            print("Tag.last: \(tag)")
        }

        // Select specified number of objects from the tail.
        if let tags = Tag.last(limit: 2) as? [Tag] {
            print("Tag.last(limit:): \(tags)")
        }

        // Select specified number of objects ordered by specified property from the tail.
        if let tags = Tag.last(orderedBy: "name", ascending: true, limit: 2) as? [Tag] {
            print("Tag.last(orderedBy:): \(tags)")
        }

        // Find an object by specified parameters. When multiple objects are found, select last object.
        if let tag = Tag.findLast(["articleID": article1.uid]) {
            print("Tag.findLast: \(tag)")
        }

        // Find multiple objects by specified parameters.
        if let tags = Tag.where(["articleID": article1.uid]) as? [Tag] {
            print("Tag.where: \(tags)")
        }

        // Find multiple objects by specified parameters. The results are ordered by specified property.
        if let tags = Tag.where(["articleID": article1.uid], orderedBy: "name", ascending: true) as? [Tag] {
            print("Tag.where(orderedBy:): \(tags)")
        }

        // Find specified number of objects by specified parameters. The results are ordered by specified property.
        if let tags = Tag.where(["articleID": article1.uid], orderedBy: "name", ascending: false, limit: 1) as? [Tag] {
            print("Tag.where(orderedBy:): \(tags)")
        }

        // Cascade delete.
        alice.destroy()
        if let authors = Author.all() as? [Author] {
            print("Author.all: \(authors)")
        }
        if let userSettings = UserSettings.all() as? [UserSettings] {
            print("UserSettings.all: \(userSettings)")
        }
        if let articles = Article.all() as? [Article] {
            print("Article.all: \(articles)")
        }
        if let tags = Tag.all() as? [Tag] {
            print("Tag.all: \(tags)")
        }

        // Cascade delete by specified parameters.
        Article.destroy(["title": "Computer Science Vol.1", "revision": 0])
        if let authors = Author.all() as? [Author] {
            print("Author.all: \(authors)")
        }
        if let userSettings = UserSettings.all() as? [UserSettings] {
            print("UserSettings.all: \(userSettings)")
        }
        if let articles = Article.all() as? [Article] {
            print("Article.all: \(articles)")
        }
        if let tags = Tag.all() as? [Tag] {
            print("Tag.all: \(tags)")
        }

        for i in 0..<100 {
            Author.findOrCreate(["name": "Author\(i)", "age": 30])
        }

        // Cascade delete all objects.
        Author.destroyAll()
        print("Author.all: \(Author.all())")

        // Failed to save because validation error.
        let invalidArticle = Article.findOrInitialize(["title": "Programming Guide",
                                                       "text": "Introduction ..."])
        let success        = invalidArticle.save()

        if Article.find(ID: invalidArticle.uid) == nil {
            print("success: \(success)")
        }

        let chris = Author.findOrCreate(["name": "Chris", "age": 32])
        Article.findOrCreate(["authorID": chris.uid, "title": "Book1", "text": "Book1..."])
        Article.findOrCreate(["authorID": chris.uid, "title": "Book2", "text": "Book2..."])

        // Convert to dictionary.
        print("author.asDictionary: \(chris.asDictionary())")
        print("author.asDictionary: \(chris.asDictionary(excepted: ["uid", "createdAt", "updatedAt"]))")
        print("author.asDictionary: \(chris.asDictionary(included: ["name", "age", "shortID"]))")
        let dictionary1 = chris.asDictionary(included: ["uid"]) { prop, value in
            if prop == "uid" {
                let uuid = value as! String
                return uuid.split(separator: "-").first!
            }
            return value
        }
        print("author.asDictionary: \(dictionary1)")
        let dictionary2 = chris.asDictionary(addingPropertiesWith: chris,
                                             methods: ["generation": "generation:"])    // The method name is specified by ObjC representation.
        print("author.asDictionary: \(dictionary2)")
        let dictionary3 = chris.asDictionary(excepted: ["uid", "createdAt", "updatedAt", "age"],
                                             addingPropertiesWith: chris,
                                             methods: ["generation": "generation:", "works": "works:"])   // The method name is specified by ObjC representation.
        print("author.asDictionary: \(dictionary3)")

        // Convert to JSON.
        print("author.asJSON: \(chris.asJSONString())")
        print("author.asJSON: \(chris.asJSONString(excepted: ["uid", "createdAt", "updatedAt"]))")
        print("author.asJSON: \(chris.asJSONString(included: ["name", "age", "shortID"]))")
        let json1 = chris.asJSONString(included: ["uid"]) { prop, value in
            if prop == "uid" {
                let uuid = value as! String
                return uuid.split(separator: "-").first!
            }
            return value
        }
        print("author.asJSON: \(json1)")
        let json2 = chris.asJSONString(addingPropertiesWith: chris,
                                       methods: ["generation": "generation:"])  // The method name is specified by ObjC representation.
        print("author.asJSON: \(json2)")
        let json3 = chris.asJSONString(excepted: ["uid", "createdAt", "updatedAt", "age"],
                                       addingPropertiesWith: chris,
                                       methods: ["generation": "generation:", "works": "works:"]) // The method name is specified by ObjC representation.
        print("author.asJSON: \(json3)")

        let david = Author()
        david.name = "David"
        david.age = 45
        david.save()

        // Count objects.
        print("Author.count: \(Author.count())")
        print("Author.count(where:): \(Author.count(where: ["name": "David"]))")
        print("Author.count(predicate:): \(Author.count(predicate: NSPredicate(format: "age > %d", 40)))")

        // An ActiveRealm object can be used on multi-threads.
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 2.0) {
            david.age = 46
            david.save()

            DispatchQueue.main.async {
                if let author = Author.find(with: NSPredicate(format: "name=%@", "David")) {
                    print("author: \(author)")
                }
            }
        }
    }
}
