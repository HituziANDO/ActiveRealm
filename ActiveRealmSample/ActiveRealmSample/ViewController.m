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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setup ActiveRealm
    RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
    configuration.inMemoryIdentifier = @"Sample";
    [RLMRealmConfiguration setDefaultConfiguration:configuration];
    ARMActiveRealmManager.sharedInstance.realm = [RLMRealm defaultRealm];

    // Initialize an instance.
    Article *article1 = [Article new];
    article1.title = @"ActiveRealm";
    article1.text = @"ActiveRealm is a library for iOS.";

    // Insert to Realm DB. `save` means INSERT if the record does not exists in the DB, otherwise UPDATE it.
    [article1 save];

    // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters.
    Author *author1 = [Author findOrInitialize:@{ @"articleID": article1.uid, @"name": @"Alice", @"age": @28 }];
    [author1 save];

    // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters and insert it to the DB.
    Tag *tag1 = [Tag findOrCreate:@{ @"articleID": article1.uid, @"name": @"Programming" }];
    Tag *tag2 = [Tag findOrCreate:@{ @"articleID": article1.uid, @"name": @"iOS" }];

    // Relations.
    Author *author = (Author *) article1.relations[@"author"].object;
    NSArray<Tag *> *tags = (NSArray<Tag *> *) article1.relations[@"tags"].objects;
    NSLog(@"article.relations['author']: %@", author);
    NSLog(@"article.relations['tags']: %@", tags);

    // Update.
    article1.revision = @1;
    [article1 save];

    Article *article2 = [Article findOrCreate:@{ @"title": @"Computer Science Vol.1", @"text": @"The programming is ...", @"revision": @0 }];
    [Author findOrCreate:@{ @"articleID": article2.uid, @"name": @"Bob", @"age": @55 }];
    [Tag findOrCreate:@{ @"articleID": article2.uid, @"name": @"Computer Science" }];

    // Select all objects.
    NSArray<Article *> *articles = Article.all;
    NSLog(@"Article.all: %@", articles);

    // Find an object by specified ID.
    author = [Author findByID:author1.uid];
    NSLog(@"Author.findByID: %@", author);

    // Find an object by specified parameters. When multiple objects are found, select first object.
    author = [Author find:@{ @"name": @"Bob" }];
    NSLog(@"Author.find: %@", author);

    // Select first object.
    Tag *tag = Tag.first;
    NSLog(@"Tag.first: %@", tag);

    // Select last object.
    tag = Tag.last;
    NSLog(@"Tag.last: %@", tag);

    // Find an object by specified parameters. When multiple objects are found, select last object.
    tag = [Tag findLast:@{ @"articleID": article1.uid }];
    NSLog(@"Tag.findLast: %@", tag);

    // Find multiple objects by specified parameters.
    tags = [Tag where:@{ @"articleID": article1.uid }];
    NSLog(@"Tag.where: %@", tags);

    NSLog(@"Article.findByID: %@", [Article findByID:article1.uid]);
    NSLog(@"Author.where: %@", [Author where:@{ @"articleID": article1.uid }]);
    NSLog(@"Tag.where: %@", [Tag where:@{ @"articleID": article1.uid }]);

    // Cascade delete.
    [article1 destroy];
    NSLog(@"Article.findByID: %@", [Article findByID:article1.uid]);
    NSLog(@"Author.where: %@", [Author where:@{ @"articleID": article1.uid }]);
    NSLog(@"Tag.where: %@", [Tag where:@{ @"articleID": article1.uid }]);

    // Cascade delete by specified parameters.
    [Article destroy:@{ @"title": @"Computer Science Vol.1", @"revision": @0 }];
    NSLog(@"Article.all: %@", Article.all);
    NSLog(@"Author.all: %@", Author.all);
    NSLog(@"Tag.all: %@", Tag.all);
}

@end
