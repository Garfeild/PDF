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

- (id)init
{
  self = [super init];
  
  NSLog(@"View blank init");
  
  
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  
  NSLog(@"View coder init");
  if (self) 
  {
    [self initLayers];
  }
  
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  NSLog(@"View init");
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
  
  nextPageArea_ = CGRectMake(self.frame.size.width-100, 0, 100, self.frame.size.height);
  
  prevPageArea_ = CGRectMake(0, 0, 100, self.frame.size.height);
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


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"Touch 2");

  if ( [touches count] == 1 ) 
  {
    UITouch *touch = [touches anyObject];

    if ( [[touch view] isEqual:self] )
    {
      
      if ( [touch tapCount] == 1 ) 
      {
        CGPoint location = [touch locationInView:self];
        
        if ( CGRectContainsPoint(nextPageArea_, location) )
        {
          self.currentItem += 1;
        }
        else if ( CGRectContainsPoint(prevPageArea_, location) )
        {
          self.currentItem -= 1;
        }
      }
      else if ( [touch tapCount] == 2 )
      {
        [_delegate beginZoom];
      }
      
    }
  }
  else if ( [touches count] == 2 )
  {
    [_delegate beginZoom];

  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  
}
@end
