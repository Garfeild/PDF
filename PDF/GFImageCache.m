//
//  GFImageCache.m
//  PDF
//
//  Created by Anton Kolchunov on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GFImageCache.h"

static GFImageCache *imageCache = nil;

@implementation GFImageCache

@synthesize dataSource = _dataSource;

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
	}
  
	return self;
}
- (void)dealloc {
  // Should never be called, but just here for clarity really.
  [super dealloc];
}

@end
