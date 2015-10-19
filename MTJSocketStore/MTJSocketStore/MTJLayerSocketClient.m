//
//  MTJSocketClient.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/19/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "MTJLayerSocketClient.h"
#import "SRWebSocket.h"

@interface MTJLayerSocketClient() <SRWebSocketDelegate> {
    SRWebSocket *_socket;
    dispatch_queue_t _parsingConcurrentQueue;
}
@end

@implementation MTJLayerSocketClient

+ (instancetype)client {
    return [MTJLayerSocketClient new];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _parsingConcurrentQueue = dispatch_queue_create("com.mtjsocketstore.mtjlayersocketclient.parsingconcurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (SRWebSocket *)socket {
    assert(_sessionToken);
    if (_socket) return _socket;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"wss://api.layer.com/websocket?session_token=%@", _sessionToken]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _socket =  [[SRWebSocket alloc] initWithURLRequest:request protocols:@[@"layer-1.0"]];
    _socket.delegate = self;
    return _socket;
}

#pragma mark - MTJSocketClientProtocol

- (void)connectToSession:(NSString *)sessionToken {
    _sessionToken = [sessionToken copy];
    [self.socket open];
}

- (void)sendData:(NSDictionary *)data {
    if (data == nil) return;
    if (_socket.readyState != SR_OPEN) {
        NSLog(@"socket not opened yet! Queue the message for retry");
        return;
    }
    
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&jsonError];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (!jsonError) {
        [_socket send:jsonStr];
    } else {
        NSLog(@"%@: parsing error", NSStringFromSelector(_cmd));
    }
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    [_delegate socketDidOpen];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    dispatch_async(_parsingConcurrentQueue, ^{
        NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError __autoreleasing *jsonError = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"%@: parsing error", NSStringFromSelector(_cmd));
            return;
        }
        
        NSDictionary *ret = [self parseReceivedData:dict];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate didReceiveData:ret];
        });
    });
}

- (NSDictionary *)parseReceivedData:(NSDictionary *)dictionary {
    if ([dictionary[@"type"] isEqualToString:@"change"]) {
        return [self parseChange:dictionary];
    } else if ([dictionary[@"type"] isEqualToString:@"response"]) {
        return [self parseRequest:dictionary];
    } else {
        NSLog(@"not handle");
    }
    return dictionary;
}

- (NSDictionary *)parseChange:(NSDictionary *)dictionary {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return dictionary;
}

- (NSDictionary *)parseRequest:(NSDictionary *)dictionary {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSNumber *success = dictionary[@"body"][@"success"];
    if ([success integerValue] == 1) {
        NSLog(@"request succeeded!");
        return dictionary[@"body"][@"data"];
    } else {
        NSLog(@"socket received failed request from layer");
        return nil;
    }
    
}


- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [_delegate socketDidCloseWithCode:code reason:reason wasClean:wasClean];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [_delegate socketDidFailWithError:error];
}

@end
