//
//  DemoFactory.h
//  WeViews2DemoApp
//
//  Copyright (c) 2013 Charles Matthew Chen. All rights reserved.
//
//  Distributed under the Apache License v2.0.
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#pragma once

#import <Foundation/Foundation.h>

#import "Demo.h"

@interface DemoFactory : NSObject

+ (NSArray *)allDemos;
+ (Demo *)defaultDemo;

@end
