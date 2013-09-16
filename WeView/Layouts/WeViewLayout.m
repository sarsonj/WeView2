//
//  WeViewLayout.m
//  Unknown Project
//
//  Copyright (c) 2013 Charles Matthew Chen. All rights reserved.
//
//  Distributed under the Apache License v2.0.
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <QuartzCore/QuartzCore.h>

#import "UIView+WeView.h"
#import "WeView.h"
#import "WeViewLinearLayout.h"
#import "WeViewMacros.h"

@interface WeViewLayout ()
{
/* CODEGEN MARKER: Members Start */

CGFloat _leftMargin;
CGFloat _rightMargin;
CGFloat _topMargin;
CGFloat _bottomMargin;

CGFloat _vSpacing;
CGFloat _hSpacing;

HAlign _hAlign;
VAlign _vAlign;

BOOL _cropSubviewOverflow;
CellPositioningMode _cellPositioning;

BOOL _debugLayout;
BOOL _debugMinSize;

/* CODEGEN MARKER: Members End */
}

@property (nonatomic) WeView *_superview;

@end

#pragma mark -

@implementation WeViewLayout

- (id)init
{
    if (self = [super init])
    {
        _hAlign = H_ALIGN_CENTER;
        _vAlign = V_ALIGN_CENTER;

        _cropSubviewOverflow = YES;
    }

    return self;
}

- (void)dealloc
{
}

- (void)layoutContentsOfView:(UIView *)view
                    subviews:(NSArray *)subviews
{
    assert(0);
}

- (CGSize)minSizeOfContentsView:(UIView *)view
                       subviews:(NSArray *)subviews
                   thatFitsSize:(CGSize)guideSize
{
    assert(0);
    return CGSizeZero;
}

#pragma mark - Per-Layout Properties

/* CODEGEN MARKER: Accessors Start */

- (CGFloat)leftMargin
{
    return _leftMargin;
}

- (WeViewLayout *)setLeftMargin:(CGFloat)value
{
    _leftMargin = value;
    [self._superview setNeedsLayout];
    return self;
}

- (CGFloat)rightMargin
{
    return _rightMargin;
}

- (WeViewLayout *)setRightMargin:(CGFloat)value
{
    _rightMargin = value;
    [self._superview setNeedsLayout];
    return self;
}

- (CGFloat)topMargin
{
    return _topMargin;
}

- (WeViewLayout *)setTopMargin:(CGFloat)value
{
    _topMargin = value;
    [self._superview setNeedsLayout];
    return self;
}

- (CGFloat)bottomMargin
{
    return _bottomMargin;
}

- (WeViewLayout *)setBottomMargin:(CGFloat)value
{
    _bottomMargin = value;
    [self._superview setNeedsLayout];
    return self;
}

- (CGFloat)vSpacing
{
    return _vSpacing;
}

- (WeViewLayout *)setVSpacing:(CGFloat)value
{
    _vSpacing = value;
    [self._superview setNeedsLayout];
    return self;
}

- (CGFloat)hSpacing
{
    return _hSpacing;
}

- (WeViewLayout *)setHSpacing:(CGFloat)value
{
    _hSpacing = value;
    [self._superview setNeedsLayout];
    return self;
}

- (HAlign)hAlign
{
    return _hAlign;
}

- (WeViewLayout *)setHAlign:(HAlign)value
{
    _hAlign = value;
    [self._superview setNeedsLayout];
    return self;
}

- (VAlign)vAlign
{
    return _vAlign;
}

- (WeViewLayout *)setVAlign:(VAlign)value
{
    _vAlign = value;
    [self._superview setNeedsLayout];
    return self;
}

- (BOOL)cropSubviewOverflow
{
    return _cropSubviewOverflow;
}

- (WeViewLayout *)setCropSubviewOverflow:(BOOL)value
{
    _cropSubviewOverflow = value;
    [self._superview setNeedsLayout];
    return self;
}

- (CellPositioningMode)cellPositioning
{
    return _cellPositioning;
}

- (WeViewLayout *)setCellPositioning:(CellPositioningMode)value
{
    _cellPositioning = value;
    [self._superview setNeedsLayout];
    return self;
}

- (BOOL)debugLayout
{
    return _debugLayout;
}

- (WeViewLayout *)setDebugLayout:(BOOL)value
{
    _debugLayout = value;
    [self._superview setNeedsLayout];
    return self;
}

- (BOOL)debugMinSize
{
    return _debugMinSize;
}

- (WeViewLayout *)setDebugMinSize:(BOOL)value
{
    _debugMinSize = value;
    [self._superview setNeedsLayout];
    return self;
}

