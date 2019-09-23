# ActiveRealm

***ActiveRealm is Active Record library using Realm for Objective-C/Swift, inspired by ActiveRecord of Ruby on Rails.***

[日本語doc](https://qiita.com/hituziando/items/06f85328c500da76afc6)

## Features

- Made in Objective-C and supports Swift
- Connects to Realm DB
- Many READ operations
- Cascade Delete by One-to-One or One-to-Many relationships
- An ActiveRealm object can be used on multi-threads

## Installation

### CocoaPods

ActiveRealm is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ActiveRealm"
```

### Manual Installation

1. Install [Realm](https://realm.io/docs/objc/latest/)
1. Download latest [ActiveRealm](https://github.com/HituziANDO/ActiveRealm/releases)
1. Drag & Drop ActiveRealm.framework into your Xcode project

## Getting Started

1. Import
	
	```swift
	import ActiveRealm
	```
	
1. Setup Realm
	
	First, you configure your Realm configuration as default Realm. For detail, see [this](https://realm.io/docs/objc/latest/#configuring-a-realm).
	
	```swift
	// Configure your Realm configuration as default Realm.
	let configuration = RLMRealmConfiguration.default()
	// Something to do
	RLMRealmConfiguration.setDefault(configuration)
	```
	
1. Implement Models
	
	Implement [Realm models](https://realm.io/docs/swift/latest/#models) using ARMObject class. ARMObject is the subclass of RLMObject. ARMObject has the following three properties by default: `uid`, `createdAt`, `updatedAt`. The uid property is the primary key for an ActiveRealm model. You must use ARMObject, not RLMObject.
	
	A class name inheriting ARMObject must have the prefix: `ActiveRealm`.
	
	Your subclass of ARMObject has just properties as data saved to DB.
	
	```swift
	class ActiveRealmAuthor: ARMObject {
	    @objc dynamic var name          = ""
	    @objc dynamic var age: NSNumber = 0
	}
	```
	
	Next, you implement models of ARMActiveRealm's subclass. A class name inheriting ARMActiveRealm must be the same as the string excluding the `ActiveRealm` prefix of the class name inheriting ARMObject.
	
	e.g.) ActiveRealmAuthor -> Author
	
	```swift
	class Author: ARMActiveRealm {
	    @objc var name          = ""
	    @objc var age: NSNumber = 0
	}
	```
	
	**[IMPORTANT]** 
	
	```
	Now, ActiveRealm does NOT support primitive type properties.
	e.g.) Int, Float, Double, Bool, etc...
	Please use NSNumber instead.
	```
	
### Relationships

You can make a relationship between two ActiveRealm subclasses by override `definedRelationships` method. By making a relationship, cascade delete is possible. Use ARMRelationship class and ARMInverseRelationship class for making the relationship.

#### One-to-One

For example, an Author object has one UserSettings object.

First, you set related child class and `.hasOne` type to ARMRelationship object in Author class.

```swift
class ActiveRealmAuthor: ARMObject {
    
    @objc dynamic var name          = ""
    @objc dynamic var age: NSNumber = 0
}

// Parent
class Author: ARMActiveRealm {
    
    @objc var name          = ""
    @objc var age: NSNumber = 0
    
    override class func definedRelationships() -> [String: ARMRelationship] {
        return ["userSettings": ARMRelationship(with: UserSettings.self, type: .hasOne)]
    }
}
```

Next, you set related parent class and `.belongsTo` type to ARMInverseRelationship object in UserSettings class. Then, you implement an `authorID` property as the foreign key. The property name as the foreign key must be the parent class name with lower case prefix and ID added to the end.

```swift
class ActiveRealmUserSettings: ARMObject {
    
    @objc dynamic var authorID                      = ""
    @objc dynamic var notificationEnabled: NSNumber = false
}

// Child
class UserSettings: ARMActiveRealm {
    
    @objc var authorID                      = ""
    @objc var notificationEnabled: NSNumber = false
    
    override class func definedRelationships() -> [String: ARMRelationship] {
        return ["author": ARMInverseRelationship(with: Author.self, type: .belongsTo)]
    }
}
```

#### One-to-Many

For example, an Article object has many Tag objects.

First, you set related child class and `.hasMany` type to ARMRelationship object in Article class.

```swift
class ActiveRealmArticle: ARMObject {
    
    @objc dynamic var title = ""
    @objc dynamic var text  = ""
}

class Article: ARMActiveRealm {
    
    @objc var title = ""
    @objc var text  = ""
    
    override class func definedRelationships() -> [String: ARMRelationship] {
        return ["tags": ARMRelationship(with: Tag.self, type: .hasMany)]
    }
}
```

Next, you set related parent class and `.belongsTo` type to ARMInverseRelationship object in Tag class. Then, you implement an `articleID` property as the foreign key. The property name as the foreign key must be the parent class name with lower case prefix and ID added to the end.

```swift
class ActiveRealmTag: ARMObject {
    
