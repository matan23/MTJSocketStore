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

@interface MTJSocketStore() {
    dispatch_queue_t _parsingConcurrentQueue;
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
        _parsingConcurrentQueue = dispatch_queue_create("com.mtjsocketstore.parsingconcurrentqueue", DISPATCH_QUEUE_CONCURRENT);
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
            
            completion(YES, nil);
        } else {
            
            completion(success, error);
        }
    }];
}

- (void)syncCollectionOfType:(id<MTJSyncedEntity>)type
                  completion:(void(^)(NSArray *collection, NSError *error))completion {
    [_client GETCollectionAtEndpoint:[type endpointURL] completion:^(NSArray *collection, NSError *error) {
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
            id<MTJSyncedEntity> entity = [type findOrCreateConversation:identifier
                                                              inContext:_backGroundContext];
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

- (MTJSyncedTableViewDataSource *)tableViewDataSourceForType:(id<MTJSyncedEntity>)type {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:[type entityName]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:[type sortKey] ascending:YES]];
    
    return [self tableViewDataSourceForRequest:request];
}

- (MTJSyncedTableViewDataSource *)tableViewDataSourceForRequest:(NSFetchRequest *)request {
    NSFetchedResultsController *FRC = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[PersistentStack sharedManager].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    MTJSyncedTableViewDataSource *FRCDatasource = [[MTJSyncedTableViewDataSource alloc] initWithFRC:FRC];
    return FRCDatasource;
}

@end
