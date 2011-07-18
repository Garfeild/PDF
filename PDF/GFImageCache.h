//
//  GFImageCache.h
//  PDF
//
//  Created by Anton Kolchunov on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GFRenderView.h"

@interface GFImageCache : NSObject {
   
  NSMutableDictionary *_cache;
  
  CGSize pageSize_;
}

@property (assign) CGSize pageSize;

+ (id)imageCache;

- (CGImageRef)itemForIndex:(NSInteger)index dataSource:(id<GFRenderDataSource>)dataSource;

- (void)minimizeItems:(NSInteger)currentIndex dataSource:(id<GFRenderDataSource>)dataSource;

@end

