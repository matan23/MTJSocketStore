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

- (void)testConnectShouldCallClientConnect {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [_store connectUser:[_testHelper userID] completion:nil];
    OCMVerify([_mockClient connectUser:[_testHelper userID] completion:[OCMArg any]]);
}

@end
