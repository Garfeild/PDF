//
//  GFTiledRenderView.h
//  PDF
//
//  Created by Anton Kolchunov on 13.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFRenderProtocols.h"

typedef enum {
  GFTiledRenderViewModeRight = 0,
  GFTiledRenderViewModeLeft,
} GFTiledRenderViewMode;

@interface GFRenderTiledView : UIView {
  
  id <GFPDFRenderDataSource> _dataSource;
  
  GFTiledRenderViewMode mode_;
    
}

@property (assign) id<GFPDFRenderDataSource> dataSource;
@property (assign) GFTiledRenderViewMode mode;

- (void)reloadData;

@end
