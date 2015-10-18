//
//  MTJSocketStore.h
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MTJClientProtocol <NSObject>

+ (instancetype)clientWithAppID:(NSString *)appID;

- (void)connectUser:(NSString *)userID completion:(void(^)(BOOL success, NSError *error))completion;
- (void)GETCollectionAtEndpoint:(NSString *)endpoint completion:(void(^)(NSArray *collection, NSError *error))completion;
- (void)GETObjectAtEndpoint:(NSString *)endpoint withObjID:(NSString *)objID completion:(void(^)(NSDictionary *responseObj, NSError *error))completion;

@end



@interface MTJSocketStore : NSObject

@property (nonatomic) id<MTJClientProtocol> client;

+ (instancetype)sharedStore;

- (void)connectUser:(NSString *)userID completion:(void(^)(BOOL success, NSError *error))completion;

- (void)getAllConversationsCompletion:(void(^)(NSArray *conversations, NSError *error))completion;

- (void)getConversation:(NSString *)objID completion:(void(^)(NSDictionary *conversation, NSError *error))completion;

@end

