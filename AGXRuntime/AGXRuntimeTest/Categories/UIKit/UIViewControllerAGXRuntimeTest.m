//
//  UIViewControllerAGXRuntimeTest.m
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/20.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
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
    UIViewController *controller = UIViewController.instance;
    XCTAssertTrue(controller.view.class == [UIView class]);

    MyViewController *myController = MyViewController.instance;
    XCTAssertTrue(myController.view.class == [MyView class]);
}

@end
