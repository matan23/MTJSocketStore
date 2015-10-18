//
//  MTJLayerClient.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "MTJLayerClient.h"

#import "AFNetworking/AFNetworking.h"

@interface MTJLayerClient() {
    NSString *_appID;
    AFHTTPSessionManager *_layerSessionManager;
    NSString *_sessionToken;
}

@end

static NSString *const kBaseUrl = @"https://api.layer.com";

@implementation MTJLayerClient

+ (instancetype)clientWithAppID:(NSString *)appID {
    MTJLayerClient *client = [MTJLayerClient new];
    client->_appID = appID;
    
    return client;
}

/*
 ** Auth APIs
 */
- (void)connectUser:(NSString *)userID completion:(void(^)(BOOL success, NSError *error))completion {
    NSParameterAssert(userID);
    assert(_appID);
    
    [self requestNonceCompletion:^(NSString *nonce, NSError *error) {
        [self requestIdentityTokenWithNonce:nonce forUserID:userID completion:^(NSString *identityToken, NSError *error) {
            [self requestSessionTokenForIdentityToken:identityToken completion:^(NSString *sessionToken, NSError *error) {
                
                _sessionToken = sessionToken;
                if (_sessionToken) {
                    completion(YES, error);
                } else {
                    completion(NO, error);
                }
            }];
        }];
    }];
}

- (void)requestNonceCompletion:(void(^)(NSString *nonce, NSError *error))completion {
    [[self layerAuthSessionManager] POST:@"/nonces" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dic = responseObject;
        NSError *error = nil;
        NSString *nonce = [self tryReadDictionary:dic ForKey:@"nonce" error:&error];
        
        completion(nonce, error);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)requestIdentityTokenWithNonce:(NSString *)nonce forUserID:(NSString *)userID completion:(void(^)(NSString *identityToken, NSError *error))completion {
    NSParameterAssert(nonce);
    NSParameterAssert(userID);
    assert(_appID);
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"Accept":@"application/json"};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://layer-identity-provider.herokuapp.com"] sessionConfiguration:config];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    NSDictionary *params = @{@"app_id": _appID,
                             @"user_id": userID,
                             @"nonce": nonce};
    [manager POST:@"identity_tokens" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dic = responseObject;
        NSError *error = nil;
        NSString *identityToken = [self tryReadDictionary:dic ForKey:@"identity_token" error:&error];
        
        completion(identityToken, error);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        completion(@"", error);
    }];
}

- (void)requestSessionTokenForIdentityToken:(NSString *)identityToken completion:(void(^)(NSString *sessionToken, NSError *error))completion {
    
    NSDictionary *params = @{@"app_id": _appID,
                             @"identity_token": identityToken};
    [[self layerAuthSessionManager] POST:@"/sessions" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dic = responseObject;
        NSError *error = nil;
        NSString *sessionToken = [self tryReadDictionary:dic ForKey:@"session_token" error:&error];
        
        completion(sessionToken, error);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)GETCollectionAtEndpoint:(NSString *)endpoint completion:(void(^)(NSArray *collection, NSError *error))completion {
    [self GETObjectAtEndpoint:endpoint withObjID:nil completion:^(NSDictionary *responseObj, NSError *error) {
       
        completion((NSArray *)responseObj, error);
    }];
}


- (void)GETObjectAtEndpoint:(NSString *)endpoint withObjID:(NSString *)objID completion:(void (^)(NSDictionary *, NSError *))completion {
    NSString *url = [NSString stringWithFormat:@"%@/%@", kBaseUrl, endpoint];
    
//    GET Single Object /obj/uuid
    if (objID) {
        url = [NSString stringWithFormat:@"%@/%@", url, objID];
    }

    [[self layerSessionManager] GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSError *jsonParseError;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParseError];
        
        if (!jsonParseError) {
            NSNumber *code = response[@"code"];
            if ([code integerValue] == 4)
                NSLog(@"session token expired, should reconnect here");
        }
        completion(nil, error);
    }];
}

- (AFHTTPSessionManager *)layerSessionManager {
    if (_layerSessionManager) return _layerSessionManager;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    assert(_sessionToken);
    NSString *authorization = [NSString stringWithFormat:@"Layer session-token='%@'", _sessionToken];
    config.HTTPAdditionalHeaders = @{
                                     @"Accept":@"application/vnd.layer+json; version=1.0",
                                     @"Content-Type":@"application/json",
                                     @"Authorization":authorization
                                     };
    
    _layerSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL] sessionConfiguration:config];
    _layerSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _layerSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    i want to use charles for now.
    AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [policy setValidatesDomainName:NO];
    _layerSessionManager.securityPolicy = policy;
    
    return _layerSessionManager;
}

- (AFHTTPSessionManager *)layerAuthSessionManager {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.HTTPAdditionalHeaders = @{
                                     @"Accept":@"application/vnd.layer+json; version=1.0",
                                     @"Content-Type":@"application/json"
                                     };
    
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL] sessionConfiguration:config];
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    i want to use charles for now.
    AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [policy setValidatesDomainName:NO];
    sessionManager.securityPolicy = policy;
    
    return sessionManager;
}


//helpers
- (NSURL *)baseURL {
    return [NSURL URLWithString:kBaseUrl];
}

- (NSString *)tryReadDictionary:(NSDictionary *)dic ForKey:(NSString *)key error:(NSError **)error {
    if (!dic[key]) {
        NSDictionary *userInfo =
        @{
          NSLocalizedDescriptionKey: @"Unable to parse response",
          NSLocalizedRecoverySuggestionErrorKey: @"Check request"
          };
        
        *error = [[NSError alloc] initWithDomain:@"api.layer.com" code:-1 userInfo:userInfo];
    }
    return dic[key];
}

@end