    @objc dynamic var articleID = ""
    @objc dynamic var name      = ""
}

class Tag: ARMActiveRealm {
    
    @objc var articleID = ""
    @objc var name      = ""
    
    override class func definedRelationships() -> [String: ARMRelationship] {
        return ["article": ARMInverseRelationship(with: Article.self, type: .belongsTo)]
    }
}
```

#### Access related object(s)

You can access related object(s) through `relations` property. The `relations` is the dictionary, so you specify the key that is same key of the dictionary `definedRelationships` method returns.

```swift
let alice = Author.findOrCreate(["name": "Alice", "age": 28])
UserSettings.findOrCreate(["authorID": alice.uid, "notificationEnabled": true])

// One-to-One
// Use relations[key].object
if let settings = alice.relations["userSettings"]?.object as? UserSettings {
    // Something to do.
}

let article = Article.findOrCreate(["title": "ActiveRealm User Guide",
                                    "text": "ActiveRealm is a library for iOS."])
Tag.findOrCreate(["articleID": article.uid, "name": "Programming"])
Tag.findOrCreate(["articleID": article.uid, "name": "iOS"])

// One-to-Many
// Use relations[key].objects
if let tags = article.relations["tags"]?.objects as? [Tag] {
    // Something to do.
}

// Inverse relationship
let tag = Tag.find(["articleID": article.uid])
if let article = tag.relations["article"]?.object as? Article {
    // Something to do.
}
```

Recommend that you implement alias of the relation property.

```swift
class Author: ARMActiveRealm {
    ...
    
    // The relation property. This property is just alias.
    var userSettings: UserSettings? {
        guard let userSettings = relations["userSettings"]?.object as? UserSettings else { return nil }
        return userSettings
    }
    
    override class func definedRelationships() -> [String: ARMRelationship] {
        return ["userSettings": ARMRelationship(with: UserSettings.self, type: .hasOne)]
    }
    
class UserSettings: ARMActiveRealm {
    ...
    
    // The relation property. This property is just alias.
    var author: Author {
        return relations["author"]?.object as! Author
    }
    
