//
//  SidebarViewController.m
//  WeViews2DemoApp
//
//  Copyright (c) 2013 Charles Matthew Chen. All rights reserved.
//
//  Distributed under the Apache License v2.0.
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import "UIView+WeView2.h"
#import "WeView2.h"
#import "SidebarViewController.h"

@interface SidebarViewController ()

@property (nonatomic) WeView2 *rootView;

@end

#pragma mark -

@implementation SidebarViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.selectDemoViewController = [[SelectDemoViewController alloc] init];
        [self addWrappedViewController:self.selectDemoViewController];

        self.viewTreeViewController = [[ViewTreeViewController alloc] init];
        [self addWrappedViewController:self.viewTreeViewController];

        self.viewEditorController = [[ViewEditorController alloc] init];
        [self addWrappedViewController:self.viewEditorController];
    }

    return self;
}

- (void)addWrappedViewController:(UIViewController *)viewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self addChildViewController:navigationController];
}

- (void)loadView
{
    self.rootView = [[[WeView2 alloc] init]
                     useVerticalDefaultLayout];
//    self.rootView.debugLayout = YES;
    self.rootView.opaque = YES;
    self.rootView.backgroundColor = [UIColor whiteColor];
    self.view = self.rootView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *subviews = [NSMutableArray array];
    for (UIViewController *childViewController in self.childViewControllers)
    {
        [subviews addObject:[childViewController.view withPureStretch]];
    }

    [self.rootView addSubviews:subviews];
//    self.rootView.debugLayout = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
