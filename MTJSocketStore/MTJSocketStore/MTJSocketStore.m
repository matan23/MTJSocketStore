//
//  MTJSocketStore.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "MTJSocketStore.h"

#import "PersistentStack.h"

#import "MTJSyncedTableViewDataSource.h"

//these two imports should not be here as models are generic once 'entityCreated:' is completely done we can remove these imports
#import "Conversation.h"
#import "Message.h"

@interface MTJSocketStore() <MTJSocketClientDelegate> {
    NSManagedObjectContext *_backGroundContext;
}
@end



@implementation MTJSocketStore

+ (instancetype)sharedStore {
    static MTJSocketStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [MTJSocketStore new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _backGroundContext = [PersistentStack sharedManager].backgroundManagedObjectContext;
    }
    return self;
}

- (void)connectUser:(NSString *)userID
         completion:(void(^)(BOOL success, NSError *error))completion {
    NSParameterAssert(userID);
    NSAssert(_client, @"client not set");
    
    [_client connectUser:userID completion:^(BOOL success, NSError *error) {
        if (success) {
    
            NSAssert(_socketClient, @"client not set");
            [_socketClient connectToSession:_client.sessionToken];
            _socketClient.delegate = self;
            completion(YES, nil);
        } else {
            
            completion(success, error);
        }
    }];
}

- (void)syncCollectionOfType:(Class<MTJSyncedEntity>)collectionType
             belongingToType:(id<MTJSyncedEntity>)parentType
                  completion:(void(^)(NSArray *collection, NSError *error))completion {
    [_client GETCollectionAtEndpoint:[parentType collectionWithRelationshipEndpointURL] completion:^(NSArray *collection, NSError *error) {
        if (!error) {
            [self importCollectionOfType:collectionType belongingToType:parentType fromJSON:collection completion:completion];
        } else {
            completion([NSArray array], error);
        }
    }];
}

- (void)importCollectionOfType:(Class<MTJSyncedEntity>)type
               belongingToType:(id<MTJSyncedEntity>)parentType
                      fromJSON:(NSArray *)collection
                    completion:(void(^)(NSArray *collection, NSError *error))completion {
    assert(_backGroundContext);
    
    [_backGroundContext performBlock:^{
        assert(![NSThread isMainThread]);
        NSMutableArray *ret = [NSMutableArray new];
        NSMutableSet *mutableSet = [NSMutableSet new];
        
        for (NSDictionary *dictionary in collection) {
            NSString *identifier = dictionary[[type identifierString]];
            
            assert(identifier);
            id<MTJSyncedEntity> entity = [type findOrCreateEntity:identifier inContext:_backGroundContext];
            [entity loadFromDictionary:dictionary];
            [mutableSet addObject:entity];
        }
        [parentType addCollection:[mutableSet copy]];
        
        NSError *ctxError = nil;
        [_backGroundContext save:&ctxError];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!ctxError) {
                completion(ret, nil);
            } else {
                NSLog(@"Error: %@", ctxError.localizedDescription);
                completion([NSArray array], ctxError);
            }
        });
    }];

}

- (void)syncCollectionOfType:(id<MTJSyncedEntity>)type
                  completion:(void(^)(NSArray *collection, NSError *error))completion {
    [_client GETCollectionAtEndpoint:[type collectionEndpointURL] completion:^(NSArray *collection, NSError *error) {
        if (!error) {
            [self importCollectionOfType:type fromJSON:collection completion:completion];
        } else {
            completion([NSArray array], error);
        }
    }];
}

- (void)importCollectionOfType:(id<MTJSyncedEntity>)type
                      fromJSON:(NSArray *)collection
                    completion:(void(^)(NSArray *collection, NSError *error))completion {
    assert(_backGroundContext);
    assert([type conformsToProtocol:@protocol(MTJSyncedEntity)]);
    
    [_backGroundContext performBlock:^{
        assert(![NSThread isMainThread]);
        NSMutableArray *ret = [NSMutableArray new];
        
        for (NSDictionary *dictionary in collection) {
            NSString *identifier = dictionary[[type identifierString]];
            
            assert(identifier);
            id<MTJSyncedEntity> entity = [type findOrCreateEntity:identifier inContext:_backGroundContext];
            [entity loadFromDictionary:dictionary];
            [ret addObject:entity];
        }
        
        NSError *ctxError = nil;
        [_backGroundContext save:&ctxError];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!ctxError) {
                completion(ret, nil);
            } else {
                NSLog(@"Error: %@", ctxError.localizedDescription);
                completion([NSArray array], ctxError);
            }
        });
    }];
}

- (void)syncedInsertEntity:(id<MTJSyncedEntity>)entity {
    [_socketClient sendData:[entity serializedCreateRequestDictionary]];
}

- (id<MTJSyncedEntity>)entityWithId:(NSString *)identifier ofType:(Class<MTJSyncedEntity>)type {
    id<MTJSyncedEntity> entity= [type findOrCreateEntity:identifier inContext:_backGroundContext];
    return entity;
}

- (MTJSyncedTableViewDataSource *)tableViewDataSourceForType:(Class<MTJSyncedEntity>)type {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:[type entityName]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:[type sortKey] ascending:YES]];
    
    return [self tableViewDataSourceForRequest:request];
}

- (MTJSyncedTableViewDataSource *)tableViewDataSourceForRequest:(NSFetchRequest *)request {
    NSFetchedResultsController *FRC = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[PersistentStack sharedManager].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    MTJSyncedTableViewDataSource *FRCDatasource = [[MTJSyncedTableViewDataSource alloc] initWithFRC:FRC];
    return FRCDatasource;
}

#pragma mark - MTJSocketClientDelegate
- (void)socketDidOpen {
    
}

- (void)socketDidFailWithError:(NSError *)error {
    
}

- (void)socketDidCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
}

//hardcoded type for now
- (void)entityCreated:(NSDictionary *)data {
//    handle only message for now

    
    [_backGroundContext performBlock:^{
        assert(![NSThread isMainThread]);
        Message *message = [Message findOrCreateEntity:data[[Message identifierString]] inContext:_backGroundContext];
        [message loadFromDictionary:data];
        
        Conversation *conversation = [Conversation findOrCreateEntity:data[@"conversation"][@"id"] inContext:_backGroundContext];
//        [conversation addMessagesObject:message];
        message.conversation = conversation;

        
        NSError *ctxError = nil;
        [_backGroundContext save:&ctxError];
        if (ctxError) NSLog(@"error creation entity from socket response: %@", ctxError);
    }];


}

- (void)didReceiveData:(NSDictionary *)data {
    NSLog(@"%@", data);
//    id<MTJSyncedEntity> entity = [type findOrCreateEntity:identifier inContext:_backGroundContext];
//    [entity loadFromDictionary:dictionary];
//    [ret addObject:entity];
}


@end
