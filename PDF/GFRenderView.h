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

typedef enum {
  GFRenderViewModeSinglePage = 0,
  GFRenderViewModeFacingPages,
} GFRenderViewMode;

@interface GFRenderView : UIView {

  id<GFRenderDataSource> _dataSource;
  id<GFRenderDelegate> _delegate;
  
  CALayer *_topLayer;
	CALayer *_topLayerOverlay;
	CAGradientLayer *_topLayerShadow;
  
  CALayer *_facingLayer;
	CALayer *_facingLayerOverlay;
	
	CALayer *_topLayerReversed;
	CALayer *_topLayerReversedImage;
	CALayer *_topLayerReversedOverlay;
	CAGradientLayer *_topLayerReversedShading;
	
	CALayer *_bottomLayer;
	CAGradientLayer *_bottomLayerShadow;
  
  NSArray *_selections;
  
  NSInteger currentItem_;
  NSInteger numberOfItems_;
  
  NSInteger numberOfVisiblePages_;
  
  CGRect  nextPageArea_,
          prevPageArea_;
  
  CGPoint touchBeganPoint_;
  
  CGFloat pageEdge_;
  
  BOOL animationIsRunning_;
  
  BOOL touchIsActive_;
  
  BOOL lockedOtherView_;
  
  GFRenderViewMode renderViewMode_;
  
  
  
}

@property (assign) id<GFRenderDataSource> dataSource;
@property (assign) id<GFRenderDelegate> delegate;
@property (assign) NSInteger currentItem;
@property (assign) CGFloat pageEdge;
@property (assign) BOOL lockedOtherView;
@property (assign) GFRenderViewMode renderViewMode;
@property (nonatomic, retain) NSArray *selections;

- (void)reloadData;

@end
