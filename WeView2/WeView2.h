//
//  WeView2.h
//  Unknown Project
//
//  Copyright (c) 2013 Charles Matthew Chen. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIView+WeView2.h"

@class WeView2Layout;

@interface WeView2 : UIView

@property (nonatomic) WeView2Layout *layout;

- (WeView2 *)setHLinearLayout;
- (WeView2 *)setVLinearLayout;
- (WeView2 *)setNoopLayout;

- (WeView2 *)addSubviews:(NSArray *)subviews;
- (void)removeAllSubviews;

@end
