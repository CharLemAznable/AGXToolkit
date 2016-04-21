//
//  UIViewControllerAGXRuntimeTest.m
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/20.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXRuntime.h"

@interface MyView : UIView
@end
@implementation MyView
@end

@interface MyViewController : UIViewController
@property (nonatomic, strong) MyView *view;
@end
@implementation MyViewController
@dynamic view;
@end

@interface UIViewControllerAGXRuntimeTest : XCTestCase

@end

@implementation UIViewControllerAGXRuntimeTest

- (void)testUIViewControllerAGXRuntime {
    UIViewController *controller = [[UIViewController alloc] init];
    XCTAssertTrue(controller.view.class == [UIView class]);

    MyViewController *myController = [[MyViewController alloc] init];
    XCTAssertTrue(myController.view.class == [MyView class]);
}

@end
