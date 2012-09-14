//
//  GridView.h
//  Trove
//
//  Created by Dana Smith on 9/11/12.
//  Copyright (c) 2012 Dana Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridViewCell.h"

@class GridView;

@protocol GridViewDelegate <NSObject>

@optional

//  Called whenever a cell is tapped, regardless of selecting property value.
//
- (void)gridView:(GridView *)gridView didSelectCellAtIndex:(NSUInteger)index;

@end

@protocol GridViewDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInGridView:(GridView *)gridView;
- (GridViewCell *)gridView:(GridView *)gridView cellAtIndex:(NSUInteger)index;

@end



@interface GridView : UIScrollView

@property (nonatomic) CGSize cellSize;
@property (nonatomic) CGFloat cellSpacing;
@property (nonatomic) BOOL picking;

@property (nonatomic, assign) IBOutlet id <GridViewDelegate> gridViewDelegate;
@property (nonatomic, assign) IBOutlet id <GridViewDataSource> dataSource;

- (void)reloadData;

- (GridViewCell *)cellAtIndex:(NSUInteger)index;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (NSArray *)selectedCellIndicies;

@end
