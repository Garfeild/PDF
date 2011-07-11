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
  
  NSInteger currentItem_;
  
  CGRect  nextPageArea_,
          prevPageArea_;
  
}

@property (assign) id<GFRenderDataSource> dataSource;
@property (assign) id<GFRenderDelegate> delegate;
@property (assign) NSInteger currentItem;

- (void)reloadData;

@end
