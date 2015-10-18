//
//  MTJSocketStore.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "MTJSocketStore.h"

//// create a dispatch queue, first argument is a C string (note no "@"), second is always NULL
//dispatch_queue_t jsonParsingQueue = dispatch_queue_create("jsonParsingQueue", NULL);
//
//// execute a task on that queue asynchronously
//dispatch_async(jsonParsingQueue, ^{
//    [self doSomeJSONReadingAndParsing];
//    
//    // once this is done, if you need to you can call
//    // some code on a main thread (delegates, notifications, UI updates...)
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.viewController updateWithNewData];
//    });
//});
//
//// release the dispatch queue
//dispatch_release(jsonParsingQueue

#import "PersistentStack.h"
#import "Conversation.h"

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
        _parsingConcurrentQueue = dispatch_queue_create("com.mataejoon.mtjsocketstore", DISPATCH_QUEUE_CONCURRENT);
        _backGroundContext = [PersistentStack sharedManager].backgroundManagedObjectContext;
    }
    return self;
}

- (void)connectUser:(NSString *)userID completion:(void(^)(BOOL success, NSError *error))completion {
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

- (void)getAllConversationsCompletion:(void(^)(NSArray *conversations, NSError *error))completion {
    [_client GETCollectionAtEndpoint:@"conversations" completion:^(NSArray *collection, NSError *error) {
        if (!error) {
//            CHANGE THAT
            //            CHANGE THAT
            //            CHANGE THAT
            //            CHANGE THAT//            CHANGE THAT
//            dispatch_async(_parsingConcurrentQueue, ^{
            
            assert(_backGroundContext);
                [_backGroundContext performBlock:^{
                    
                    NSMutableArray *conversations = [NSMutableArray new];
                    for (NSDictionary *convDic in collection) {
                        NSString *identifier = convDic[@"obj_id"];
                        Conversation *conv = [Conversation findOrCreateConversation:identifier inContext:_backGroundContext];
                        [conv loadFromDictionary:convDic];
                        [conversations addObject:conv];
                    }
                    NSError *error = nil;
                    [_backGroundContext save:&error];
                    if (error) {
                        NSLog(@"Error: %@", error.localizedDescription);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(conversations, nil);
                    });
                }];
            
                
                
                
//            });
        } else {
            completion([NSArray array], nil);
        }
    }];
}

//+ (NSArray<Conversation *>*)fetchConversationsFromJSONArray:(NSArray *)json {
//    NSMutableArray<Conversation *> *conversations = [NSMutableArray new];
//    
//    
//    for (NSDictionary *dic in json) {
//        
//        Conversation *conv = [Conversation findOrCreatePodWithIdentifier:identifier inContext:self.context];
//        [conv loadFromDictionary:json];
//        
//        
//        [conversations addObject:conv];
//    }
//    
//    return [NSArray arrayWithArray:conversations];
//}


- (void)getConversation:(NSString *)objID completion:(void(^)(NSDictionary *conversation, NSError *error))completion {
    [_client GETObjectAtEndpoint:@"conversations" withObjID:objID completion:^(NSDictionary *responseObj, NSError *error) {
        if (!error) {
            NSDictionary *conversation = nil;
            
            completion(conversation, nil);
        } else {
            completion([NSDictionary dictionary], nil);
        }
    }];
}


@end
