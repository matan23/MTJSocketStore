//
//  MTJSocketStore.h
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

// Model object that can be persisted and serialized/deserialized
@protocol MTJSyncedEntity <NSObject>

+ (NSString *)identifierString;
+ (id<MTJSyncedEntity>)findOrCreateConversation:(NSString *)identifier inContext:(NSManagedObjectContext *)context;

- (void)loadFromDictionary:(NSDictionary *)dictionary;
+ (NSString *)entityName;
+ (NSString *)sortKey;

//network
+ (NSString *)endpointURL;


@end



@protocol MTJClientProtocol <NSObject>

+ (instancetype)clientWithAppID:(NSString *)appID;

- (void)connectUser:(NSString *)userID completion:(void(^)(BOOL success, NSError *error))completion;
- (void)GETCollectionAtEndpoint:(NSString *)endpoint completion:(void(^)(NSArray *collection, NSError *error))completion;
- (void)GETObjectAtEndpoint:(NSString *)endpoint withObjID:(NSString *)objID completion:(void(^)(NSDictionary *responseObj, NSError *error))completion;

@end




@class MTJSyncedTableViewDataSource;

@interface MTJSocketStore : NSObject

@property (nonatomic) id<MTJClientProtocol> client;

+ (instancetype)sharedStore;

- (void)connectUser:(NSString *)userID completion:(void(^)(BOOL success, NSError *error))completion;

- (void)syncCollectionOfType:(id<MTJSyncedEntity>)type
                  completion:(void(^)(NSArray *collection, NSError *error))completion;


- (MTJSyncedTableViewDataSource *)tableViewDataSourceForType:(id<MTJSyncedEntity>)type;

@end

