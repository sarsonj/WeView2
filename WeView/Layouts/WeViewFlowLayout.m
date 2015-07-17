//
//  WeViewFlowLayout.m
//  WeView v2
//
//  Copyright (c) 2014 Charles Matthew Chen. All rights reserved.
//
//  Distributed under the Apache License v2.0.
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <QuartzCore/QuartzCore.h>

#import "UIView+WeView.h"
#import "WeViewFlowLayout.h"
#import "WeViewLayout+Subclass.h"
#import "WeViewMacros.h"

@interface WeViewFlowLayout ()

@property (nonatomic) BOOL rightToLeft;

@end

#pragma mark -

@implementation WeViewFlowLayout

+ (WeViewFlowLayout *)flowLayout
{
    WeViewFlowLayout *layout = [[WeViewFlowLayout alloc] init];
    return layout;
}

- (CGSize)minSizeOfContentsView:(UIView *)view
                       subviews:(NSArray *)subviews
                   thatFitsSize:(CGSize)guideSize
{
    if ([subviews count] < 1)
    {
        return [self insetSizeOfView:view];
    }

    guideSize = CGSizeMax(guideSize, CGSizeZero);
    BOOL debugMinSize = [self debugMinSize];
    int indent = 0;
    if (debugMinSize)
    {
        indent = [self viewHierarchyDistanceToWindow:view];
        NSLog(@"%@+ [%@ (%@) minSizeOfContentsView: %@] thatFitsSize: %@",
              [self indentPrefix:indent],
              [self class],
              view.debugName,
              [view class],
              NSStringFromCGSize(guideSize));
    }

    NSUInteger subviewCount = [subviews count];

    CGRect contentBounds = [self contentBoundsOfView:view
                                             forSize:guideSize];

    if (debugMinSize)
    {
        NSLog(@"%@ contentBounds: %@, guideSize: %@, insetSizeOfView: %@",
              [self indentPrefix:indent + 1],
              FormatCGRect(contentBounds),
              FormatCGSize(guideSize),
              FormatCGSize([self insetSizeOfView:view]));
    }

    BOOL hasNonEmptyGuideSize = (guideSize.width > 0) || (guideSize.height > 0);

    CGSize subviewDesiredSizes[subviewCount];
    [self findDesiredSizes:&(subviewDesiredSizes[0])
                ofSubviews:subviews
          subviewGuideSize:hasNonEmptyGuideSize ? contentBounds.size : CGSizeZero
            maxSubviewSize:contentBounds.size
                  cropSize:hasNonEmptyGuideSize];

    CGRect cellBounds[subviewCount];
    CGSize bodySize = [self arrangeCells:&(cellBounds[0])
                     subviewDesiredSizes:&(subviewDesiredSizes[0])
                                subviews:subviews
                                    view:view
                           contentBounds:contentBounds
                        findBodySizeOnly:YES];

    CGSize result = CGSizeAdd([self insetSizeOfView:view],
                              bodySize);

    if (debugMinSize)
    {
        NSLog(@"%@ result: %@",
              [self indentPrefix:indent + 1],
              NSStringFromCGSize(result));
    }

    return result;
}

- (void)findDesiredSizes:(CGSize *)subviewDesiredSizes
              ofSubviews:(NSArray *)subviews
        subviewGuideSize:(CGSize)subviewGuideSize
          maxSubviewSize:(CGSize)maxSubviewSize
                cropSize:(BOOL)cropSize
{
    NSUInteger subviewCount = [subviews count];
    BOOL cropSubviewOverflow = [self cropSubviewOverflow];
    for (int i=0; i < subviewCount; i++)
    {
        UIView* subview = subviews[i];
        CGSize subviewSize = [self desiredItemSize:subview
                                           maxSize:subviewGuideSize];

        if (cropSubviewOverflow && cropSize)
        {
            subviewSize = CGSizeMin(subviewSize, maxSubviewSize);
        }
        subviewDesiredSizes[i] = subviewSize;
    }
}

