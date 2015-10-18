//
//  MTJTestHelper.h
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTJLayerKeysHelper : NSObject

- (NSString *)appID;
- (NSString *)userID;

+ (instancetype)sharedInstance;

@end
