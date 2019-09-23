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

    // Configure your Realm configuration as default Realm.
    RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
    // Something to do
    [RLMRealmConfiguration setDefaultConfiguration:configuration];

    [self createSample];
    [self relationSample];
    [self selectSample];
    [self destroySample];
    [self destroyAllSample];
    [self validationSample];
    [self conversionSample];
    [self countSample];
    [self pluckSample];
    [self multiThreadSample];
}

- (void)createSample {
    // Delete all data for sample.
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteAllObjects];
    }];

    // Initialize an instance.
    Author *alice = [Author new];
    alice.name = @"Alice";
    alice.age = @28;

    // Insert to Realm DB. `save` means INSERT if the record does not exists in the DB, otherwise UPDATE it.
    [alice save];

    // Update.
    alice.age = @29;
    [alice save];

    // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters. NOT save yet.
    Author *bob = [Author findOrInitialize:@{ @"name": @"Bob", @"age": @55 }];
    // Insert the object to the DB.
    [bob save];

    // Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters and insert it to the DB.
    Author *chris = [Author findOrCreate:@{ @"name": @"Chris", @"age": @32 }];
}

- (void)relationSample {
    // Delete all data for sample.
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteAllObjects];
    }];

    // Save objects.
    Author *author = [Author findOrCreate:@{ @"name": @"Alice", @"age": @28 }];
    UserSettings *userSettings = [UserSettings findOrCreate:@{ @"authorID": author.uid, @"notificationEnabled": @YES }];
    Article *article1 = [Article findOrCreate:@{ @"authorID": author.uid, @"title": @"Book1", @"text": @"Book1..." }];
    Article *article2 = [Article findOrCreate:@{ @"authorID": author.uid, @"title": @"Book2", @"text": @"Book2..." }];
    [Tag findOrCreate:@{ @"articleID": article1.uid, @"name": @"Programming" }];
    [Tag findOrCreate:@{ @"articleID": article1.uid, @"name": @"iOS" }];
    [Tag findOrCreate:@{ @"articleID": article2.uid, @"name": @"Programming" }];
    [Tag findOrCreate:@{ @"articleID": article2.uid, @"name": @"iOS" }];

    // Relations.
    // One-to-One
    UserSettings *settings = author.relations[@"userSettings"].object;
    NSLog(@"author.relations['userSettings']: %@", settings);

    // One-to-Many
    NSArray<Article *> *articles = author.relations[@"articles"].objects;
    NSLog(@"author.relations['articles']: %@", articles);

    Article *article = articles.firstObject;
    NSArray<Tag *> *tags = article.relations[@"tags"].objects;
    NSLog(@"article.relations['tags']: %@", tags);

    // Inverse relationship
    Author *author1 = article.relations[@"author"].object;
    NSLog(@"article.relations['author']: %@", author1);

    Tag *tag = [Tag findOrCreate:@{ @"articleID": article.uid, @"name": @"Realm" }];
    NSLog(@"tag.relations['article']['author']: %@", tag.relations[@"article"].object.relations[@"author"].object);
}

