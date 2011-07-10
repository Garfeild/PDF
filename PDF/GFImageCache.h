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
 
  id<GFRenderDataSource> _dataSource;
  
  NSMutableDictionary *_cache;
  
}

@property (nonatomic, assign) id<GFRenderDataSource> dataSource;

+ (id)imageCache;

- (CGImageRef)imageForPageIndex:(NSInteger)pageIndex;

- (void)removeUnusedIndexes;

@end
