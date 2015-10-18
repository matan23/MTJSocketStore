//
//  MTJTestHelper.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "MTJTestHelper.h"

@interface MTJTestHelper() {
    NSDictionary *_plistDic;
}

@end

@implementation MTJTestHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *strplistPath = [[NSBundle mainBundle] pathForResource:@"layer_secrets" ofType:@"plist"];
        _plistDic = [NSDictionary dictionaryWithContentsOfFile:strplistPath];
    }
    return self;
}

- (NSString *)appID {
    NSString *layerAppID = _plistDic[@"layerAppID"];
    NSAssert(layerAppID, @"Could not read layerAppID from layer_secrets.plist, is the plist configured correctly and present in the app bundle?");
    
    return layerAppID;
}

- (NSString *)userID {
    NSString *layerUserID = _plistDic[@"layerUserID"];
    NSAssert(layerUserID, @"Could not read layerUserID from layer_secrets.plist, is the plist configured correctly and present in the app bundle?");
    
    return layerUserID;
}

@end