- (void)selectSample {
    // Delete all data for sample.
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteAllObjects];
    }];

    // Save objects.
    Author *author1 = [Author findOrCreate:@{ @"name": @"Alice", @"age": @28 }];
    Author *author2 = [Author findOrCreate:@{ @"name": @"Bob", @"age": @55 }];
    Author *author3 = [Author findOrCreate:@{ @"name": @"Chris", @"age": @32 }];
    Author *author4 = [Author findOrCreate:@{ @"name": @"David", @"age": @45 }];
    Article *article1 = [Article findOrCreate:@{ @"authorID": author1.uid, @"title": @"Book1", @"text": @"Book1..." }];
    Article *article2 = [Article findOrCreate:@{ @"authorID": author1.uid, @"title": @"Book2", @"text": @"Book2..." }];
    Article *article3 = [Article findOrCreate:@{ @"authorID": author1.uid, @"title": @"Book3", @"text": @"Book3..." }];
    [Tag findOrCreate:@{ @"articleID": article1.uid, @"name": @"Computer Science" }];
    [Tag findOrCreate:@{ @"articleID": article2.uid, @"name": @"Paper" }];
    [Tag findOrCreate:@{ @"articleID": article3.uid, @"name": @"Magazine" }];

    // Select all objects.
    NSArray<Author *> *authors = Author.all;
    NSLog(@"All authors: %@", authors);

    // Select all objects ordered by specified property.
    authors = [Author.query.all order:@"age" ascending:NO].toArray;
    NSLog(@"All authors ordered by age: %@", authors);

    // Retrieve an object at index.
    Author *author = Author.query.all[1];
    NSLog(@"Retrieve an author at index: %@", author);

    // Find an object by specified ID.
    author = [Author findByID:author1.uid];
    NSLog(@"Find an author by ID: %@", author);

    // Find an object by specified parameters. When multiple objects are found, select first object.
    author = [Author find:@{ @"name": @"Bob" }];
    NSLog(@"Find an author by name: %@", author);

    // Select first created object.
    Tag *tag = Tag.first;
    NSLog(@"First tag: %@", tag);

    // Select specified number of objects from the head.
    NSArray<Tag *> *tags = [Tag firstWithLimit:2];
    NSLog(@"Select tags from the head: %@", tags);

    // Select specified number of objects ordered by specified property from the head.
    tags = [[Tag.query.all order:@"name" ascending:NO] firstWithLimit:2];
    NSLog(@"Select tags from the head: %@", tags);

    // Select last created object.
    tag = Tag.last;
    NSLog(@"Last tag: %@", tag);

    // Select specified number of objects from the tail.
    tags = [Tag lastWithLimit:2];
    NSLog(@"Select tags from the tail: %@", tags);

    // Select specified number of objects ordered by specified property from the tail.
    tags = [[Tag.query.all order:@"name" ascending:YES] lastWithLimit:2];
    NSLog(@"Select tags from the tail: %@", tags);

    // Find an object by specified parameters. When multiple objects are found, select last object.
    Article *article = [Article findLast:@{ @"authorID": author1.uid }];
    NSLog(@"Find last article: %@", article);

    // Find multiple objects by specified parameters.
    NSArray<Article *> *articles = [Article.query where:@{ @"authorID": author1.uid }].toArray;
    NSLog(@"Select articles by author: %@", articles);

    // Find multiple objects by specified parameters. The results are ordered by specified property.
    articles = [[Article.query where:@{ @"authorID": author1.uid }] order:@"title" ascending:NO].toArray;
    NSLog(@"Select articles by author: %@", articles);

    // Find specified number of objects by specified parameters. The results are ordered by specified property.
    articles = [[[Article.query where:@{ @"authorID": author1.uid }] order:@"title" ascending:NO] firstWithLimit:2];
    NSLog(@"Select articles by author: %@", articles);
    articles = [[[Article.query where:@{ @"authorID": author1.uid }] order:@"title" ascending:NO] lastWithLimit:2];
    NSLog(@"Select articles by author: %@", articles);

    // Retrieve an object at index.
    author = [Author.query.all objectAtIndex:1];
    NSLog(@"Author at index: %@", author);
}

- (void)destroySample {
    // Delete all data for sample.
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteAllObjects];
    }];

    // Save objects.
    Author *author1 = [Author findOrCreate:@{ @"name": @"Alice", @"age": @28 }];
    Author *author2 = [Author findOrCreate:@{ @"name": @"Bob", @"age": @55 }];
    Article *article1 = [Article findOrCreate:@{ @"authorID": author1.uid, @"title": @"Book1", @"text": @"Book1..." }];
    Article *article2 = [Article findOrCreate:@{ @"authorID": author1.uid, @"title": @"Book2", @"text": @"Book2..." }];
    Article *article3 = [Article findOrCreate:@{ @"authorID": author2.uid, @"title": @"Book3", @"text": @"Book3..." }];
    [Tag findOrCreate:@{ @"articleID": article1.uid, @"name": @"Computer Science" }];
    [Tag findOrCreate:@{ @"articleID": article2.uid, @"name": @"Paper" }];
    [Tag findOrCreate:@{ @"articleID": article3.uid, @"name": @"Magazine" }];

    NSLog(@"Authors before destroy: %@", Author.all);
    NSLog(@"Articles before destroy: %@", Article.all);
    NSLog(@"Tags before destroy: %@", Tag.all);

    // Cascade delete.
    [author1 destroy];

    NSLog(@"Authors after destroy: %@", Author.all);
    NSLog(@"Articles after destroy: %@", Article.all);
    NSLog(@"Tags after destroy: %@", Tag.all);

    // Cascade delete by specified parameters.
    [Author destroy:@{ @"name": @"Bob" }];
    NSLog(@"Authors after destroy: %@", Author.all);
    NSLog(@"Articles after destroy: %@", Article.all);
    NSLog(@"Tags after destroy: %@", Tag.all);
}

