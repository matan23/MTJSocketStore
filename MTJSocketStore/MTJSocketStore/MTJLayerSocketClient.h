//
//  MTJSocketClient.h
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/19/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTJSocketStore.h"

//Adapter to communicate with layer using SocketRocket
@interface MTJLayerSocketClient : NSObject <MTJSocketClientProtocol>

@property (nonatomic, copy, readonly) NSString *sessionToken;
@property (nonatomic, weak) id<MTJSocketClientDelegate> delegate;

@end
