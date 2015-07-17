//
//  ViewEditorController.m
//  WeView v2
//
//  Copyright (c) 2014 Charles Matthew Chen. All rights reserved.
//
//  Distributed under the Apache License v2.0.
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <QuartzCore/QuartzCore.h>

#import "DemoFactory.h"
#import "DemoMacros.h"
#import "UIView+WeView.h"
#import "ViewEditorController.h"
#import "WeViewDemoConstants.h"
#import "WeViewLayout+Subclass.h"
#import "WeViewMacros.h"

@interface WeView (ViewEditorController)

- (WeViewLayout *)replaceLayoutWithHorizontalLayout:(WeViewLayout *)layout;
- (WeViewLayout *)replaceLayoutWithVerticalLayout:(WeViewLayout *)layout;
- (WeViewLayout *)replaceLayoutWithStackLayout:(WeViewLayout *)layout;
- (WeViewLayout *)replaceLayoutWithFlowLayout:(WeViewLayout *)layout;
- (WeViewLayout *)replaceLayoutWithGridLayout:(WeViewLayout *)layout;

@end

@interface WeViewLayout (ViewEditorController)

- (WeView *)superview;

@end

#pragma mark -

@protocol ViewParameterDelegate <NSObject>

- (void)viewChanged;

@end

#pragma mark -

@interface ViewParameter : NSObject

@property (nonatomic, weak) id<ViewParameterDelegate> delegate;

@end

#pragma mark -

@implementation ViewParameter

- (void)configureCell:(UITableViewCell *)cell
             withItem:(id)item
{
    WeViewAssert(0);
}

@end

#pragma mark -

typedef NSString *(^GetterBlock)(id item);
typedef void (^SetterBlock)(id item);

@interface ViewParameterSetter : NSObject

@property (nonatomic) NSString *name;
@property (copy, nonatomic) SetterBlock setterBlock;
@property (nonatomic) id item;
@property (nonatomic, weak) id<ViewParameterDelegate> delegate;

@end

#pragma mark -

@implementation ViewParameterSetter

+ (ViewParameterSetter *)create:(NSString *)name
                    setterBlock:(SetterBlock)setterBlock
{
    ViewParameterSetter *result = [[ViewParameterSetter alloc] init];
    result.name = name;
    result.setterBlock = setterBlock;
    return result;
}

- (void)perform:(id)sender
{
    ViewParameterSetter *strongSelf = self;
    strongSelf.setterBlock(strongSelf.item);
//    [self.view setNeedsLayout];
//    [self.view.superview setNeedsLayout];
    [strongSelf.delegate viewChanged];
}

@end

#pragma mark -

@interface ViewParameterSimple : ViewParameter

@property (nonatomic) NSString *name;
@property (copy, nonatomic) GetterBlock getterBlock;
@property (copy, nonatomic) NSArray *setters;
@property (nonatomic) BOOL doubleHeight;

@end

#pragma mark -

@implementation ViewParameterSimple

+ (ViewParameterSimple *)create:(NSString *)name
                    getterBlock:(GetterBlock)getterBlock
                        setters:(NSArray *)setters
{
    return [self create:name
            getterBlock:getterBlock
                setters:setters
           doubleHeight:NO];
}

+ (ViewParameterSimple *)create:(NSString *)name
                    getterBlock:(GetterBlock)getterBlock
                        setters:(NSArray *)setters
                   doubleHeight:(BOOL)doubleHeight
{
    ViewParameterSimple *result = [[ViewParameterSimple alloc] init];
    result.name = name;
    result.getterBlock = getterBlock;
    result.setters = setters;
    result.doubleHeight = doubleHeight;
    return result;
}

