//
//  GFRenderView.h
//  PDF
//
//  Created by Anton Kolchunov on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GFRenderView : UIView {
  
  CALayer *_topLayer;
  
}

@end

@protocol GFRenderDataSource <NSObject>

@required
- (NSInteger)numberOfItems:(GFRenderView)renderView;
- (void)renderItemAtIndex:(NSInteger)index;

@end

@protocol GFRenderDelegate <NSObject>

@optional

@end