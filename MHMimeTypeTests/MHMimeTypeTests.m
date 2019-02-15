//
//  MHMimeTypeTests.m
//  MHMimeTypeTests
//
//  Created by MakeHui on 15/2/19.
//  Copyright © 2019年 MakeHui. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MHMimeType/MHMimeType.h>

@interface MHMimeTypeTests : XCTestCase

@end

@implementation MHMimeTypeTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    NSString *path = @"file:///Users/imacbook/Desktop/tmp.mid";
    MHMimeTypeModel *model = [[MHMimeType sharedInstance] mimeTypeModelWithPath:path];
    
    XCTAssertTrue([model.ext isEqualToString:@"mid"], @"not midi file.");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
