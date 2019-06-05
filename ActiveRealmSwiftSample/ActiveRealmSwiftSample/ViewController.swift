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

        // Setup ActiveRealm.
        let configuration = RLMRealmConfiguration.default()
        configuration.inMemoryIdentifier = "Sample"
        RLMRealmConfiguration.setDefault(configuration)
        ARMActiveRealmManager.shared().realm = RLMRealm.default()

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

        // Failed to save because validation error.
        let invalidArticle = Article.findOrInitialize(["title": "Programming Guide",
                                                       "text": "Introduction ..."])
        let success        = invalidArticle.save()

        if Article.find(ID: invalidArticle.uid) == nil {
            print("success: \(success)")
        }
    }
}
