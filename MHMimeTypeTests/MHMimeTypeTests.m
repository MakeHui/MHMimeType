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
    // Fixtures from: https://github.com/sendyhalim/Swime/tree/master/Tests/SwimeTests/fixtures
    NSString *filesDir = @"/Users/imacbook/Developer/MHMimeType/MHMimeTypeTests/fixtures";
    NSArray * dirArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filesDir error:nil];
    for (NSString *file in dirArray) {
        NSString *subPath = [filesDir stringByAppendingPathComponent:file];
        NSArray *info = [file componentsSeparatedByString:@"."];
        if (info.count != 2) continue;
        [self checkFileWithPath:subPath ext:info[1]];
    }
}

- (void)testData
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(150, 150), NO, 0.0);
    UIImage *blankImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    MHMimeTypeModel *pngModel = [[MHMimeType sharedInstance] mimeTypeModelWithData:UIImagePNGRepresentation(blankImage)];
    XCTAssertTrue([pngModel.ext isEqualToString:@"png"], @"warn");
    
    MHMimeTypeModel *jpegModel = [[MHMimeType sharedInstance] mimeTypeModelWithData:UIImageJPEGRepresentation(blankImage, 0.8)];
    XCTAssertTrue([jpegModel.ext isEqualToString:@"jpg"], @"warn");
}

- (void)checkFileWithPath:(NSString *)path ext:(NSString *)ext
{
    if ([ext isEqualToString:@"tif"]) {
        NSLog(@"%@", @"tif");
    }
    MHMimeTypeModel *model = [[MHMimeType sharedInstance] mimeTypeModelWithPath:[NSString stringWithFormat:@"file://%@", path]];
//    MHMimeTypeModel *model = [[MHMimeType sharedInstance] mimeTypeModelWithURL:URL];
//    MHMimeTypeModel *model = [[MHMimeType sharedInstance] mimeTypeModelWithData:data];
    NSLog(@"%@", [NSString stringWithFormat:@"file ext: %@", ext]);
    XCTAssertTrue([model.ext isEqualToString:ext], @"warn");
}

@end