- (void)destroyAllSample {
    // Delete all data for sample.
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteAllObjects];
    }];

    // Save objects.
    Author *author1 = [Author findOrCreate:@{ @"name": @"Alice", @"age": @28 }];
    Author *author2 = [Author findOrCreate:@{ @"name": @"Bob", @"age": @55 }];
    Author *author3 = [Author findOrCreate:@{ @"name": @"Chris", @"age": @32 }];
    Author *author4 = [Author findOrCreate:@{ @"name": @"David", @"age": @45 }];
    [Article findOrCreate:@{ @"authorID": author1.uid, @"title": @"Book1", @"text": @"Book1..." }];
    [Article findOrCreate:@{ @"authorID": author1.uid, @"title": @"Book2", @"text": @"Book2..." }];
    [Article findOrCreate:@{ @"authorID": author2.uid, @"title": @"Book3", @"text": @"Book3..." }];

    NSLog(@"Authors before destroy: %@", Author.all);
    NSLog(@"Articles before destroy: %@", Article.all);

    // Cascade delete all objects.
    [Author destroyAll];
    NSLog(@"Authors after destroy: %@", Author.all);
    NSLog(@"Articles after destroy: %@", Article.all);
}

- (void)validationSample {
    // Delete all data for sample.
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteAllObjects];
    }];

    // Failed to save because validation error.
    Article *article = [Article findOrInitialize:@{ @"title": @"Programming Guide", @"text": @"Introduction ..." }];
    BOOL success = [article save];

    if (![Article findByID:article.uid]) {
        NSLog(@"Failed to save: %d", success);
    }
}

- (void)conversionSample {
    // Delete all data for sample.
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteAllObjects];
    }];

    // Save objects.
    Author *chris = [Author findOrCreate:@{ @"name": @"Chris", @"age": @32 }];
    [Article findOrCreate:@{ @"authorID": chris.uid, @"title": @"Book1", @"text": @"Book1..." }];
    [Article findOrCreate:@{ @"authorID": chris.uid, @"title": @"Book2", @"text": @"Book2..." }];

    // Convert to dictionary.
    NSDictionary *dict1 = chris.asDictionary;
    NSLog(@"author.asDictionary: %@", dict1);

    NSDictionary *dict2 = [chris asDictionaryExceptingProperties:@[ @"uid", @"createdAt", @"updatedAt" ]];
    NSLog(@"author.asDictionary: %@", dict2);

    NSDictionary *dict3 = [chris asDictionaryIncludingProperties:@[ @"name", @"age", @"shortUID" ]];
    NSLog(@"author.asDictionary: %@", dict3);

    NSDictionary *dict4 = [chris asDictionaryIncludingProperties:@[ @"uid" ] block:^id(NSString *prop, id value) {
        if ([prop isEqualToString:@"uid"]) {
            return [((NSString *) value) componentsSeparatedByString:@"-"].firstObject;
        }
        return value;
    }];
    NSLog(@"author.asDictionary: %@", dict4);

    NSDictionary *dict5 = [chris asDictionaryAddingPropertiesWithTarget:chris
                                                                methods:@{ @"generation": @"generation:" }];
    NSLog(@"author.asDictionary: %@", dict5);

    NSDictionary *dict6 = [chris asDictionaryExceptingProperties:@[ @"uid",
                                                                    @"createdAt",
                                                                    @"updatedAt",
                                                                    @"age" ]
                                      addingPropertiesWithTarget:chris
                                                         methods:@{ @"generation": @"generation:",
                                                                    @"works": @"works:" }];
    NSLog(@"author.asDictionary: %@", dict6);

    // Convert to JSON.
    NSString *json1 = chris.asJSONString;
    NSLog(@"author.asJSON: %@", json1);

    NSString *json2 = [chris asJSONStringExceptingProperties:@[ @"uid", @"createdAt", @"updatedAt" ]];
    NSLog(@"author.asJSON: %@", json2);

    NSString *json3 = [chris asJSONStringIncludingProperties:@[ @"name", @"age", @"shortUID" ]];
    NSLog(@"author.asJSON: %@", json3);

    NSString *json4 = [chris asJSONStringIncludingProperties:@[ @"uid" ] block:^id(NSString *prop, id value) {
        if ([prop isEqualToString:@"uid"]) {
            return [((NSString *) value) componentsSeparatedByString:@"-"].firstObject;
        }
        return value;
    }];
    NSLog(@"author.asJSON: %@", json4);

    NSString *json5 = [chris asJSONStringAddingPropertiesWithTarget:chris
                                                            methods:@{ @"generation": @"generation:" }];
    NSLog(@"author.asJSON: %@", json5);

    NSString *json6 = [chris asJSONStringExceptingProperties:@[ @"uid",
                                                                @"createdAt",
                                                                @"updatedAt",
                                                                @"age" ]
                                  addingPropertiesWithTarget:chris
                                                     methods:@{ @"generation": @"generation:",
                                                                @"works": @"works:" }];
    NSLog(@"author.asJSON: %@", json6);
}

