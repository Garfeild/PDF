//
//  GFTiledRenderView.h
//  PDF
//
//  Created by Anton Kolchunov on 13.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFRenderProtocols.h"

typedef enum
{
  GFRenderTiledViewModeLeft = 0,
  GFRenderTiledViewModeRight,
} GFRenderTiledViewMode;

@interface GFRenderTiledView : UIView {
  
  id <GFPDFRenderDataSource> _dataSource;
  GFRenderTiledViewMode mode_;
  BOOL rotated_;
    
}

@property (assign) id<GFPDFRenderDataSource> dataSource;
@property (assign) GFRenderTiledViewMode mode;
@property (assign) BOOL rotated;

- (void)reloadData;

@end