    override class func definedRelationships() -> [String: ARMRelationship] {
        return ["author": ARMInverseRelationship(with: Author.self, type: .belongsTo)]
    }
}
```

## CRUD

### Create

#### save()

`save` means INSERT if the record does not exists in the DB, otherwise UPDATE it.

```swift
// Initialize an instance.
let alice = Author()
alice.name = "Alice"
alice.age = 28

// Insert to Realm DB.
alice.save()
```

#### findOrInitialize(_:)

Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters. NOT save yet.

```swift
let author = Author.findOrInitialize(["name": "Bob", "age": 55])
author.save()
```

#### findOrCreate(_:)

Find an object if exists in Realm DB. Otherwise, initialize it with specified parameters and insert it to the DB.

```swift
let author = Author.findOrCreate(["name": "Bob", "age": 55])
```

### Read

ActiveRealm has many READ operations.

#### all()

Select all objects.

```swift
let authors = Author.all()
```

#### first()

Select first created object.

```swift
let tag = Tag.first()
```

#### first(limit:)

Select specified number of objects from the head.

```swift
let tags = Tag.first(limit: 10)
```

#### last()

Select last created object.

```swift
let tag = Tag.last()
```

#### last(limit:)

Select specified number of objects from the tail.

```swift
let tags = Tag.last(limit: 10)
```

#### find(ID:)

Find an object by specified ID.

```swift
let author = Author.find(ID: "XXXXXXXX-XXXX-4XXX-XXXX-XXXXXXXXXXXX")
```

#### find(_:)

Find an object by specified parameters. When multiple objects are found, select first object.

```swift
let author = Author.find(["name": "Alice", "age": 28])
```

#### find(with:)

Find an object by specified parameters. When multiple objects are found, select first object.

```swift
let author = Author.find(with: NSPredicate(format: "age > %d", 28))
```

#### findLast(_:)

Find an object by specified parameters. When multiple objects are found, select last object.

```swift
let tag = Tag.findLast(["articleID": "XXXXXXXX-XXXX-4XXX-XXXX-XXXXXXXXXXXX"])
```

#### findLast(with:)

Find an object by specified parameters. When multiple objects are found, select last object.

```swift
let tag = Tag.findLast(with: NSPredicate(format: "articleID=%@", "XXXXXXXX-XXXX-4XXX-XXXX-XXXXXXXXXXXX"))
```

### Update

#### save()

```swift
let alice = Author.find(["name": "Alice"])
alice.age = 29

// Update.
alice.save()
```

### Delete

#### destroy()

`destroy` method performs cascade delete by default. In other words, related data are also deleted collectively.

```swift
alice.destroy()
```

#### destroy(_:)

Deletes objects and related objects searched by specified parameters.

```swift
Author.destroy(["name": "Alice"])
Author.destroy(with: NSPredicate(format: "name=%@", "Alice"))
```

#### destroyAll()

Deletes all objects and related objects at the same time.

```swift
Author.destroyAll()
```

If not cascade deleting, use following methods. Specify false to `cascade` argument.

```swift
alice.destroy(cascade: false)
Author.destroy(["name": "Alice"], cascade: false)
Author.destroy(with: NSPredicate(format: "name=%@", "Alice"), cascade: false)
Author.destroyAll(cascade: false)
```

### Query

#### all

Returns all objects of the model.

```swift
let collection = Author.query.all
```

#### where(_:)

Returns objects searched by specified parameters.

```swift
let collection = Author.query.where(["name": "Alice"])
```

#### where(predicate:)

Returns objects searched by specified searching condition with a predicate.

```swift
let collection = Author.query.where(predicate: NSPredicate(format: "age > %d", 40))
```

### Collection

#### toArray

The models in the collection. Converts to a NSArray.
 
```swift
let collection = Author.query.all
let authors = collection.toArray
```

#### count

The number of models in the collection.

```swift
let collection = Author.query.all
let count = collection.count
```

#### first

The first model in the collection.

```swift
let collection = Author.query.all
let author = collection.first
```

#### first(limit:)

Returns specified number of the models from the head.

```swift
let collection = Author.query.all
let authors = collection.first(limit: 5)
```

#### last

The last model in the collection.

```swift
let collection = Author.query.all
let author = collection.last
```

#### last(limit:)

Returns specified number of the models from the tail.

```swift
let collection = Author.query.all
let authors = collection.last(limit: 5)
```

#### order(_:ascending:)

Sorts objects in the collection by specified property.

```swift
let collection = Author.query.all
collection.order("age", ascending: true)
```

#### at(_:)

Retrieves an object at given index.

```swift
let collection = Author.query.all
let author = collection.at(1)
```

#### pluck(_:)

Plucks properties of the model.

```swift
let collection = Author.query.all
let names = collection.pluck(["name"])
```

## Count

Count objects.

```swift
// The number of all objects.
let count = Author.count
```

```swift
// The number of objects matched given condition.
let count1 = Author.query.where(["name": "Alice"]).count
let count2 = Author.query.where(predicate: NSPredicate(format: "age > %d", 40)).count
```

## Ignored properties

ActiveRealm saves all properties in your model to the DB by default. If you don’t want to save a property, override `ignoredProperties` method.

```swift
class Author: ARMActiveRealm {
    
    @objc var name          = ""
    @objc var age: NSNumber = 0
    
    // A property ignored by ActiveRealm.
    @objc var shortID: String {
        return String(uid.split(separator: "-").first!)
    }
    
    override class func ignoredProperties() -> [String] {
        return ["shortID"]
    }
}
```

## Validation

ActiveRealm can validate data before saving a model. By default, the validation is always successful. If you want to validate data, override `validateBeforeSaving` method. When `validateBeforeSaving` method returns false, the data isn't saved.

```swift
class Author: ARMActiveRealm {
    
    @objc var name          = ""
    @objc var age: NSNumber = 0
    
    override class func validateBeforeSaving(_ obj: Any) -> Bool {
        let author = obj as! Author
        
        // The name must not be empty.
        return !author.name.isEmpty
    }
}
```

## Conversion methods

ActiveRealm can convert properties in your model to the dictionary or JSON easily.

### Converting to Dictionary

#### asDictionary()

```swift
class Author: ARMActiveRealm {
    
    @objc var name          = ""
    @objc var age: NSNumber = 0
    
    // A property ignored by ActiveRealm.
    @objc var shortID: String {
        return String(uid.split(separator: "-").first!)
    }
    
    override class func ignoredProperties() -> [String] {
        return ["shortID"]
    }
    