- (void)configureCell:(UITableViewCell *)cell
             withItem:(id)item
{
    WeView *container = [[WeView alloc] init];
    container.backgroundColor = [UIColor clearColor];
    container.opaque = NO;
    [cell addSubview:container];
    container.frame = cell.bounds;

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.opaque = NO;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold"
                                     size:14];
    nameLabel.text = [NSString stringWithFormat:@"%@:", self.name];

    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.backgroundColor = [UIColor clearColor];
    valueLabel.opaque = NO;
    valueLabel.textColor = [UIColor blackColor];
    valueLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold"
                                      size:14];
    valueLabel.text = self.getterBlock(item);

    NSMutableArray *subviews = [@[
                                nameLabel,
                                valueLabel,
                                ] mutableCopy];

    NSMutableArray *setterViews = [NSMutableArray array];
    for (ViewParameterSetter *setter in self.setters)
    {
        setter.item = item;
        setter.delegate = self.delegate;

        UIButton *setterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        setterButton.opaque = NO;
        setterButton.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.f];
        setterButton.layer.cornerRadius = 5.f;
        setterButton.contentEdgeInsets = UIEdgeInsetsMake(3, 5, 2, 5);
        [setterButton setTitle:setter.name forState:UIControlStateNormal];
        [setterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [setterButton setTitleColor:[UIColor colorWithWhite:0.5f
                                                      alpha:1.f]
                           forState:UIControlStateHighlighted];

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.f, 1.f), NO, 1.f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor colorWithWhite:0.25f alpha:1.f] setFill];
        CGContextFillRect(context, CGRectMake(0.f, 0.f, 1.f, 1.f));
        UIImage *highlightBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [setterButton setBackgroundImage:highlightBackgroundImage
                                forState:UIControlStateHighlighted];
        setterButton.clipsToBounds = YES;

        //        setterButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        setterButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold"
                                                       size:14];
        [setterButton addTarget:setter
                         action:@selector(perform:)
               forControlEvents:UIControlEventTouchUpInside];
        [setterViews addObject:setterButton];
    }

    if (self.doubleHeight)
    {
        WeView *topPanel = [[WeView alloc] init];
        topPanel.backgroundColor = [UIColor clearColor];
        topPanel.opaque = NO;
        [[[topPanel addSubviewsWithHorizontalLayout:subviews]
          setHAlign:H_ALIGN_LEFT]
         setSpacing:4];

        WeView *bottomPanel = [[WeView alloc] init];
        bottomPanel.backgroundColor = [UIColor clearColor];
        bottomPanel.opaque = NO;
        [[[bottomPanel addSubviewsWithHorizontalLayout:setterViews]
          setHAlign:H_ALIGN_RIGHT]
         setSpacing:4];

        [[[[container addSubviewsWithVerticalLayout:@[
                                                   [topPanel setHStretches],
            [bottomPanel setHStretches], ]]
           setHMargin:10]
          setVMargin:2]
         setSpacing:4];
    }
    else
    {
        [subviews addObject: [[[UIView alloc] init] setStretchesIgnoringDesiredSize]];
        [subviews addObjectsFromArray:setterViews];
        [[[[[container addSubviewsWithHorizontalLayout:subviews]
            setHAlign:H_ALIGN_LEFT]
           setHMargin:10]
          setVMargin:2]
         setSpacing:4];
    }

    cell.height = container.height = [container sizeThatFits:CGSizeMake(cell.width, CGFLOAT_MAX)].height;
}

+ (ViewParameterSimple *)booleanProperty:(NSString *)name
{
    return [ViewParameterSimple create:name
                           getterBlock:^NSString *(UIView *view) {
                               BOOL value = [[view valueForKey:name] boolValue];
                               return FormatBoolean(value);
                           }
                               setters:@[
            [ViewParameterSetter create:@"YES"
                            setterBlock:^(UIView *view) {
                                [view setValue:@(YES) forKey:name];
                            }
             ],
            [ViewParameterSetter create:@"NO"
                            setterBlock:^(UIView *view) {
                                [view setValue:@(NO) forKey:name];
                            }
             ],
            ]];
}

+ (ViewParameterSimple *)floatProperty:(NSString *)name
{
    return [self floatProperty:name
                  doubleHeight:NO];
}

