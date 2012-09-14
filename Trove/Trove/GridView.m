//
//  GridView.m
//  Trove
//
//  Created by Dana Smith on 9/11/12.
//  Copyright (c) 2012 Dana Smith. All rights reserved.
//

#import "GridView.h"

@interface GridView ()
{
	NSMutableArray *_onscreenCells;
	NSMutableArray *_offscreenCells;
}

@end

@implementation GridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		_onscreenCells = [NSMutableArray arrayWithCapacity:40];
		_offscreenCells = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)reloadData
{
	// Clear the scroll view
	
	// Calculate the size of the frame needed to hold all of the cells to set up the scroll view
	
	// Get the cells from the data source
	
}

- (GridViewCell *)cellAtIndex:(NSUInteger)index
{
	
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
	
}

- (NSArray *)selectedCellIndicies
{
	
}


- (void)layoutSubviews
{
	
}


- (void) _reflowGrid
{
	
}

@end
