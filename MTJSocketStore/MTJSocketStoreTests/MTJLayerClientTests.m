//
//  MTJLayerClientTests.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "MTJTestHelper.h"
#import "MTJLayerClient.h"

//used to check that public methods call private methods
@interface MTJLayerClient(PrivateAPI)
- (void)requestNonceCompletion:(void(^)(NSString *nonce, NSError *error))completion;
- (void)requestIdentityTokenWithNonce:(NSString *)nonce forUserID:(NSString *)userID completion:(void(^)(NSString *identityToken, NSError *error))completion;
- (void)requestSessionTokenForIdentityToken:(NSString *)identityToken completion:(void(^)(NSString *sessionToken, NSError *error))completion;
@end

@interface MTJLayerClientTests : XCTestCase {
    MTJLayerClient *_client;
    MTJTestHelper *_testHelper;
}

@end

@implementation MTJLayerClientTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _testHelper = [MTJTestHelper new];
    _client = [MTJLayerClient clientWithAppID:[_testHelper appID]];
}

- (void)tearDown {

    _client = nil;
    [super tearDown];
}

- (void)testConnectUserShouldCallRequestNonce {
    id mockClient = [OCMockObject partialMockForObject:_client];
    [[[mockClient expect] andForwardToRealObject] connectUser:[OCMArg any] completion:[OCMArg any]];
    [[[mockClient expect] andForwardToRealObject] requestNonceCompletion:[OCMArg any]];
    
    [_client connectUser:[OCMArg any] completion:[OCMArg any]];
    
    [mockClient verify];
}

- (void)testConnectShouldSucceed {
    XCTestExpectation *expectation = [self expectationWithDescription:@"networkCallExpectation"];
    
    [_client connectUser:[_testHelper userID] completion:^(BOOL success, NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue(success);
        [expectation fulfill];
    }];
    
    [self asyncWait];
}

- (void)testRequestConversationShoudlSucceed {
    XCTestExpectation *expectation = [self expectationWithDescription:@"networkCallExpectation"];
    
    [_client connectUser:[_testHelper userID] completion:^(BOOL success, NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue(success);
        
        [_client GETCollectionAtEndpoint:@"conversations" completion:^(NSArray *responseObj, NSError *error) {
            XCTAssertNotNil(responseObj);
            XCTAssertNil(error);
            [expectation fulfill];
        }];
        
        
    }];
    
    [self asyncWait];

}

- (void)asyncWait {
    [self waitForExpectationsWithTimeout:100.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