+ (ViewParameterSimple *)floatProperty:(NSString *)name
                          doubleHeight:(BOOL)doubleHeight
{
    return [ViewParameterSimple create:name
                           getterBlock:^NSString *(UIView *view) {
                               CGFloat value = [[view valueForKey:name] floatValue];
                               return FormatFloat(value);
                           }
                               setters:@[
            [ViewParameterSetter create:@"-5"
                            setterBlock:^(UIView *view) {
                                CGFloat value = [[view valueForKey:name] floatValue];
                                [view setValue:@(value - 5) forKey:name];
                            }],
            [ViewParameterSetter create:@"-1"
                            setterBlock:^(UIView *view) {
                                CGFloat value = [[view valueForKey:name] floatValue];
                                [view setValue:@(value - 1) forKey:name];
                            }],
            [ViewParameterSetter create:@"0"
                            setterBlock:^(UIView *view) {
                                [view setValue:@(0.f) forKey:name];
                            }],
            [ViewParameterSetter create:@"+1"
                            setterBlock:^(UIView *view) {
                                CGFloat value = [[view valueForKey:name] floatValue];
                                [view setValue:@(value + 1) forKey:name];
                            }],
            [ViewParameterSetter create:@"+5"
                            setterBlock:^(UIView *view) {
                                CGFloat value = [[view valueForKey:name] floatValue];
                                [view setValue:@(value + 5) forKey:name];
                            }
             ],
            ]
                          doubleHeight:doubleHeight];
}

+ (ViewParameterSimple *)intProperty:(NSString *)name
{
    return [self intProperty:name
                doubleHeight:NO];
}

+ (ViewParameterSimple *)intProperty:(NSString *)name
                        doubleHeight:(BOOL)doubleHeight
{
    return [ViewParameterSimple create:name
                           getterBlock:^NSString *(UIView *view) {
                               int value = [[view valueForKey:name] intValue];
                               return FormatInt(value);
                           }
                               setters:@[
            [ViewParameterSetter create:@"-5"
                            setterBlock:^(UIView *view) {
                                int value = [[view valueForKey:name] intValue];
                                [view setValue:@(value - 5) forKey:name];
                            }],
            [ViewParameterSetter create:@"-1"
                            setterBlock:^(UIView *view) {
                                int value = [[view valueForKey:name] intValue];
                                [view setValue:@(value - 1) forKey:name];
                            }],
            [ViewParameterSetter create:@"0"
                            setterBlock:^(UIView *view) {
                                [view setValue:@(0) forKey:name];
                            }],
            [ViewParameterSetter create:@"+1"
                            setterBlock:^(UIView *view) {
                                int value = [[view valueForKey:name] intValue];
                                [view setValue:@(value + 1) forKey:name];
                            }],
            [ViewParameterSetter create:@"+5"
                            setterBlock:^(UIView *view) {
                                int value = [[view valueForKey:name] intValue];
                                [view setValue:@(value + 5) forKey:name];
                            }
             ],
            ]
                          doubleHeight:doubleHeight];
}

@end

#pragma mark -

@interface ViewEditorController () <ViewParameterDelegate>

@property (nonatomic) NSArray *viewParams;

@property (nonatomic) id currentItem;

@end

#pragma mark -

@implementation ViewEditorController

- (CGFloat)UIColorAlpha:(UIColor *)color
{
    CGFloat alpha, red, green, blue;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return alpha;
}

- (unsigned int)UIColorToArgb:(UIColor *)color
{
    CGFloat alpha, red, green, blue;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    unsigned int argb = (((0xff & (unsigned int) roundf(alpha * 255.f)) << 24) |
                         ((0xff & (unsigned int) roundf(red * 255.f)) << 16) |
                         ((0xff & (unsigned int) roundf(green * 255.f)) << 8) |
                         ((0xff & (unsigned int) roundf(blue * 255.f)) << 0));
    return argb;
}

