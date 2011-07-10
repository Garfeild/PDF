//
//  GFRenderProtocols.h
//  PDF
//
//  Created by Anton Kolchunov on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GFRenderView;

@protocol GFRenderDataSource <NSObject>

@required
- (NSInteger)numberOfItems:(GFRenderView*)renderView;
- (void)renderItemAtIndex:(NSInteger)index inContext:(CGContextRef)context;
- (NSString*)fileName;

@end

@protocol GFRenderDelegate <NSObject>

@optional

@end