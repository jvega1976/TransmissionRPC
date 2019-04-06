//
//  TransmissionRPCTests.m
//  TransmissionRPCTests
//
//  Created by Johnny Vega on 4/1/19.
//  Copyright © 2019 Johnny Vega. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TransmissionRPC/TransmissionRPC.h>

@interface TransmissionRPCTests : XCTestCase <RPCConnectorDelegate>
@property RPCConnector *connector;
@end

@implementation TransmissionRPCTests


- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSURL *url = [NSURL URLWithString:@"http://jvega:Nmjcup0112*@diskstation.johnnyvega.net:9091/transmission/rpc"];
    [RPCConnector setURL:url requestTimeout:5 andDelegate:self];
    _connector = [RPCConnector sharedConnector];
    _connector.delegate = self;
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    TRInfos *infos = [self.connector returnAllTorrents];
    NSLog(@"%lu Torrents were retuned",infos.items.count);
    XCTAssert(YES);
}

-(void)wait:(id)sender {
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


-(void)connector:(RPCConnector *)cn complitedRequestName:(NSString *)requestName withError:(NSString *)errorMessage {
    NSLog(@"Error: %@",errorMessage);
    XCTAssert(NO);
}
@end