- (NSString *)FormatUIColor:(UIColor *)color
{
    return [NSString stringWithFormat:@"0x%08X", [self UIColorToArgb:color]];
}

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.title = NSLocalizedString(@"View Config", nil);
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.clearsSelectionOnViewWillAppear = NO;
        }
        [self updateParameters];

        //        self.tableView.rowHeight = 25;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.sectionHeaderHeight = 10;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSelectionChanged:)
                                                     name:NOTIFICATION_SELECTION_CHANGED
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleItemAdded:)
                                                     name:NOTIFICATION_ITEM_ADDED
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateParameters
{
    if ([self.currentItem isKindOfClass:[UIView class]])
    {
        self.viewParams = @[
                            [ViewParameterSimple create:@"class"
                                            getterBlock:^NSString *(UIView *view) {
                                                return [[view class] description];
                                            }
                                                setters:@[
                             [ViewParameterSetter create:@"Delete"
                                             setterBlock:^(UIView *view) {
                                                 [view removeFromSuperview];
                                             }],
                             ]],
                            [ViewParameterSimple create:@"frame"
                                            getterBlock:^NSString *(UIView *view) {
                                                return FormatCGRect(view.frame);
                                            }
                                                setters:@[]],
                            [ViewParameterSimple create:@"desired size"
                                            getterBlock:^NSString *(UIView *view) {
                                                return FormatCGSize([view sizeThatFits:CGSizeZero]);
                                            }
                                                setters:@[
                             [ViewParameterSetter create:@"Set"
                                             setterBlock:^(UIView *view) {
                                                 CGPoint center = view.center;
                                                 view.size = [view sizeThatFits:CGSizeZero];
                                                 view.center = center;
                                             }],
                             ]],

                            [ViewParameterSimple create:@"background"
                                            getterBlock:^NSString *(UIView *view) {
                                                if (view.backgroundColor &&
                                                    [self UIColorAlpha:view.backgroundColor] > 0)
                                                {
                                                    return [self FormatUIColor:view.backgroundColor];
                                                }
                                                return @"None";
                                            }
                                                setters:@[
                             [ViewParameterSetter create:@"Clear"
                                             setterBlock:^(UIView *view) {
                                                 view.backgroundColor = [UIColor clearColor];
                                                 view.opaque = NO;
                                             }],
                             [ViewParameterSetter create:@"Random"
                                             setterBlock:^(UIView *view) {
                                                 [DemoFactory assignRandomBackgroundColor:view];
                                                 view.opaque = NO;
                                             }],
                             [ViewParameterSetter create:@"0.25"
                                             setterBlock:^(UIView *view) {
                                                 view.backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.f];
                                                 view.opaque = NO;
                                             }],
                             [ViewParameterSetter create:@"0.5"
                                             setterBlock:^(UIView *view) {
                                                 view.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.f];
                                                 view.opaque = NO;
                                             }],
                             [ViewParameterSetter create:@"0.75"
                                             setterBlock:^(UIView *view) {
                                                 view.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.f];
                                                 view.opaque = NO;
                                             }],
                             [ViewParameterSetter create:@"1."
                                             setterBlock:^(UIView *view) {
                                                 view.backgroundColor = [UIColor colorWithWhite:1.f alpha:1.f];
                                                 view.opaque = NO;
                                             }],
                             ] doubleHeight:YES],

                            [ViewParameterSimple create:@"border"
                                            getterBlock:^NSString *(UIView *view) {
                                                if (view.layer.borderColor &&
                                                    view.layer.borderWidth > 0)
                                                {
                                                    return [NSString stringWithFormat:@"%0.1fpt %@",
                                                            view.layer.borderWidth,
                                                            [self FormatUIColor:[UIColor colorWithCGColor:view.layer.borderColor]]];
                                                }
                                                return @"None";
                                            }
                                                setters:@[
                             [ViewParameterSetter create:@"Clear"
                                             setterBlock:^(UIView *view) {
                                                 view.layer.borderColor = nil;
                                                 view.layer.borderWidth = 0.f;
                                             }],
                             [ViewParameterSetter create:@"Random"
                                             setterBlock:^(UIView *view) {
                                                 view.layer.borderColor = [DemoFactory randomForegroundColor].CGColor;
                                                 view.layer.borderWidth = 1.f;
                                             }],
                             [ViewParameterSetter create:@"Yellow"
                                             setterBlock:^(UIView *view) {
                                                 view.layer.borderColor = [UIColor yellowColor].CGColor;
                                                 view.layer.borderWidth = 1.f;
                                             }],
                             ] doubleHeight:YES],

                            [ViewParameterSimple booleanProperty:@"hidden"],
                            [ViewParameterSimple booleanProperty:@"opaque"],
                            [ViewParameterSimple booleanProperty:@"clipsToBounds"],

                            /* CODEGEN MARKER: View Parameters Start */

                                [ViewParameterSimple floatProperty:@"minDesiredWidth"],

                                [ViewParameterSimple floatProperty:@"maxDesiredWidth"],

                                [ViewParameterSimple floatProperty:@"minDesiredHeight"],

                                [ViewParameterSimple floatProperty:@"maxDesiredHeight"],

                                [ViewParameterSimple floatProperty:@"hStretchWeight"],

                                [ViewParameterSimple floatProperty:@"vStretchWeight"],

                                [ViewParameterSimple intProperty:@"leftSpacingAdjustment" doubleHeight:YES],

                                [ViewParameterSimple intProperty:@"topSpacingAdjustment" doubleHeight:YES],

                                [ViewParameterSimple intProperty:@"rightSpacingAdjustment" doubleHeight:YES],

                                [ViewParameterSimple intProperty:@"bottomSpacingAdjustment" doubleHeight:YES],

                                [ViewParameterSimple floatProperty:@"desiredWidthAdjustment" doubleHeight:YES],

                                [ViewParameterSimple floatProperty:@"desiredHeightAdjustment" doubleHeight:YES],

                                [ViewParameterSimple booleanProperty:@"ignoreDesiredWidth"],

                                [ViewParameterSimple booleanProperty:@"ignoreDesiredHeight"],

                                [ViewParameterSimple create:@"cellHAlign"
                                                getterBlock:^NSString *(id item) {
                                                    return FormatHAlign(((UIView *) item).cellHAlign);
                                                }
                                                    setters:@[
                                 [ViewParameterSetter create:@"Left"
                                                 setterBlock:^(id item) {
                                                     ((UIView *) item).cellHAlign = H_ALIGN_LEFT;
                                                 }],
                                 [ViewParameterSetter create:@"Center"
                                                 setterBlock:^(id item) {
                                                     ((UIView *) item).cellHAlign = H_ALIGN_CENTER;
                                                 }],
                                 [ViewParameterSetter create:@"Right"
                                                 setterBlock:^(id item) {
                                                     ((UIView *) item).cellHAlign = H_ALIGN_RIGHT;
                                                 }],
                                 ]
                                 doubleHeight:YES],
                                 

                                [ViewParameterSimple create:@"cellVAlign"
                                                getterBlock:^NSString *(id item) {
                                                    return FormatVAlign(((UIView *) item).cellVAlign);
                                                }
                                                    setters:@[
                                 [ViewParameterSetter create:@"Top"
                                                 setterBlock:^(id item) {
                                                     ((UIView *) item).cellVAlign = V_ALIGN_TOP;
                                                 }],
                                 [ViewParameterSetter create:@"Center"
                                                 setterBlock:^(id item) {
                                                     ((UIView *) item).cellVAlign = V_ALIGN_CENTER;
                                                 }],
                                 [ViewParameterSetter create:@"Bottom"
                                                 setterBlock:^(id item) {
                                                     ((UIView *) item).cellVAlign = V_ALIGN_BOTTOM;
                                                 }],
                                 ]
                                 doubleHeight:YES],
                                 

                                [ViewParameterSimple booleanProperty:@"hasCellHAlign"],

                                [ViewParameterSimple booleanProperty:@"hasCellVAlign"],

                                [ViewParameterSimple booleanProperty:@"skipLayout"],

