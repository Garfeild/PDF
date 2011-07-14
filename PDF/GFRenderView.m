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

- (void)setLayerFrames;

@end

CGFloat distance(CGPoint a, CGPoint b);

@implementation GFRenderView

@synthesize dataSource  = _dataSource;
@synthesize delegate    = _delegate;
@synthesize currentItem = currentItem_;
@synthesize pageEdge    = pageEdge_;

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
      
      animationIsRunning_ = NO;
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
  
  self.pageEdge = 1.f;
  
  [self setLayerFrames];

}

- (void)initLayers
{
  _topLayer = [[CALayer alloc] init];
  _topLayer.masksToBounds = YES;
	_topLayer.contentsGravity = kCAGravityLeft;
	_topLayer.backgroundColor = [[UIColor whiteColor] CGColor];
  
  _topLayerOverlay = [[CALayer alloc] init];
	_topLayerOverlay.backgroundColor = [[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor];
	
	_topLayerShadow = [[CAGradientLayer alloc] init];
	_topLayerShadow.colors = [NSArray arrayWithObjects:
                          (id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
                          (id)[[UIColor clearColor] CGColor],
                          nil];
	_topLayerShadow.startPoint = CGPointMake(1,0.5);
	_topLayerShadow.endPoint = CGPointMake(0,0.5);
	
	_topLayerReversed = [[CALayer alloc] init];
	_topLayerReversed.backgroundColor = [[UIColor whiteColor] CGColor];
	_topLayerReversed.masksToBounds = YES;
	
	_topLayerReversedImage = [[CALayer alloc] init];
	_topLayerReversedImage.masksToBounds = YES;
	_topLayerReversedImage.contentsGravity = kCAGravityRight;
	
	_topLayerReversedOverlay = [[CALayer alloc] init];
	_topLayerReversedOverlay.backgroundColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.8] CGColor];
	
	_topLayerReversedShading = [[CAGradientLayer alloc] init];
	_topLayerReversedShading.colors = [NSArray arrayWithObjects:
                                  (id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
                                  (id)[[UIColor clearColor] CGColor],
                                  nil];
	_topLayerReversedShading.startPoint = CGPointMake(1,0.5);
	_topLayerReversedShading.endPoint = CGPointMake(0,0.5);
	
	_bottomLayer = [[CALayer alloc] init];
	_bottomLayer.backgroundColor = [[UIColor whiteColor] CGColor];
	_bottomLayer.masksToBounds = YES;
	
	_bottomLayerShadow = [[CAGradientLayer alloc] init];
	_bottomLayerShadow.colors = [NSArray arrayWithObjects:
                             (id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
                             (id)[[UIColor clearColor] CGColor],
                             nil];
	_bottomLayerShadow.startPoint = CGPointMake(0,0.5);
	_bottomLayerShadow.endPoint = CGPointMake(1,0.5);
	
	[_topLayer addSublayer:_topLayerShadow];
	[_topLayer addSublayer:_topLayerOverlay];
	[_topLayerReversed addSublayer:_topLayerReversedImage];
	[_topLayerReversed addSublayer:_topLayerReversedOverlay];
	[_topLayerReversed addSublayer:_topLayerReversedShading];
	[_bottomLayer addSublayer:_bottomLayerShadow];
	[self.layer addSublayer:_bottomLayer];
	[self.layer addSublayer:_topLayer];
	[self.layer addSublayer:_topLayerReversed];
  
  self.pageEdge = 1.0;

}

- (void)getImages
{
  _topLayer.contents = (id)[[GFImageCache imageCache] itemForIndex:currentItem_
                                                        dataSource:_dataSource];
  
  
  if ( currentItem_ < [_dataSource numberOfItems:self] ) 
  {
    _topLayer.contents = (id)[[GFImageCache imageCache] itemForIndex:currentItem_
                                                          dataSource:_dataSource];
    _topLayerReversedImage.contents = (id)[[GFImageCache imageCache] itemForIndex:currentItem_
                                                          dataSource:_dataSource];
		if ( currentItem_ < [_dataSource numberOfItems:self]- 1 )
			_bottomLayer.contents = (id)[[GFImageCache imageCache] itemForIndex:currentItem_+1
                                                              dataSource:_dataSource];
	} else {
		_topLayer.contents = nil;
		_topLayerReversedImage.contents = nil;
		_bottomLayer.contents = nil;
	}
  
}

- (void)setCurrentItem:(NSInteger)currentItem 
{
  NSLog(@"Setting current item %d", currentItem);
  if ( currentItem < 0 || currentItem > [_dataSource numberOfItems:self]-1 )
    return;
	currentItem_ = currentItem;
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
                   forKey:kCATransactionDisableActions];
	
	[self getImages];

  self.pageEdge = 1.0;
		
	[CATransaction commit];
}

- (void) setLayerFrames {
	_topLayer.frame = CGRectMake(self.layer.bounds.origin.x, 
                             self.layer.bounds.origin.y, 
                             pageEdge_ * self.bounds.size.width, 
                             self.layer.bounds.size.height);
	_topLayerReversed.frame = CGRectMake(self.layer.bounds.origin.x + (2*pageEdge_-1) * self.bounds.size.width, 
                                    self.layer.bounds.origin.y, 
                                    (1-pageEdge_) * self.bounds.size.width, 
                                    self.layer.bounds.size.height);
	_bottomLayer.frame = self.layer.bounds;
	_topLayerShadow.frame = CGRectMake(_topLayerReversed.frame.origin.x - 40, 
                                   0, 
                                   40, 
                                   _bottomLayer.bounds.size.height);
	_topLayerReversedImage.frame = _topLayerReversed.bounds;
	_topLayerReversedImage.transform = CATransform3DMakeScale(-1, 1, 1);
	_topLayerReversedOverlay.frame = _topLayerReversed.bounds;
	_topLayerReversedShading.frame = CGRectMake(_topLayerReversed.bounds.size.width - 50, 
                                           0, 
                                           50 + 1, 
                                           _topLayerReversed.bounds.size.height);
	_bottomLayerShadow.frame = CGRectMake(pageEdge_ * self.bounds.size.width, 
                                      0, 
                                      40, 
                                      _bottomLayer.bounds.size.height);
	_topLayerReversedOverlay.frame = _topLayer.bounds;
}

- (void)setPageEdge:(CGFloat)aPageEdge {
  NSLog(@"Setting leaf edge");
  
	pageEdge_ = aPageEdge;
	_topLayerShadow.opacity = MIN(1.0, 4*(1-aPageEdge));
	_bottomLayerShadow.opacity = MIN(1.0, 4*aPageEdge);
	_topLayerOverlay.opacity = MIN(1.0, 4*(1-aPageEdge));
	[self setLayerFrames];
}

- (void) didTurnPageBackward {
	animationIsRunning_ = NO;
}

- (void) didTurnPageForward {
	animationIsRunning_ = NO;
	self.currentItem = self.currentItem + 1;	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (animationIsRunning_)
		return;
	
	UITouch *touch = [event.allTouches anyObject];
	touchBeganPoint_ = [touch locationInView:self];
	
	if ( CGRectContainsPoint(prevPageArea_, touchBeganPoint_) && currentItem_ > 0 ) {		
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
		self.currentItem = self.currentItem - 1;
		self.pageEdge = 0.0;
		[CATransaction commit];
		touchIsActive_ = YES;		
	} 
	else if ( CGRectContainsPoint(nextPageArea_, touchBeganPoint_) && currentItem_ < [_dataSource numberOfItems:self]-1 )
  {
		touchIsActive_ = YES;
	}
	else 
  {
    if ( [touch tapCount] == 2 || [touches count] == 2 )
    {
      NSLog(@"Double touch");
      [_delegate beginZoom];
    }
		touchIsActive_ = NO;
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!touchIsActive_)
		return;
	UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.07]
                   forKey:kCATransactionAnimationDuration];
	self.pageEdge = touchPoint.x / self.bounds.size.width;
	[CATransaction commit];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!touchIsActive_)
		return;
	touchIsActive_ = NO;
	
	UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
  
	BOOL dragged = distance(touchPoint, touchBeganPoint_) > 10.f;
	
	[CATransaction begin];
	float duration;
	if ( ( dragged && self.pageEdge < 0.5 ) || ( !dragged && CGRectContainsPoint(nextPageArea_, touchBeganPoint_) ) ) {
		self.pageEdge = 0;
		duration = pageEdge_;
		animationIsRunning_ = YES;
		[self performSelector:@selector(didTurnPageForward)
               withObject:nil 
               afterDelay:duration + 0.25];
	}
	else {
		self.pageEdge = 1.0;
		duration = 1 - pageEdge_;
		animationIsRunning_ = YES;
		[self performSelector:@selector(didTurnPageBackward)
               withObject:nil 
               afterDelay:duration + 0.25];
	}
	[CATransaction setValue:[NSNumber numberWithFloat:duration]
                   forKey:kCATransactionAnimationDuration];
	[CATransaction commit];
}
@end

CGFloat distance(CGPoint a, CGPoint b) {
	return sqrtf(powf(a.x-b.x, 2) + powf(a.y-b.y, 2));
}