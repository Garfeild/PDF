//
//  GFTiledRenderView.h
//  PDF
//
//  Created by Anton Kolchunov on 13.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFRenderProtocols.h"

@interface GFRenderTiledView : UIView {
  
  id <GFPDFRenderDataSource> _dataSource;
    
}

@property (assign) id<GFPDFRenderDataSource> dataSource;

- (void)reloadData;

@end