/* CODEGEN MARKER: View Parameters End */
                            ];
    }
    else if ([self.currentItem isKindOfClass:[WeViewLayout class]])
    {
        __weak ViewEditorController *weakSelf = self;
        self.viewParams = @[
                            [ViewParameterSimple create:@"class"
                                            getterBlock:^NSString *(UIView *view) {
                                                return [[view class] description];
                                            }
                                                setters:@[
                             [ViewParameterSetter create:@"Horizontal"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 WeViewLayout *newLayout = [layout.superview replaceLayoutWithHorizontalLayout:layout];
                                                 [weakSelf postSelectionChanged:newLayout];
                                             }],
                             [ViewParameterSetter create:@"Vertical"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 WeViewLayout *newLayout = [layout.superview replaceLayoutWithVerticalLayout:layout];
                                                 [weakSelf postSelectionChanged:newLayout];
                                             }],
                             [ViewParameterSetter create:@"Stack"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 WeViewLayout *newLayout = [layout.superview replaceLayoutWithStackLayout:layout];
                                                 [weakSelf postSelectionChanged:newLayout];
                                             }],
                             [ViewParameterSetter create:@"Flow"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 WeViewLayout *newLayout = [layout.superview replaceLayoutWithFlowLayout:layout];
                                                 [weakSelf postSelectionChanged:newLayout];
                                             }],
                             [ViewParameterSetter create:@"Grid"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 WeViewLayout *newLayout = [layout.superview replaceLayoutWithGridLayout:layout];
                                                 [weakSelf postSelectionChanged:newLayout];
                                             }],
                             ]
                                           doubleHeight:YES],

                            [ViewParameterSimple create:@"margin"
                                            getterBlock:^NSString *(UIView *view) {
                                                return @"";
                                            }
                                                setters:@[
                             [ViewParameterSetter create:@"0"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 [layout setMargin:0];
                                             }],
                             [ViewParameterSetter create:@"+5"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 [layout setMargin:+5];
                                             }],
                             [ViewParameterSetter create:@"+10"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 [layout setMargin:+10];
                                             }],
                             [ViewParameterSetter create:@"+15"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 [layout setMargin:+15];
                                             }],
                             [ViewParameterSetter create:@"+20"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 [layout setMargin:+20];
                                             }],
                             ]],

                            [ViewParameterSimple create:@"spacing"
                                            getterBlock:^NSString *(UIView *view) {
                                                return @"";
                                            }
                                                setters:@[
                             [ViewParameterSetter create:@"0"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 [layout setSpacing:0];
                                             }],
                             [ViewParameterSetter create:@"+5"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 [layout setSpacing:+5];
                                             }],
                             [ViewParameterSetter create:@"+10"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 [layout setSpacing:+10];
                                             }],
                             [ViewParameterSetter create:@"+15"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 [layout setSpacing:+15];
                                             }],
                             [ViewParameterSetter create:@"+20"
                                             setterBlock:^(id item) {
                                                 WeViewLayout *layout = item;
                                                 [layout setSpacing:+20];
                                             }],
                             ]],

                            /* CODEGEN MARKER: Layout Parameters Start */

                                [ViewParameterSimple floatProperty:@"leftMargin"],

                                [ViewParameterSimple floatProperty:@"rightMargin"],

                                [ViewParameterSimple floatProperty:@"topMargin"],

                                [ViewParameterSimple floatProperty:@"bottomMargin"],

                                [ViewParameterSimple intProperty:@"vSpacing"],

                                [ViewParameterSimple intProperty:@"hSpacing"],

                                [ViewParameterSimple create:@"hAlign"
                                                getterBlock:^NSString *(id item) {
                                                    return FormatHAlign(((WeViewLayout *) item).hAlign);
                                                }
                                                    setters:@[
                                 [ViewParameterSetter create:@"Left"
                                                 setterBlock:^(id item) {
                                                     ((WeViewLayout *) item).hAlign = H_ALIGN_LEFT;
                                                 }],
                                 [ViewParameterSetter create:@"Center"
                                                 setterBlock:^(id item) {
                                                     ((WeViewLayout *) item).hAlign = H_ALIGN_CENTER;
                                                 }],
                                 [ViewParameterSetter create:@"Right"
                                                 setterBlock:^(id item) {
                                                     ((WeViewLayout *) item).hAlign = H_ALIGN_RIGHT;
                                                 }],
                                 ]
                                 doubleHeight:YES],
                                 

                                [ViewParameterSimple create:@"vAlign"
                                                getterBlock:^NSString *(id item) {
                                                    return FormatVAlign(((WeViewLayout *) item).vAlign);
                                                }
                                                    setters:@[
                                 [ViewParameterSetter create:@"Top"
                                                 setterBlock:^(id item) {
                                                     ((WeViewLayout *) item).vAlign = V_ALIGN_TOP;
                                                 }],
                                 [ViewParameterSetter create:@"Center"
                                                 setterBlock:^(id item) {
                                                     ((WeViewLayout *) item).vAlign = V_ALIGN_CENTER;
                                                 }],
                                 [ViewParameterSetter create:@"Bottom"
                                                 setterBlock:^(id item) {
                                                     ((WeViewLayout *) item).vAlign = V_ALIGN_BOTTOM;
                                                 }],
                                 ]
                                 doubleHeight:YES],
                                 

                                [ViewParameterSimple booleanProperty:@"cropSubviewOverflow"],

                                [ViewParameterSimple create:@"cellPositioning"
                                                getterBlock:^NSString *(id item) {
                                                    return FormatCellPositioningMode(((WeViewLayout *) item).cellPositioning);
                                                }
                                                    setters:@[
                                 [ViewParameterSetter create:FormatCellPositioningMode(CELL_POSITIONING_NORMAL)
                                                 setterBlock:^(id item) {
                                                     ((WeViewLayout *) item).cellPositioning = CELL_POSITIONING_NORMAL;
                                                 }],
                                 [ViewParameterSetter create:FormatCellPositioningMode(CELL_POSITIONING_FILL)
                                                 setterBlock:^(id item) {
                                                     ((WeViewLayout *) item).cellPositioning = CELL_POSITIONING_FILL;
                                                 }],
                                 [ViewParameterSetter create:FormatCellPositioningMode(CELL_POSITIONING_FILL_W_ASPECT_RATIO)
                                                 setterBlock:^(id item) {
                                                     ((WeViewLayout *) item).cellPositioning = CELL_POSITIONING_FILL_W_ASPECT_RATIO;
                                                 }],
                                 [ViewParameterSetter create:FormatCellPositioningMode(CELL_POSITIONING_FIT_W_ASPECT_RATIO)
                                                 setterBlock:^(id item) {
                                                     ((WeViewLayout *) item).cellPositioning = CELL_POSITIONING_FIT_W_ASPECT_RATIO;
                                                 }],
                                 ]
                                 doubleHeight:YES],
                                 

                                [ViewParameterSimple booleanProperty:@"debugLayout"],

                                [ViewParameterSimple booleanProperty:@"debugMinSize"],

