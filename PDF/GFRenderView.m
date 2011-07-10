//
//  GFRenderView.m
//  PDF
//
//  Created by Anton Kolchunov on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GFRenderView.h"
#import "GFImageCache.h"

@interface GFRenderView (Workers)

- (void)initLayers;

@end


@implementation GFRenderView

@synthesize dataSource  = _dataSource;
@synthesize delegate    = _delegate;
@synthesize currentItem = currentItem_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
      [self initLayers];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)reloadData
{
  self.currentItem = 0;
  _topLayer.frame = CGRectMake(0, 0, self.layer.bounds.size.width, self.layer.bounds.size.height);
}

- (void)initLayers
{
  _topLayer = [[CALayer alloc] init];
  [self.layer addSublayer:_topLayer];
}

- (void)getImages
{
  _topLayer.contents = (id)[[GFImageCache imageCache] itemForIndex:currentItem_
                                                        dataSource:_dataSource];
}

- (void)setCurrentItem:(NSInteger)currentItem {
  if ( currentItem < 0 || currentItem > [_dataSource numberOfItems:self]-1 )
    return;
	currentItem_ = currentItem;
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
                   forKey:kCATransactionDisableActions];
	
	[self getImages];
		
	[CATransaction commit];
}

@end