    @objc func generation(_ obj: Author) -> NSNumber {
        return NSNumber(integerLiteral: Int(age.doubleValue / 10.0) * 10)
    }
}

let chris = Author.findOrCreate(["name": "Chris", "age": 32])

// Convert to a dictionary.
let dict = chris.asDictionary()
// => {
//	age = 32;
//	createdAt = "2019-06-07 07:45:05 +0000";
//	name = Chris;
//	uid = "D56F60E1-96C1-4083-A7D4-E216FF072DEA";
//	updatedAt = "2019-06-07 07:45:05 +0000";
// }
```

#### asDictionary(excepted:)

Converts to a dictionary using a black list of property names.

```swift
let dict = chris.asDictionary(excepted: ["uid", "createdAt", "updatedAt"])
// => {
//	age = 32;
//	name = Chris;
// }
```

#### asDictionary(included:)

Converts to a dictionary using a white list of property names. This method also includes ignored properties.

```swift
let dict = chris.asDictionary(included: ["name", "age", "shortID"])
// => {
//	age = 32;
//	name = Chris;
//	shortUID = D56F60E1;
// }
```

#### asDictionary { prop, value in }
#### asDictionary(excepted:) { prop, value in }
#### asDictionary(included:) { prop, value in }

Converts to a dictionary using a conversion logic.

```swift
// Using a conversion logic.
let dict = chris.asDictionary(included: ["uid"]) { prop, value in
    if prop == "uid" {
        let uuid = value as! String
        return uuid.split(separator: "-").first!
    }
    return value
}
// => {
//	uid = D56F60E1;
// }
```

#### asDictionary(addingPropertiesWith:methods:)
#### asDictionary(excepted:addingPropertiesWith:methods:)
#### asDictionary(included:addingPropertiesWith:methods:)

Converts to a dictionary adding properties with a conversion method of a target. The method name is specified by Objective-C representation.

```swift
let dict = chris.asDictionary(included: ["name"],
                              addingPropertiesWith: chris,
                              methods: ["generation": "generation:"])
// => {
//	generation = 30;
//	name = Chris;
// }
```

### Converting to JSON

#### asJSON(), asJSONString()

The `asJSON` method returns a Data type value. On the other hand, the `asJSONString` method returns a String type value.

```swift
class Author: ARMActiveRealm {
    
    @objc var name          = ""
    @objc var age: NSNumber = 0
    
    // A property ignored by ActiveRealm.
    @objc var shortID: String {
        return String(uid.split(separator: "-").first!)
    }
    
    override class func ignoredProperties() -> [String] {
        return ["shortID"]
    }
    
    @objc func generation(_ obj: Author) -> NSNumber {
        return NSNumber(integerLiteral: Int(age.doubleValue / 10.0) * 10)
    }
}

let chris = Author.findOrCreate(["name": "Chris", "age": 32])

// Convert to a JSON.
let json = chris.asJSONString()
// => {
//	"age" : 32,
//	"uid" : "66703A0B-5712-4631-83C4-DF52E1CCE15F",
//	"updatedAt" : "2019-06-07 09:15:15 +0000",
//	"name" : "Chris",
//	"createdAt" : "2019-06-07 09:15:15 +0000"
// }
```

#### asJSON(excepted:), asJSONString(excepted:)

Converts to a JSON using a black list of property names.

```swift
let json = chris.asJSONString(excepted: ["uid", "createdAt", "updatedAt"])
// => {
//	"age" : 32,
//	"name" : "Chris"
// }
```

#### asJSON(included:), asJSONString(included:)

Converts to a JSON using a white list of property names. This method also includes ignored properties.

```swift
let json = chris.asJSONString(included: ["name", "age", "shortID"])
// => {
//	"age" : 32,
//	"name" : "Chris",
//	"shortUID" : "66703A0B"
// }
```

#### asJSON { prop, value in }, asJSONString { prop, value in }
#### asJSON(excepted:) { prop, value in }, asJSONString(excepted:) { prop, value in }
#### asJSON(included:) { prop, value in }, asJSONString(included:) { prop, value in }

Converts to a JSON using a conversion logic.

```swift
let json = chris.asJSONString(included: ["uid"]) { prop, value in
    if prop == "uid" {
        let uuid = value as! String
        return uuid.split(separator: "-").first!
    }
    return value
}
// => {
//	"uid" : "66703A0B"
// }
```

#### asJSON(addingPropertiesWith:methods:), asJSONString(addingPropertiesWith:methods:)
#### asJSON(excepted:addingPropertiesWith:methods:), asJSONString(excepted:addingPropertiesWith:methods:)
#### asJSON(included:addingPropertiesWith:methods:), asJSONString(included:addingPropertiesWith:methods:)

Converts to a JSON adding properties with a conversion method of a target. The method name is specified by Objective-C representation.

```swift
let json = chris.asJSONString(excepted: ["uid", "createdAt", "updatedAt", "age"],
                              addingPropertiesWith: chris,
                              methods: ["generation": "generation:"])
// => {
//	"generation" : 30,
//	"name" : "Chris"
// }
```

## Usage in Objective-C
Usage in Objective-C, see [my sample code](https://github.com/HituziANDO/ActiveRealm/blob/master/ActiveRealmSample/ActiveRealmSample/ViewController.m).

## TODO

- Supports Many-to-Many relationship
- Supports NOT NULL constraint
- Supports primitive types. e.g.) NSInteger, float, double, BOOL, etc...
- Property names mapping