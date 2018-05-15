//
//  ViewController.m
//  MHMimeTypeDemo
//
//  Created by MakeHui on 2018/5/14.
//  Copyright © 2018年 MakeHui. All rights reserved.
//

#import "ViewController.h"
#import "MHMimeType.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *url = @"file:///Users/MakeHui/Desktop/1.mp4";
    MHMimeType *mimeType = [MHMimeType initWithPath:url];
    
    NSLog(@"%@", mimeType.currentMimeTypeModel.mime);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
