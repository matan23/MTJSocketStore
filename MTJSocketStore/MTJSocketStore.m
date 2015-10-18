//
//  MTJSocketStore.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "MTJSocketStore.h"

@implementation MTJSocketStore

+ (instancetype)sharedStore {
    static MTJSocketStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [MTJSocketStore new];
    });
    return sharedInstance;
}

- (void)connectUser:(NSString *)userID completion:(void(^)(BOOL success, NSError *error))completion {
    NSParameterAssert(userID);
    NSAssert(_client, @"client not set");
    
    [_client connectUser:userID completion:^(BOOL success, NSError *error) {
        
    }];
}

@end
