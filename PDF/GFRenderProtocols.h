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
- (void)beginZoom;

@end

@protocol GFPDFRenderDataSource <NSObject>

@required
- (CGPDFDocumentRef)document;
- (CGPDFPageRef)page;
@optional
- (CGPDFPageRef)pageAtIndex:(NSInteger)index;
- (CGPDFPageRef)pageWithOffset:(NSInteger)offset;

@end