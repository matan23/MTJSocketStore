//
//  MTJLayerClient.h
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTJSocketStore.h"

@interface MTJLayerClient : NSObject <MTJClientProtocol>

+ (instancetype)clientWithAppID:(NSString *)appID;

- (void)connectUser:(NSString *)userID completion:(void(^)(BOOL success, NSError *error))completion;

@end
