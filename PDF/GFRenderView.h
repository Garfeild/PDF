//
//  GFRenderView.h
//  PDF
//
//  Created by Anton Kolchunov on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GFRenderProtocols.h"


@interface GFRenderView : UIView {

  id<GFRenderDataSource> _dataSource;
  id<GFRenderDelegate> _delegate;
  
  CALayer *_topLayer;
	CALayer *_topLayerOverlay;
	CAGradientLayer *_topLayerShadow;
	
	CALayer *_topLayerReversed;
	CALayer *_topLayerReversedImage;
	CALayer *_topLayerReversedOverlay;
	CAGradientLayer *_topLayerReversedShading;
	
	CALayer *_bottomLayer;
	CAGradientLayer *_bottomLayerShadow;
  
  NSInteger currentItem_;
  
  CGRect  nextPageArea_,
          prevPageArea_;
  
  CGPoint touchBeganPoint_;
  
  CGFloat pageEdge_;
  
  BOOL animationIsRunning_;
  
  BOOL touchIsActive_;
  
  BOOL lockedOtherView_;
  
}

@property (assign) id<GFRenderDataSource> dataSource;
@property (assign) id<GFRenderDelegate> delegate;
@property (assign) NSInteger currentItem;
@property (assign) CGFloat pageEdge;
@property (assign) BOOL lockedOtherView;

- (void)reloadData;

@end
