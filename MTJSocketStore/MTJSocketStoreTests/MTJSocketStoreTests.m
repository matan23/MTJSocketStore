//
//  MTJSocketStoreTests.m
//  MTJSocketStoreTests
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "MTJTestHelper.h"
#import "MTJSocketStore.h"
#import "MTJLayerClient.h"

@interface MTJSocketStoreTests : XCTestCase {
    MTJTestHelper *_testHelper;
    
    MTJSocketStore *_store;
    id _mockClient;
}

@end

@implementation MTJSocketStoreTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _testHelper = [MTJTestHelper new];
    
    _store = [MTJSocketStore sharedStore];
  
    _mockClient = OCMClassMock([MTJLayerClient class]);
    [OCMStub(ClassMethod([_mockClient clientWithAppID:[_testHelper appID]])) andReturn:_mockClient];
    [_store setClient:_mockClient];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [_mockClient stopMocking];
    [super tearDown];
}

- (void)testConnectShouldForwardToClient {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [_store connectUser:[_testHelper userID] completion:nil];
    OCMVerify([_mockClient connectUser:[_testHelper userID] completion:[OCMArg any]]);
}

- (void)testGetAllConversationsShouldForwardToClient {
    [_store getAllConversationsCompletion:[OCMArg any]];
    
    OCMVerify([_mockClient GETCollectionAtEndpoint:[OCMArg any] completion:[OCMArg any]]);
}

- (void)testGetAllConversationsShouldFeedCoreData {
    XCTestExpectation *expectation = [self expectationWithDescription:@"networkCallExpectation"];
    
    [_mockClient stopMocking];
    [_store setClient:[MTJLayerClient clientWithAppID:[_testHelper appID]]];
    [_store connectUser:[_testHelper userID] completion:^(BOOL success, NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue(success);
        [_store getAllConversationsCompletion:^(NSArray *conversations, NSError *error) {
            XCTAssertNil(error);
            XCTAssertNotNil(conversations);
            
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

- (void)testDate {
//    2015-10-12T17:58:34.026Z
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormat dateFromString:@"2015-10-12T17:58:34.026Z"];
    XCTAssertNotNil(date);
}


@end