- (WeViewLayout *)setHMargin:(CGFloat)value
{
    [self setLeftMargin:value];
    [self setRightMargin:value];
    [self._superview setNeedsLayout];
    return self;
}

- (WeViewLayout *)setVMargin:(CGFloat)value
{
    [self setTopMargin:value];
    [self setBottomMargin:value];
    [self._superview setNeedsLayout];
    return self;
}

- (WeViewLayout *)setMargin:(CGFloat)value
{
    [self setLeftMargin:value];
    [self setRightMargin:value];
    [self setTopMargin:value];
    [self setBottomMargin:value];
    [self._superview setNeedsLayout];
    return self;
}

- (WeViewLayout *)setSpacing:(CGFloat)value
{
    [self setHSpacing:value];
    [self setVSpacing:value];
    [self._superview setNeedsLayout];
    return self;
}

/* CODEGEN MARKER: Accessors End */

#pragma mark - Utility Methods

- (void)bindToSuperview:(WeView *)superview
{
    // Layouts should not be shared or re-used.
    WeViewAssert(superview);
    WeViewAssert(!self._superview);
    self._superview = superview;
}

- (WeView *)superview
{
    WeViewAssert(self._superview != nil);
    return self._superview;
}

- (HAlign)subviewCellHAlign:(UIView *)superview
                    subview:(UIView *)subview
{
    if (subview.hasCellHAlign)
    {
        return subview.cellHAlign;
    }
    return _hAlign;
}

- (VAlign)subviewCellVAlign:(UIView *)view
                    subview:(UIView *)subview
{
    if (subview.hasCellVAlign)
    {
        return subview.cellVAlign;
    }
    return _vAlign;
}

- (void)positionSubview:(UIView *)subview
            inSuperview:(UIView *)superview
               withSize:(CGSize)subviewSize
           inCellBounds:(CGRect)cellBounds
        cellPositioning:(CellPositioningMode)cellPositioning
{
    switch (cellPositioning)
    {
        case CELL_POSITION_NORMAL:
        {
            if (subview.hStretchWeight > 0)
            {
                subviewSize.width = cellBounds.size.width;
            }
            if (subview.vStretchWeight > 0)
            {
                subviewSize.height = cellBounds.size.height;
            }

            subviewSize = CGSizeMax(CGSizeZero, CGSizeFloor(subviewSize));
            subview.frame = alignSizeWithinRect(subviewSize,
                                                cellBounds,
                                                [self subviewCellHAlign:superview
                                                                subview:subview],
                                                [self subviewCellVAlign:superview
                                                                subview:subview]);
            break;
        }
        case CELL_POSITION_FILL:
        {
            CGRect subviewFrame = cellBounds;
            subviewFrame.origin = CGPointRound(subviewFrame.origin);
            subviewFrame.size = CGSizeMax(CGSizeZero, CGSizeFloor(subviewFrame.size));
            subview.frame = subviewFrame;
            break;
        }
        case CELL_POSITION_FILL_W_ASPECT_RATIO:
        case CELL_POSITION_FIT_W_ASPECT_RATIO:
        {
            CGSize desiredSize = [subview sizeThatFits:CGSizeZero];
            BOOL isValid = (desiredSize.width > 0 &&
                            desiredSize.height > 0 &&
                            cellBounds.size.width > 0 &&
                            cellBounds.size.height > 0);
            if (!isValid)
            {
                subview.frame = cellBounds;
            }
            else
            {
                if (cellPositioning == CELL_POSITION_FILL_W_ASPECT_RATIO)
                {
                    subview.frame = FillRectWithSize(cellBounds, desiredSize);
                }
                else
                {
                    subviewSize = FitSizeInRect(cellBounds, desiredSize).size;
                    subviewSize = CGSizeMax(CGSizeZero, CGSizeFloor(subviewSize));
                    subview.frame = alignSizeWithinRect(subviewSize,
                                                        cellBounds,
                                                        [self subviewCellHAlign:superview
                                                                        subview:subview],
                                                        [self subviewCellVAlign:superview
                                                                        subview:subview]);
                }
            }
        }
        default:
            break;
    }
}

- (CGRect)contentBoundsOfView:(UIView *)view
                      forSize:(CGSize)size
{
    CGFloat borderWidth = view.layer.borderWidth;

    int left = ceilf([self leftMargin] + borderWidth);
    int top = ceilf([self topMargin] + borderWidth);
    int right = floorf(size.width - ceilf([self rightMargin] + borderWidth));
    int bottom = floorf(size.height - ceilf([self bottomMargin] + borderWidth));

    return CGRectMake(left,
                      top,
                      MAX(0, right - left),
                      MAX(0, bottom - top));
}

