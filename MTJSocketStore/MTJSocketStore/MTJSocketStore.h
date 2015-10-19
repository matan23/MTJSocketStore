//
//  MTJSocketStore.h
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObject;
@class NSManagedObjectContext;

// Model object that can be persisted and serialized/deserialized
@protocol MTJSyncedEntity <NSObject>

//name of the field in the core data model to identify the object
+ (NSString *)identifierString;
+ (id<MTJSyncedEntity>)findOrCreateEntity:(NSString *)identifier inContext:(NSManagedObjectContext *)context;
- (void)addCollection:(NSSet<NSManagedObject *> *)values;

//serialize/deserializing
- (void)loadFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)serializedCreateRequestDictionary;

+ (NSString *)entityName;
+ (NSString *)sortKey;

//REST url for the resource: ex: for https://mywebserver.com/conversations the value would be 'conversations'
- (NSString *)endpointURL;
+ (NSString *)collectionEndpointURL;
- (NSString *)collectionWithRelationshipEndpointURL;

@end



@protocol MTJClientProtocol <NSObject>

@property (nonatomic, readonly) NSString *sessionToken;

+ (instancetype)clientWithAppID:(NSString *)appID;

- (void)connectUser:(NSString *)userID completion:(void(^)(BOOL success, NSError *error))completion;
- (void)GETCollectionAtEndpoint:(NSString *)endpoint completion:(void(^)(NSArray *collection, NSError *error))completion;
- (void)GETObjectAtEndpoint:(NSString *)endpoint withObjID:(NSString *)objID completion:(void(^)(NSDictionary *responseObj, NSError *error))completion;

@end


@protocol MTJSocketClientDelegate <NSObject>
- (void)socketDidOpen;
- (void)socketDidFailWithError:(NSError *)error;
- (void)socketDidCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)didReceiveData:(NSDictionary *)data;
@end

@protocol MTJSocketClientProtocol <NSObject>

@property (nonatomic, weak) id<MTJSocketClientDelegate> delegate;

+ (instancetype)client;

- (void)connectToSession:(NSString *)sessionToken;
- (void)sendData:(NSDictionary *)data;

@end



@class MTJSyncedTableViewDataSource;

@interface MTJSocketStore : NSObject

@property (nonatomic) id<MTJClientProtocol> client;
@property (nonatomic) id<MTJSocketClientProtocol> socketClient;

+ (instancetype)sharedStore;

- (void)connectUser:(NSString *)userID completion:(void(^)(BOOL success, NSError *error))completion;

- (void)syncCollectionOfType:(id<MTJSyncedEntity>)collectionType
             belongingToType:(id<MTJSyncedEntity>)parentType
                  completion:(void(^)(NSArray *collection, NSError *error))completion;

- (void)syncCollectionOfType:(id<MTJSyncedEntity>)type
                  completion:(void(^)(NSArray *collection, NSError *error))completion;

- (void)syncedInsertEntityOfType:(id<MTJSyncedEntity>)type;

- (MTJSyncedTableViewDataSource *)tableViewDataSourceForType:(id<MTJSyncedEntity>)type;

@end

