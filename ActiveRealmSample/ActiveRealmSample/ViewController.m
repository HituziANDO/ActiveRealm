//
//  ViewController.m
//  ActiveRealmSample
//
//  Created by Masaki Ando on 2019/05/30.
//  Copyright © 2019 Hituzi Ando. All rights reserved.
//

#import <ActiveRealm/ActiveRealm.h>

#import "ViewController.h"

#import "Article.h"
#import "Author.h"
#import "Tag.h"
#import "UserSettings.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setup ActiveRealm.
    RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
    configuration.inMemoryIdentifier = @"Sample";
    [RLMRealmConfiguration setDefaultConfiguration:configuration];
    ARMActiveRealmManager.sharedInstance.realm = [RLMRealm defaultRealm];

    // Initialize an instance.
    Author *alice = [Author new];
    alice.name = @"Alice";
    alice.age = @28;

    // Insert to Realm DB. `save` means INSERT if the record does not exists in the DB, otherwise UPDATE it.
    [alice save];

    // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters. NOT save yet.
    UserSettings *userSettings = [UserSettings findOrInitialize:@{ @"authorID": alice.uid,
                                                                   @"notificationEnabled": @YES }];
    [userSettings save];

    // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters and insert it to the DB.
    Article *article1 = [Article findOrCreate:@{ @"authorID": alice.uid,
                                                 @"title": @"ActiveRealm User Guide",
                                                 @"text": @"ActiveRealm is a library for iOS.",
                                                 @"revision": @0 }];
    Article *article2 = [Article findOrCreate:@{ @"authorID": alice.uid,
                                                 @"title": @"ActiveRealm API Reference",
                                                 @"text": @"ActiveRealm API (Objective-C).",
                                                 @"revision": @0 }];
    [Tag findOrCreate:@{ @"articleID": article1.uid, @"name": @"Programming" }];
    [Tag findOrCreate:@{ @"articleID": article1.uid, @"name": @"iOS" }];
    [Tag findOrCreate:@{ @"articleID": article2.uid, @"name": @"Programming" }];
    [Tag findOrCreate:@{ @"articleID": article2.uid, @"name": @"iOS" }];

    // Relations.
    // One-to-One
    UserSettings *settings = alice.relations[@"userSettings"].object;
    NSLog(@"author.relations['userSettings']: %@", settings);

    // One-to-Many
    NSArray<Article *> *articles = alice.relations[@"articles"].objects;
    NSLog(@"author.relations['articles']: %@", articles);

    Article *article = articles.firstObject;
    NSArray<Tag *> *tags = article.relations[@"tags"].objects;
    NSLog(@"article.relations['tags']: %@", tags);

    // Inverse relationship
    Author *author = article.relations[@"author"].object;
    NSLog(@"article.relations['author']: %@", author);

    Tag *tag = [Tag findOrCreate:@{ @"articleID": article.uid, @"name": @"Realm" }];
    NSLog(@"tag.relations['article']['author']: %@", tag.relations[@"article"].object.relations[@"author"].object);

    // Update.
    article1.revision = @1;
    [article1 save];

    Author *bob = [Author findOrCreate:@{ @"name": @"Bob", @"age": @55 }];
    Article *bobsArticle = [Article findOrCreate:@{ @"authorID": bob.uid,
                                                    @"title": @"Computer Science Vol.1",
                                                    @"text": @"The programming is ...",
                                                    @"revision": @0 }];
    [Tag findOrCreate:@{ @"articleID": bobsArticle.uid, @"name": @"Computer Science" }];
    [Tag findOrCreate:@{ @"articleID": bobsArticle.uid, @"name": @"Paper" }];

    // Select all objects.
    NSArray<Author *> *authors = Author.all;
    NSLog(@"Author.all: %@", authors);

    // Select all objects ordered by specified property.
    authors = [Author allOrderedBy:@"age" ascending:NO];
    NSLog(@"Author.allOrderedBy: %@", authors);

    // Find an object by specified ID.
    author = [Author findByID:alice.uid];
    NSLog(@"Author.findByID: %@", author);

    // Find an object by specified parameters. When multiple objects are found, select first object.
    author = [Author find:@{ @"name": @"Bob" }];
    NSLog(@"Author.find: %@", author);

    // Select first created object.
    tag = Tag.first;
    NSLog(@"Tag.first: %@", tag);

    // Select specified number of objects from the head.
    tags = [Tag firstWithLimit:2];
    NSLog(@"Tag.firstWithLimit: %@", tags);

    // Select specified number of objects ordered by specified property from the head.
    tags = [Tag firstOrderedBy:@"name" ascending:NO limit:2];
    NSLog(@"Tag.firstOrderedBy: %@", tags);

    // Select last created object.
    tag = Tag.last;
    NSLog(@"Tag.last: %@", tag);

    // Select specified number of objects from the tail.
    tags = [Tag lastWithLimit:2];
    NSLog(@"Tag.lastWithLimit: %@", tags);

    // Select specified number of objects ordered by specified property from the tail.
    tags = [Tag lastOrderedBy:@"name" ascending:YES limit:2];
    NSLog(@"Tag.lastOrderedBy: %@", tags);

    // Find an object by specified parameters. When multiple objects are found, select last object.
    tag = [Tag findLast:@{ @"articleID": article1.uid }];
    NSLog(@"Tag.findLast: %@", tag);

    // Find multiple objects by specified parameters.
    tags = [Tag where:@{ @"articleID": article1.uid }];
    NSLog(@"Tag.where: %@", tags);

    // Find multiple objects by specified parameters. The results are ordered by specified property.
    tags = [Tag where:@{ @"articleID": article1.uid }
            orderedBy:@"name"
            ascending:YES];
    NSLog(@"Tag.whereOrderedBy: %@", tags);

    tags = [Tag where:@{ @"articleID": article1.uid }
            orderedBy:@"name"
            ascending:NO
                limit:1];
    NSLog(@"Tag.whereOrderedBy: %@", tags);

    // Cascade delete.
    [alice destroy];
    NSLog(@"Author.all: %@", Author.all);
    NSLog(@"UserSettings.all: %@", UserSettings.all);
    NSLog(@"Article.all: %@", Article.all);
    NSLog(@"Tag.all: %@", Tag.all);

    // Cascade delete by specified parameters.
    [Article destroy:@{ @"title": @"Computer Science Vol.1", @"revision": @0 }];
    NSLog(@"Author.all: %@", Author.all);
    NSLog(@"UserSettings.all: %@", UserSettings.all);
    NSLog(@"Article.all: %@", Article.all);
    NSLog(@"Tag.all: %@", Tag.all);

    // Failed to save because validation error.
    Article *invalidArticle = [Article findOrInitialize:@{ @"title": @"Programming Guide", @"text": @"Introduction ..." }];
    BOOL success = [invalidArticle save];
    NSLog(@"success: %d article: %@", success, [Article findByID:invalidArticle.uid]);

    Author *chris = [Author findOrCreate:@{ @"name": @"Chris", @"age": @32 }];
    [Article findOrCreate:@{ @"authorID": chris.uid, @"title": @"Book1", @"text": @"Book1..." }];
    [Article findOrCreate:@{ @"authorID": chris.uid, @"title": @"Book2", @"text": @"Book2..." }];

    // Convert to dictionary.
    NSLog(@"author.asDictionary: %@", chris.asDictionary);
    NSLog(@"author.asDictionary: %@", [chris asDictionaryExceptingProperties:@[ @"uid", @"createdAt", @"updatedAt" ]]);
    NSLog(@"author.asDictionary: %@", [chris asDictionaryIncludingProperties:@[ @"name", @"age", @"shortUID" ]]);
    NSLog(@"author.asDictionary: %@", [chris asDictionaryIncludingProperties:@[ @"uid" ]
                                                                       block:^id(NSString *prop, id value) {
                                                                           if ([prop isEqualToString:@"uid"]) {
                                                                               return [((NSString *) value) componentsSeparatedByString:@"-"].firstObject;
                                                                           }
                                                                           return value;
                                                                       }]);
    NSLog(@"author.asDictionary: %@", [chris asDictionaryAddingPropertiesWithTarget:chris
                                                                            methods:@{ @"generation": @"generation:" }]);
    NSLog(@"author.asDictionary: %@", [chris asDictionaryExceptingProperties:@[ @"uid",
                                                                                @"createdAt",
                                                                                @"updatedAt",
                                                                                @"age" ]
                                                  addingPropertiesWithTarget:chris
                                                                     methods:@{ @"generation": @"generation:",
                                                                                @"works": @"works:" }]);

    // Convert to JSON.
    NSLog(@"author.asJSON: %@", chris.asJSONString);
    NSLog(@"author.asJSON: %@", [chris asJSONStringExceptingProperties:@[ @"uid", @"createdAt", @"updatedAt" ]]);
    NSLog(@"author.asJSON: %@", [chris asJSONStringIncludingProperties:@[ @"name", @"age", @"shortUID" ]]);
    NSLog(@"author.asJSON: %@", [chris asJSONStringIncludingProperties:@[ @"uid" ]
                                                                 block:^id(NSString *prop, id value) {
                                                                     if ([prop isEqualToString:@"uid"]) {
                                                                         return [((NSString *) value) componentsSeparatedByString:@"-"].firstObject;
                                                                     }
                                                                     return value;
                                                                 }]);
    NSLog(@"author.asJSON: %@", [chris asJSONStringExceptingProperties:@[ @"uid",
                                                                          @"createdAt",
                                                                          @"updatedAt",
                                                                          @"age" ]
                                            addingPropertiesWithTarget:chris
                                                               methods:@{ @"generation": @"generation:",
                                                                          @"works": @"works:" }]);
}

@end
