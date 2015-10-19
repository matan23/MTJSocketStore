//
//  MTJSocketStoreTests.m
//  MTJSocketStoreTests
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"

#import "MTJLayerKeysHelper.h"
#import "MTJSocketStore.h"
#import "MTJLayerClient.h"

#import "Conversation.h"

#import "PersistentStack.h"

@interface MTJSocketStoreTests : XCTestCase {
    MTJLayerKeysHelper *_testHelper;
    
    MTJSocketStore *_store;
    id _mockClient;
}

@end

@implementation MTJSocketStoreTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _testHelper = [MTJLayerKeysHelper new];
    
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

- (void)testSyncCollectionOfTypeShouldForwardToClient {
    [_store syncCollectionOfType:[OCMArg any] completion:[OCMArg any]];
    
    OCMVerify([_mockClient GETCollectionAtEndpoint:[OCMArg any] completion:[OCMArg any]]);
}

- (void)testSyncCollectionOfTypeShouldSucceed {
    XCTestExpectation *expectation = [self expectationWithDescription:@"networkCallExpectation"];
    
    [_mockClient stopMocking];
    [_store setClient:[MTJLayerClient clientWithAppID:[_testHelper appID]]];
    [_store connectUser:[_testHelper userID] completion:^(BOOL success, NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue(success);
        
        id<MTJSyncedEntity> classFromString = (id<MTJSyncedEntity>)NSClassFromString(@"Conversation");
        assert([classFromString conformsToProtocol:@protocol(MTJSyncedEntity)]);
        
        [_store syncCollectionOfType:classFromString completion:^(NSArray *collection, NSError *error) {
            XCTAssertNil(error);
            XCTAssertNotNil(collection);
            
            [expectation fulfill];

        }];
         
    }];
    
    [self asyncWait];
}

- (void)testSyncCollectionOfTypeWithParentShouldSucceed {
    XCTestExpectation *expectation = [self expectationWithDescription:@"networkCallExpectation"];
    
    [_mockClient stopMocking];
    [_store setClient:[MTJLayerClient clientWithAppID:[_testHelper appID]]];
    [_store connectUser:[_testHelper userID] completion:^(BOOL success, NSError *error) {
        XCTAssertNil(error);
        XCTAssertTrue(success);
//        convID 9df275fa-c306-4316-acd3-a8f49500dd4c
        
        Conversation *conv = [Conversation findOrCreateEntity:@"layer:///conversations/9df275fa-c306-4316-acd3-a8f49500dd4c" inContext:[PersistentStack sharedManager].backgroundManagedObjectContext];

        id<MTJSyncedEntity> message = (id<MTJSyncedEntity>)NSClassFromString(@"Message");
        assert([message conformsToProtocol:@protocol(MTJSyncedEntity)]);
        
        
        [_store syncCollectionOfType:message belongingToType:conv completion:^(NSArray *collection, NSError *error) {
           
            XCTAssertNil(error);
            XCTAssertNotNil(collection);
            
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