- (CGSize)arrangeCells:(CGRect *)cellBounds
   subviewDesiredSizes:(CGSize *)subviewDesiredSizes
              subviews:(NSArray *)subviews
                  view:(UIView *)view
         contentBounds:(CGRect)contentBounds
      findBodySizeOnly:(BOOL)findBodySizeOnly
{
    NSUInteger subviewCount = [subviews count];

    // Simulate layout process.
    // xOffset is the x value for left-to-right layouts and the inverse
    // (the distance from the right edge) for right-to-left layouts.
    int xOffset = 0;
    int y = 0;
    int rowWidth = 0, rowHeight = 0;
    int itemsInRow = 0;
    int totalBodyWidth = 0;
    int row = 0;
    int cellRows[subviewCount];
    int hSpacing = ceilf(self.hSpacing);
    int vSpacing = ceilf(self.vSpacing);
    UIView *lastSubview = nil;
    for (int i=0; i < subviewCount; i++)
    {
        UIView *subview = subviews[i];
        if (lastSubview)
        {
            xOffset += (self.rightToLeft
                        ? subview.rightSpacingAdjustment
                        : subview.leftSpacingAdjustment);
        }

        int proposedRowWidth = xOffset + subviewDesiredSizes[i].width;
        if (itemsInRow > 0 &&
            proposedRowWidth > contentBounds.size.width)
        {
            // Overflow; start new row.
            y += rowHeight + vSpacing;
            xOffset = 0;
            itemsInRow = 0;
            rowWidth = 0;
            rowHeight = 0;
            lastSubview = nil;
            row++;
        }

        CGRect cell = CGRectZero;
        // For right-to-left layouts, reverse the direction of the x-offset.
        // The "row" will not end up aligned against the origin, but that will be
        // corrected below.
        cell.origin.x = (self.rightToLeft
                         ? -(xOffset + subviewDesiredSizes[i].width)
                         : +xOffset);
        cell.origin.y = y;
        cell.size = subviewDesiredSizes[i];
        cellBounds[i] = cell;
        cellRows[i] = row;

        rowWidth = xOffset + subviewDesiredSizes[i].width;
        rowHeight = MAX(rowHeight, subviewDesiredSizes[i].height);
        xOffset += subviewDesiredSizes[i].width + hSpacing;
        xOffset += (self.rightToLeft
                    ? subview.leftSpacingAdjustment
                    : subview.rightSpacingAdjustment);

        itemsInRow++;
        totalBodyWidth = MAX(totalBodyWidth, rowWidth);
        lastSubview = subview;
    }
    int totalBodyHeight = y + rowHeight;

    if (findBodySizeOnly)
    {
        return CGSizeMake(totalBodyWidth, totalBodyHeight);
    }

    const int rowCount = row + 1;

    int extraVSpace = MAX(0, contentBounds.size.height - totalBodyHeight);
    int vAdjustment = 0;
    {
        // Align rows vertically.
        switch (self.vAlign)
        {
            case V_ALIGN_TOP:
                vAdjustment = 0;
                break;
            case V_ALIGN_CENTER:
                vAdjustment = roundf(extraVSpace / 2);
                break;
            case V_ALIGN_BOTTOM:
                vAdjustment = extraVSpace;
                break;
            default:
                WeViewAssert(0);
                break;
        }
    }

    int left = contentBounds.origin.x;
    int top = contentBounds.origin.y;

    for (row=0; row < rowCount; row++)
    {
        int firstCellInRow = (int) subviewCount;
        int lastCellInRow = -1;

        // Find cells in row.
        for (int i=0; i < subviewCount; i++)
        {
            if (cellRows[i] == row)
            {
                firstCellInRow = MIN(firstCellInRow, i);
                lastCellInRow = MAX(lastCellInRow, i);
            }
        }

        WeViewAssert(firstCellInRow < subviewCount);
        WeViewAssert(lastCellInRow >= 0);
        WeViewAssert(firstCellInRow <= lastCellInRow);
        
        CGFloat rowHeight = 0;
        CGFloat rowMinX = 0;
        for (int i=firstCellInRow; i <= lastCellInRow; i++)
        {
            rowHeight = MAX(rowHeight, cellBounds[i].size.height);
            rowMinX = MIN(rowMinX, cellBounds[i].origin.x);
        }
        // Left-align the contents of each row so that the left-most subview in the row has x=0.
        // This won't be necessary for left-to-right layouts but is essential for right-to-left.
        for (int i=firstCellInRow; i <= lastCellInRow; i++)
        {
            CGRect cell = cellBounds[i];
            cell.origin.x -= rowMinX;
            cellBounds[i] = cell;
        }
        
        int rowWidth = (self.rightToLeft
                        ? (cellBounds[firstCellInRow].origin.x + cellBounds[firstCellInRow].size.width)
                        : (cellBounds[lastCellInRow].origin.x + cellBounds[lastCellInRow].size.width));
        // rowWidth might be wider than contentBounds.size.width in the overflow case.
        int extraRowSpace = contentBounds.size.width - rowWidth;
        int hAdjustment = 0;
        {
            // Align row horizontally.
            switch (self.hAlign)
            {
                case H_ALIGN_LEFT:
                    hAdjustment = 0;
                    break;
                case H_ALIGN_CENTER:
                    hAdjustment = roundf(extraRowSpace / 2);
                    break;
                case H_ALIGN_RIGHT:
                    hAdjustment = extraRowSpace;
                    break;
                default:
                    WeViewAssert(0);
                    break;
            }
        }

        for (int i=firstCellInRow; i <= lastCellInRow; i++)
        {
            CGRect cell = cellBounds[i];
            // All cells in row should have height of row.
            cell.size.height = rowHeight;
            // Apply alignment adjustments.
            cell.origin.x += left + hAdjustment;
            cell.origin.y += top + vAdjustment;
            cellBounds[i] = cell;
        }
    }

    return CGSizeMake(totalBodyWidth, totalBodyHeight);
}

