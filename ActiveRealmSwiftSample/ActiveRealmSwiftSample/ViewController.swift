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

        createSample()
        relationSample()
        selectSample()
        destroySample()
        destroyAllSample()
        validationSample()
        conversionSample()
        countSample()
        pluckSample()
        multiThreadSample()
        saveOptionSample()
    }

    func createSample() {
        // Delete all data for sample.
        let realm = RLMRealm.default()
        try! realm.transaction { realm.deleteAllObjects() }

        // Initialize an instance.
        let alice = Author()
        alice.name = "Alice"
        alice.age = 28

        // Insert to Realm DB. `save` means INSERT if the record does not exists in the DB, otherwise UPDATE it.
        alice.save()

        // Update.
        alice.age = 29
        alice.save()

        // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters. NOT save yet.
        let bob = Author.findOrInitialize(["name": "Bob", "age": 55])
        // Insert the object to the DB.
        bob.save()

        // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters and insert it to the DB.
        let chris = Author.findOrCreate(["name": "Chris", "age": 32])
    }

    func relationSample() {
        // Delete all data for sample.
        let realm = RLMRealm.default()
        try! realm.transaction { realm.deleteAllObjects() }

        // Save objects.
        let author       = Author.findOrCreate(["name": "Alice", "age": 28])
        let userSettings = UserSettings.findOrCreate(["authorID": author.uid, "notificationEnabled": true])
        let article1     = Article.findOrCreate(["authorID": author.uid, "title": "Book1", "text": "Book1..."])
        let article2     = Article.findOrCreate(["authorID": author.uid, "title": "Book2", "text": "Book2..."])
        Tag.findOrCreate(["articleID": article1.uid, "name": "Programming"])
        Tag.findOrCreate(["articleID": article1.uid, "name": "iOS"])
        Tag.findOrCreate(["articleID": article2.uid, "name": "Programming"])
        Tag.findOrCreate(["articleID": article2.uid, "name": "iOS"])

        // Relations.
        // One-to-One
        if let settings = author.relations["userSettings"]?.object as? UserSettings {
            print("author.relations['userSettings']: \(settings)")
        }

        // One-to-Many
        if let articles = author.relations["articles"]?.objects as? [Article] {
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
    }

    func selectSample() {
        // Delete all data for sample.
        let realm = RLMRealm.default()
        try! realm.transaction { realm.deleteAllObjects() }

        // Save objects.
        let author1  = Author.findOrCreate(["name": "Alice", "age": 28])
        let author2  = Author.findOrCreate(["name": "Bob", "age": 55])
        let author3  = Author.findOrCreate(["name": "Chris", "age": 32])
        let author4  = Author.findOrCreate(["name": "David", "age": 45])
        let article1 = Article.findOrCreate(["authorID": author1.uid, "title": "Book1", "text": "Book1..."])
        let article2 = Article.findOrCreate(["authorID": author1.uid, "title": "Book2", "text": "Book2..."])
        let article3 = Article.findOrCreate(["authorID": author2.uid, "title": "Book3", "text": "Book3..."])
        Tag.findOrCreate(["articleID": article1.uid, "name": "Computer Science"])
        Tag.findOrCreate(["articleID": article2.uid, "name": "Paper"])
        Tag.findOrCreate(["articleID": article3.uid, "name": "Magazine"])

        // Select all objects.
        var authors = Author.all()
        print("All authors: \(authors)")

        // Select all objects ordered by specified property.
        authors = Author.query.all.order("age", ascending: false).toArray
        print("All authors ordered by age: \(authors)")

        // Retrieve an object at index.
        if let author = Author.query.all[1] as? Author {
            print("Retrieve an author at index: \(author)")
        }

        // Find an object by specified ID.
        if let author = Author.find(ID: author1.uid) {
            print("Find an author by ID: \(author)")
        }

        // Find an object by specified parameters. When multiple objects are found, select first object.
        if let author = Author.find(["name": "Bob"]) {
            print("Find an author by name: \(author)")
        }

        // Select first created object.
        if let tag = Tag.first() {
            print("First tag: \(tag)")
        }

        // Select specified number of objects from the head.
        if let tags = Tag.first(limit: 2) as? [Tag] {
            print("Select tags from the head: \(tags)")
        }

        // Select specified number of objects ordered by specified property from the head.
        if let tags = Tag.query.all.order("name", ascending: false).first(limit: 2) as? [Tag] {
            print("Select tags from the head: \(tags)")
        }

        // Select last created object.
        if let tag = Tag.last() {
            print("Last tag: \(tag)")
        }

        // Select specified number of objects from the tail.
        if let tags = Tag.last(limit: 2) as? [Tag] {
            print("Select tags from the tail: \(tags)")
        }

        // Select specified number of objects ordered by specified property from the tail.
        if let tags = Tag.query.all.order("name", ascending: true).last(limit: 2) as? [Tag] {
            print("Select tags from the tail: \(tags)")
        }

        // Find an object by specified parameters. When multiple objects are found, select last object.
        if let article = Article.findLast(["authorID": author1.uid]) {
            print("Find last article: \(article)")
        }

        // Find multiple objects by specified parameters.
        if let articles = Article.query.where(["authorID": author1.uid]).toArray as? [Article] {
            print("Select articles by author: \(articles)")
        }

        // Find multiple objects by specified parameters. The results are ordered by specified property.
        if let articles = Article.query.where(["authorID": author1.uid]).order("title", ascending: false).toArray as? [Article] {
            print("Select articles by author: \(articles)")
        }

        // Find specified number of objects by specified parameters. The results are ordered by specified property.
        if let articles = Article.query.where(["authorID": author1.uid]).order("title", ascending: false).first(limit: 2) as? [Article] {
            print("Select articles by author: \(articles)")
        }
        if let articles = Article.query.where(["authorID": author1.uid]).order("title", ascending: false).last(limit: 2) as? [Article] {
            print("Select articles by author: \(articles)")
        }

        // Retrieve an object at index.
        if let author = Author.query.all.at(1) {
            print("Author at index: \(author)")
        }
    }

    func destroySample() {
        // Delete all data for sample.
        let realm = RLMRealm.default()
        try! realm.transaction { realm.deleteAllObjects() }

        // Save objects.
        let author1  = Author.findOrCreate(["name": "Alice", "age": 28])
        let author2  = Author.findOrCreate(["name": "Bob", "age": 55])
        let article1 = Article.findOrCreate(["authorID": author1.uid, "title": "Book1", "text": "Book1..."])
        let article2 = Article.findOrCreate(["authorID": author1.uid, "title": "Book2", "text": "Book2..."])
        let article3 = Article.findOrCreate(["authorID": author2.uid, "title": "Book3", "text": "Book3..."])
        Tag.findOrCreate(["articleID": article1.uid, "name": "Computer Science"])
        Tag.findOrCreate(["articleID": article2.uid, "name": "Paper"])
        Tag.findOrCreate(["articleID": article3.uid, "name": "Magazine"])

        print("Authors before destroy: \(Author.all())")
        print("Articles before destroy: \(Article.all())")
        print("Tags before destroy: \(Tag.all())")

        // Cascade delete
        author1.destroy()

        print("Authors after destroy: \(Author.all())")
        print("Articles after destroy: \(Article.all())")
        print("Tags after destroy: \(Tag.all())")

        // Cascade delete by specified parameters.
        Author.destroy(["name": "Bob"])
        print("Authors after destroy: \(Author.all())")
        print("Articles after destroy: \(Article.all())")
        print("Tags after destroy: \(Tag.all())")
    }

    func destroyAllSample() {
        // Delete all data for sample.
        let realm = RLMRealm.default()
        try! realm.transaction { realm.deleteAllObjects() }

        // Save objects.
        let author1 = Author.findOrCreate(["name": "Alice", "age": 28])
        let author2 = Author.findOrCreate(["name": "Bob", "age": 55])
        let author3 = Author.findOrCreate(["name": "Chris", "age": 32])
        let author4 = Author.findOrCreate(["name": "David", "age": 45])
        Article.findOrCreate(["authorID": author1.uid, "title": "Book1", "text": "Book1..."])
        Article.findOrCreate(["authorID": author1.uid, "title": "Book2", "text": "Book2..."])
        Article.findOrCreate(["authorID": author2.uid, "title": "Book3", "text": "Book3..."])

        print("Authors before destroy: \(Author.all())")
        print("Articles before destroy: \(Article.all())")

        // Cascade delete all objects.
        Author.destroyAll()
        print("Authors after destroy: \(Author.all())")
        print("Articles after destroy: \(Article.all())")
    }

    func validationSample() {
        // Delete all data for sample.
        let realm = RLMRealm.default()
        try! realm.transaction { realm.deleteAllObjects() }

        // Failed to save because validation error.
        let article = Article.findOrInitialize(["title": "Programming Guide", "text": "Introduction ..."])
        let success = article.save()

        if Article.find(ID: article.uid) == nil {
            print("Failed to save: \(success)")
        }
    }

    func conversionSample() {
        // Delete all data for sample.
        let realm = RLMRealm.default()
        try! realm.transaction { realm.deleteAllObjects() }

        // Save objects.
        let chris = Author.findOrCreate(["name": "Chris", "age": 32])
        Article.findOrCreate(["authorID": chris.uid, "title": "Book1", "text": "Book1..."])
        Article.findOrCreate(["authorID": chris.uid, "title": "Book2", "text": "Book2..."])

        // Convert to dictionary.
        let dict1 = chris.asDictionary()
        print("author.asDictionary: \(dict1)")

        let dict2 = chris.asDictionary(excepted: ["uid", "createdAt", "updatedAt"])
        print("author.asDictionary: \(dict2)")

        let dict3 = chris.asDictionary(included: ["name", "age", "shortID"])
        print("author.asDictionary: \(dict3)")

        let dict4 = chris.asDictionary(included: ["uid"]) { prop, value in
            if prop == "uid" {
                let uuid = value as! String
                return uuid.split(separator: "-").first!
            }
            return value
        }
        print("author.asDictionary: \(dict4)")

        // The method name is specified by ObjC representation.
        let dict5 = chris.asDictionary(addingPropertiesWith: chris,
                                       methods: ["generation": "generation:"])
        print("author.asDictionary: \(dict5)")

        // The method name is specified by ObjC representation.
        let dict6 = chris.asDictionary(excepted: ["uid", "createdAt", "updatedAt", "age"],
                                       addingPropertiesWith: chris,
                                       methods: ["generation": "generation:", "works": "works:"])
        print("author.asDictionary: \(dict6)")

        // Convert to JSON.
        let json1 = chris.asJSONString()
        print("author.asJSON: \(json1)")

        let json2 = chris.asJSONString(excepted: ["uid", "createdAt", "updatedAt"])
        print("author.asJSON: \(json2)")

        let json3 = chris.asJSONString(included: ["name", "age", "shortID"])
        print("author.asJSON: \(json3)")

        let json4 = chris.asJSONString(included: ["uid"]) { prop, value in
            if prop == "uid" {
                let uuid = value as! String
                return uuid.split(separator: "-").first!
            }
            return value
        }
        print("author.asJSON: \(json4)")

        // The method name is specified by ObjC representation.
        let json5 = chris.asJSONString(addingPropertiesWith: chris,
                                       methods: ["generation": "generation:"])
        print("author.asJSON: \(json5)")

        // The method name is specified by ObjC representation.
        let json6 = chris.asJSONString(excepted: ["uid", "createdAt", "updatedAt", "age"],
                                       addingPropertiesWith: chris,
                                       methods: ["generation": "generation:", "works": "works:"])
        print("author.asJSON: \(json6)")
    }

    func countSample() {
        // Delete all data for sample.
        let realm = RLMRealm.default()
        try! realm.transaction { realm.deleteAllObjects() }

        // Save objects.
        let author1 = Author.findOrCreate(["name": "Alice", "age": 28])
        let author2 = Author.findOrCreate(["name": "Bob", "age": 55])
        let author3 = Author.findOrCreate(["name": "Chris", "age": 32])
        let author4 = Author.findOrCreate(["name": "David", "age": 45])

        // Count objects.
        print("The number of authors: \(Author.count)")
        print("The number of authors called David: \(Author.query.where(["name": "David"]).count)")
        print("The number of authors over 40: \(Author.query.where(predicate: NSPredicate(format: "age >= %d", 40)).count)")
    }

    func pluckSample() {
        // Delete all data for sample.
        let realm = RLMRealm.default()
        try! realm.transaction { realm.deleteAllObjects() }

        // Save objects.
        let author1 = Author.findOrCreate(["name": "Alice", "age": 28])
        let author2 = Author.findOrCreate(["name": "Bob", "age": 55])
        let author3 = Author.findOrCreate(["name": "Chris", "age": 32])
        let author4 = Author.findOrCreate(["name": "David", "age": 45])

        let results1 = Author.query.all.pluck(["name"])
        print("Pluck author names: \(results1)")

        let results2 = Author.query.all.pluck(["name", "age"])
        print("Pluck author status: \(results2)")

        let results3 = Author.query.where(predicate: NSPredicate(format: "age < %d", 40)).pluck(["name"])
        print("Pluck author names under 40: \(results3)")
    }

    func multiThreadSample() {
        // Delete all data for sample.
        let realm = RLMRealm.default()
        try! realm.transaction { realm.deleteAllObjects() }

        let author = Author.findOrCreate(["name": "Alice", "age": 28])

        // An ActiveRealm object can be used on multi-threads.
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 2.0) {
            author.age = 29
            author.save()

            DispatchQueue.main.async {
                if let author = Author.find(with: NSPredicate(format: "name=%@", "Alice")) {
                    print("author: \(author)")
                }
            }
        }
    }

    func saveOptionSample() {
        let author = Author.findOrCreate(["name": "Yamada", "age": 35])
        print("before save: \(author)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            author.age = 36
            author.save(options: [.notAutomaticallyUpdateTimestamp])
            print("after save: \(author)")
        }
    }
}