- (void)countSample {
    // Delete all data for sample.
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteAllObjects];
    }];

    // Save objects.
    Author *author1 = [Author findOrCreate:@{ @"name": @"Alice", @"age": @28 }];
    Author *author2 = [Author findOrCreate:@{ @"name": @"Bob", @"age": @55 }];
    Author *author3 = [Author findOrCreate:@{ @"name": @"Chris", @"age": @32 }];
    Author *author4 = [Author findOrCreate:@{ @"name": @"David", @"age": @45 }];

    // Count objects.
    NSLog(@"The number of authors: %ld", Author.count);
    NSLog(@"The number of authors called David: %ld", [Author.query where:@{ @"name": @"David" }].count);
    NSLog(@"The number of authors over 40: %ld",
          [Author.query whereWithPredicate:[NSPredicate predicateWithFormat:@"age >= %d", 40]].count);
}

- (void)pluckSample {
    // Delete all data for sample.
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteAllObjects];
    }];

    // Save objects.
    Author *author1 = [Author findOrCreate:@{ @"name": @"Alice", @"age": @28 }];
    Author *author2 = [Author findOrCreate:@{ @"name": @"Bob", @"age": @55 }];
    Author *author3 = [Author findOrCreate:@{ @"name": @"Chris", @"age": @32 }];
    Author *author4 = [Author findOrCreate:@{ @"name": @"David", @"age": @45 }];

    NSArray *results1 = [Author.query.all pluck:@[ @"name" ]];
    NSLog(@"Pluck author names: %@", results1);

    NSArray *results2 = [Author.query.all pluck:@[ @"name", @"age" ]];
    NSLog(@"Pluck author status: %@", results2);

    NSArray *results3 = [[Author.query whereWithPredicate:[NSPredicate predicateWithFormat:@"age < %d", 40]]
                                       pluck:@[ @"name" ]];
    NSLog(@"Pluck author names under 40: %@", results3);
}

- (void)multiThreadSample {
    // Delete all data for sample.
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] deleteAllObjects];
    }];

    Author *author = [Author findOrCreate:@{ @"name": @"Alice", @"age": @28 }];

    // An ActiveRealm object can be used on multi-threads.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2 * NSEC_PER_SEC)),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       author.age = @29;
                       [author save];

                       dispatch_async(dispatch_get_main_queue(), ^{
                           NSLog(@"author: %@", [Author findWithFormat:@"name=%@", @"Alice"]);
                       });
                   });
}

@end