/* CODEGEN MARKER: Layout Parameters End */
                            ];
    }
    else
    {
        self.viewParams = @[];
    }
}

- (void)handleItemAdded:(NSNotification *)notification
{
    //    NSLog(@"tree handleItemAdded: %@", notification.object);
    self.currentItem = notification.object;
    [self updateParameters];
    [self updateContent];
}

- (void)handleSelectionChanged:(NSNotification *)notification
{
    //    NSLog(@"tree handleSelectionChanged");
    self.currentItem = notification.object;
    [self updateParameters];
    [self updateContent];
}

- (void)viewChanged
{
    [self updateContent];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SELECTION_ALTERED
                                                        object:self.currentItem];
}

- (void)updateContent
{
    [self.tableView reloadData];
    //    [super viewDidLoad];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.currentItem ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewParams.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Do not reuse cells until we determine a maintainable way to clear their contents.
//    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }

//    for (UIView *subview in cell.subviews)
//    {
//        if ([subview isKindOfClass:[WeView class]])
//        {
//            [subview removeFromSuperview];
//        }
//    }

    ViewParameter *viewParameter = self.viewParams[indexPath.row];
    viewParameter.delegate = self;
    [viewParameter configureCell:cell
                        withItem:self.currentItem];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    //    Class clazz = self.demoClasses[indexPath.row];
    //    Demo *demo = [[clazz alloc] init];
    //    [self.delegate demoSelected:demo];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@" \t heightForRowAtIndexPath: %f", [self tableView:tableView cellForRowAtIndexPath:indexPath].height);
    return [self tableView:tableView cellForRowAtIndexPath:indexPath].height;
}

#pragma mark -

- (void)postSelectionChanged:(id)newItem
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SET_SELECTION_TO
                                                        object:newItem];
}

@end