- (void)layoutContentsOfView:(UIView *)view
                    subviews:(NSArray *)subviews
{
    if ([subviews count] < 1)
    {
        return;
    }

    BOOL debugLayout = [self debugLayout];
    int indent = 0;
    CGSize guideSize = view.size;
    guideSize = CGSizeMax(guideSize, CGSizeZero);
    if (debugLayout)
    {
        indent = [self viewHierarchyDistanceToWindow:view];
        NSLog(@"%@+ [%@ (%@) layoutContentsOfView: %@] : %@",
              [self indentPrefix:indent],
              [self class],
              view.debugName,
              [view class],
              NSStringFromCGSize(guideSize));
    }

    NSUInteger subviewCount = [subviews count];

    CGRect contentBounds = [self contentBoundsOfView:view
                                             forSize:guideSize];

    if (debugLayout)
    {
        NSLog(@"%@ contentBounds: %@, guideSize: %@, insetSizeOfView: %@",
              [self indentPrefix:indent + 1],
              FormatCGRect(contentBounds),
              FormatCGSize(guideSize),
              FormatCGSize([self insetSizeOfView:view]));
    }

    CGSize subviewDesiredSizes[subviewCount];
    [self findDesiredSizes:&(subviewDesiredSizes[0])
                ofSubviews:subviews
          subviewGuideSize:contentBounds.size
            maxSubviewSize:contentBounds.size
                  cropSize:YES];

    CGRect cellBounds[subviewCount];
    [self arrangeCells:&(cellBounds[0])
   subviewDesiredSizes:&(subviewDesiredSizes[0])
              subviews:subviews
                  view:view
         contentBounds:contentBounds
      findBodySizeOnly:NO];

    // Calculate and apply the subviews' frames.
    CellPositioningMode cellPositioning = [self cellPositioning];
    for (int i=0; i < subviewCount; i++)
    {
        UIView* subview = subviews[i];

        [self positionSubview:subview
                  inSuperview:view
                     withSize:subviewDesiredSizes[i]
                 inCellBounds:cellBounds[i]
              cellPositioning:cellPositioning];

        if (debugLayout)
        {
            NSLog(@"%@ - final layout[%d] %@: %@, cellBounds: %@, subviewSize: %@",
                  [self indentPrefix:indent + 2],
                  i,
                  [subview class],
                  FormatCGRect(subview.frame),
                  FormatCGRect(cellBounds[i]),
                  FormatCGSize(subviewDesiredSizes[i]));
        }
    }
}

- (WeViewFlowLayout *)setIsRightToLeft {
    return [self setIsRightToLeft:YES];
}

- (WeViewFlowLayout *)setIsRightToLeft:(BOOL)value {
    self.rightToLeft = value;
    
    [self propertyChanged];
    
    return self;
}

@end
