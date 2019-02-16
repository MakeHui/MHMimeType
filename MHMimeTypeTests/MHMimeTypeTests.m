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

- (void)testExample {
    NSString *filesDir = @"/Users/imacbook/Developer/MHMimeType/MHMimeTypeTests/fixtures";
    NSArray * dirArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filesDir error:nil];
    for (NSString *file in dirArray) {
        NSString *subPath = [filesDir stringByAppendingPathComponent:file];
        NSArray *info = [file componentsSeparatedByString:@"."];
        if (info.count != 2) continue;
        [self checkFileWithPath:subPath ext:info[1]];
    }
}

- (void)checkFileWithPath:(NSString *)path ext:(NSString *)ext
{
    MHMimeTypeModel *model = [[MHMimeType sharedInstance] mimeTypeModelWithPath:[NSString stringWithFormat:@"file://%@", path]];
    NSLog(@"%@", [NSString stringWithFormat:@"file ext: %@", ext]);
    XCTAssertTrue([model.ext isEqualToString:ext], @"warn");
}

@end
