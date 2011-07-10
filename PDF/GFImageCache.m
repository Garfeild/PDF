//
//  GFImageCache.m
//  PDF
//
//  Created by Anton Kolchunov on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GFImageCache.h"

static GFImageCache *imageCache = nil;

@implementation GFImageCache

@synthesize pageSize = pageSize_;


+ (id)imageCache {
  @synchronized(self) {
    if(imageCache == nil)
      imageCache = [[super allocWithZone:NULL] init];
  }
  return imageCache;
}

+ (id)allocWithZone:(NSZone *)zone {
  return [[self imageCache] retain];
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (id)retain {
  return self;
}

- (unsigned)retainCount {
  return UINT_MAX; //denotes an object that cannot be released
}

- (void)release {
  // never release
}

- (id)autorelease {
  return self;
}

- (id)init {
	self = [super init];
	
  if ( self != nil ) {
		_cache = [[NSMutableDictionary alloc] init];
    pageSize_ = CGSizeZero;
	}
  
	return self;
}
- (void)dealloc {
  // Should never be called, but just here for clarity really.
  [super dealloc];
}


- (CGImageRef)itemForIndex:(NSInteger)index dataSource:(id<GFRenderDataSource>)dataSource
{
  NSString *itemKey = [NSString stringWithFormat:@"%@ - %d", [dataSource fileName], index];
  if ( [[_cache allKeys] containsObject:itemKey] )
    return [(UIImage*)[_cache objectForKey:itemKey] CGImage];
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, 
                                               pageSize_.width, 
                                               pageSize_.height, 
                                               8,						/* bits per component*/
                                               pageSize_.width * 4, 	/* bytes per row */
                                               colorSpace, 
                                               kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextClipToRect(context, CGRectMake(0, 0, pageSize_.width, pageSize_.height));
	
	[dataSource renderItemAtIndex:index inContext:context];
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	[_cache setObject:[UIImage imageWithCGImage:image] forKey:itemKey];
	CGImageRelease(image);
  
  return image;

}

- (void)minimizeItems:(NSInteger)currentIndex
{
  
}

@end
