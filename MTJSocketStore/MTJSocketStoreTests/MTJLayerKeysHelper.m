//
//  MTJTestHelper.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "MTJLayerKeysHelper.h"

@interface MTJLayerKeysHelper() {
    NSDictionary *_plistDic;
}

@end

@implementation MTJLayerKeysHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *strplistPath = [[NSBundle mainBundle] pathForResource:@"layer_secrets" ofType:@"plist"];
        _plistDic = [NSDictionary dictionaryWithContentsOfFile:strplistPath];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static MTJLayerKeysHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MTJLayerKeysHelper alloc] init];
    });
    
    return _sharedInstance;
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
