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

        // Setup ActiveRealm
        let configuration = RLMRealmConfiguration.default()
        configuration.inMemoryIdentifier = "Sample"
        RLMRealmConfiguration.setDefault(configuration)
        ARMActiveRealmManager.shared().realm = RLMRealm.default()

        // Initialize an instance.
        let article1 = Article()
        article1.title = "ActiveRealm"
        article1.text = "ActiveRealm is a library for iOS."

        // Insert to Realm DB. `save` means INSERT if the record does not exists in the DB, otherwise UPDATE it.
        article1.save()

        // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters.
        let author1 = Author.findOrInitialize(["articleID": article1.uid, "name": "Alice", "age": 28])
        author1.save()

        // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters and insert it to the DB.
        let tag1 = Tag.findOrCreate(["articleID": article1.uid, "name": "Programming"])
        let tag2 = Tag.findOrCreate(["articleID": article1.uid, "name": "iOS"])

        // Relations.
        if let author = article1.relations["author"]?.object as? Author {
            print("article.relations['author']: \(author)")
        }
        if let tags = article1.relations["tags"]?.objects as? [Tag] {
            print("article.relations['tags']: \(tags)")
        }
        if let article = author1.relations["article"]?.object as? Article {
            print("author.relations['article']: \(article)")
        }
        if let article = tag1.relations["article"]?.object as? Article {
            print("tag.relations['article']: \(article)")
        }
        if let article = tag2.relations["article"]?.object as? Article {
            print("tag.relations['article']: \(article)")
        }

        // Update.
        article1.revision = 1
        article1.save()

        let article2 = Article.findOrCreate(["title": "Computer Science Vol.1",
                                             "text": "The programming is ...",
                                             "revision": 0])
        Author.findOrCreate(["articleID": article2.uid, "name": "Bob", "age": 55])
        Tag.findOrCreate(["articleID": article2.uid, "name": "Computer Science"])
        Tag.findOrCreate(["articleID": article2.uid, "name": "Paper"])

        // Select all objects.
        let articles = Article.all()
        print("Article.all: \(articles)")

        // Select all objects ordered by specified property.
        let authors = Author.all(orderedBy: "age", ascending: false)
        print("Author.all(orderedBy:): \(authors)")

        // Find an object by specified ID.
        if let author = Author.find(ID: author1.uid) {
            print("Author.find(ID:): \(author)")
        }

        // Find an object by specified parameters. When multiple objects are found, select first object.
        if let author = Author.find(["name": "Bob"]) {
            print("Author.find: \(author)")
        }

        // Select first object.
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

        // Select last object.
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

        if let article = Article.find(ID: article1.uid) {
            print("Article.find(ID:): \(article)")
        }
        if let authors = Author.where(["articleID": article1.uid]) as? [Author] {
            print("Author.where: \(authors)")
        }
        if let tags = Tag.where(["articleID": article1.uid]) as? [Tag] {
            print("Tag.where: \(tags)")
        }

        // Cascade delete.
        article1.destroy()
        if let article = Article.find(ID: article1.uid) {
            print("Article.find(ID:): \(article)")
        }
        if let authors = Author.where(["articleID": article1.uid]) as? [Author] {
            print("Author.where: \(authors)")
        }
        if let tags = Tag.where(["articleID": article1.uid]) as? [Tag] {
            print("Tag.where: \(tags)")
        }

        // Cascade delete by specified parameters.
        Article.destroy(["title": "Computer Science Vol.1", "revision": 0])
        if let articles = Article.all() as? [Article] {
            print("Article.all: \(articles)")
        }
        if let authors = Author.all() as? [Author] {
            print("Author.all: \(authors)")
        }
        if let tags = Tag.all() as? [Tag] {
            print("Tag.all: \(tags)")
        }

        // Failed to save because validation error.
        let article3 = Article.findOrInitialize(["title": "Programming Guide"])
        let success  = article3.save()

        if Article.find(ID: article3.uid) == nil {
            print("success: \(success)")
        }
    }
}