- (CGSize)insetSizeOfView:(UIView *)view
{
    CGFloat borderWidth = view.layer.borderWidth;

    int left = ceilf([self leftMargin] + borderWidth);
    int top = ceilf([self topMargin] + borderWidth);
    int right = ceilf([self rightMargin] + borderWidth);
    int bottom = ceilf([self bottomMargin] + borderWidth);

    return CGSizeMake(left + right, top + bottom);
}

- (CGSize)desiredItemSize:(UIView *)subview
                  maxSize:(CGSize)maxSize
{
    if (subview.ignoreDesiredSize)
    {
        return CGSizeZero;
    }

    CGSize desiredSize = CGSizeAdd([subview sizeThatFits:maxSize],
                                   [subview desiredSizeAdjustment]);

    return CGSizeCeil(CGSizeMax(CGSizeMax(CGSizeZero,
                                          subview.minSize),
                                CGSizeMin(subview.maxSize,
                                          desiredSize)));
}

- (NSArray *)distributeSpace:(CGFloat)space
      acrossCellsWithWeights:(NSArray *)cellWeights
{
    // Weighted distribution of space between cells.

    WeViewAssert([cellWeights count] > 0);

    CGFloat totalCellWeight = 0.f;
    int cellCountWithWeight = 0;
    for (int i=0; i < [cellWeights count]; i++)
    {
        CGFloat cellWeight = MAX(0.f, [cellWeights[i] floatValue]);
        if (cellWeight > 0)
        {
            totalCellWeight += cellWeight;
            cellCountWithWeight++;
        }
    }

    WeViewAssert(cellCountWithWeight > 0);

    CGFloat spaceRemainder = space;
    int cellRemainder = cellCountWithWeight;
    CGFloat weightRemainder = totalCellWeight;

    NSMutableArray *result = [NSMutableArray array];
    for (int i=0; i < [cellWeights count]; i++)
    {
        CGFloat cellWeight = MAX(0.f, [cellWeights[i] floatValue]);
        int cellDistribution = 0;

        if (cellWeight > 0 && cellRemainder > 0)
        {
            if (cellRemainder == 1)
            {
                // Ensure that the total space distributed is exactly
                cellDistribution = spaceRemainder;
            }
            else
            {
                cellDistribution = floorf(spaceRemainder * cellWeight / weightRemainder);
            }

            cellRemainder--;
            spaceRemainder -= cellDistribution;
            weightRemainder -= cellWeight;
            WeViewAssert(spaceRemainder >= 0);
        }
        [result addObject:@(cellDistribution)];
    }

    return result;
}

- (void)distributeAdjustment:(CGFloat)totalAdjustment
                acrossValues:(NSMutableArray *)values
                 withWeights:(NSArray *)weights
                    withSign:(CGFloat)sign
                 withMaxZero:(BOOL)withMaxZero
{
    WeViewAssert([values count] == [weights count]);
    NSArray *adjustments = [self distributeSpace:roundf(totalAdjustment)
                          acrossCellsWithWeights:weights];
    WeViewAssert([values count] == [adjustments count]);
    int count = [values count];
    for (int i=0; i < count; i++)
    {
        CGFloat newValue = roundf([values[i] floatValue] + [adjustments[i] floatValue] * sign);
        if (withMaxZero)
        {
            newValue = MAX(0.f, newValue);
        }
        values[i] = @(newValue);
    }
}

#pragma mark - Debug Methods

- (NSString *)indentPrefix:(int)indent
{
    NSMutableString *result = [NSMutableString string];
    for (int i=0; i < indent; i++)
    {
        [result appendString:@"  "];
    }
    return result;
}

- (int)viewHierarchyDistanceToWindow:(UIView *)view
{
    UIResponder *responder = view;
    int result = 0;
    while (YES)
    {
        if (!responder ||
            [responder isKindOfClass:[UIWindow class]])
        {
            return result;
        }
        responder = [responder nextResponder];
        result += 2;
    }
}

#pragma mark - Copy Configuration

- (void)copyConfigurationOfLayout:(WeViewLayout *)layout
{
    /* CODEGEN MARKER: Copy Configuration Start */

    self.leftMargin = layout.leftMargin;
    self.rightMargin = layout.rightMargin;
    self.topMargin = layout.topMargin;
    self.bottomMargin = layout.bottomMargin;
    self.vSpacing = layout.vSpacing;
    self.hSpacing = layout.hSpacing;
    self.hAlign = layout.hAlign;
    self.vAlign = layout.vAlign;
    self.cropSubviewOverflow = layout.cropSubviewOverflow;
    self.cellPositioning = layout.cellPositioning;
    self.debugLayout = layout.debugLayout;
    self.debugMinSize = layout.debugMinSize;

/* CODEGEN MARKER: Copy Configuration End */
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
