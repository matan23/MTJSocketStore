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

@end



@interface MTJSocketStore : NSObject

@property (nonatomic) id<MTJClientProtocol> client;

+ (instancetype)sharedStore;

- (void)connectUser:(NSString *)userID completion:(void(^)(BOOL success, NSError *error))completion;

@end

