//
//  GFTiledRenderView.m
//  PDF
//
//  Created by Anton Kolchunov on 13.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GFRenderTiledView.h"
#import "GFPDFTiledLayer.h"

@implementation GFRenderTiledView

@synthesize dataSource = _dataSource;

+ (Class)layerClass
{
	return [GFPDFTiledLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.autoresizesSubviews = NO;
    self.userInteractionEnabled = NO;
    self.contentMode = UIViewContentModeScaleAspectFit; // For proper view rotation handling
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // N.B.
    self.autoresizingMask |= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context
{
	CGPDFPageRef drawPDFPageRef = NULL;
  
	CGPDFDocumentRef drawPDFDocRef = NULL;
  
	@synchronized(self) // Block any other threads
	{
		drawPDFDocRef = CGPDFDocumentRetain([_dataSource document]);
    
		drawPDFPageRef = CGPDFPageRetain([_dataSource page]);
	}
  
	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White
  
	CGContextFillRect(context, CGContextGetClipBoundingBox(context));
  
	if (drawPDFPageRef != NULL) // Render the page into the context
	{
		CGFloat boundsHeight = self.bounds.size.height;
    
		if (CGPDFPageGetRotationAngle(drawPDFPageRef) == 0)
		{
			CGFloat boundsWidth = self.bounds.size.width; // View width
      
			CGRect cropBoxRect = CGPDFPageGetBoxRect(drawPDFPageRef, kCGPDFCropBox);
			CGRect mediaBoxRect = CGPDFPageGetBoxRect(drawPDFPageRef, kCGPDFMediaBox);
			CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
      
			CGFloat effectiveWidth = effectiveRect.size.width;
			CGFloat effectiveHeight = effectiveRect.size.height;
      
			CGFloat widthScale = (boundsWidth / effectiveWidth);
			CGFloat heightScale = (boundsHeight / effectiveHeight);
      
			CGFloat scale = (widthScale < heightScale) ? widthScale : heightScale;
      
			CGFloat x_offset = ((boundsWidth - (effectiveWidth * scale)) / 2.0f);
			CGFloat y_offset = ((boundsHeight - (effectiveHeight * scale)) / 2.0f);
      
			y_offset = (boundsHeight - y_offset); // Co-ordinate system adjust
      
			CGFloat x_translate = (x_offset - (effectiveRect.origin.x * scale));
			CGFloat y_translate = (y_offset + (effectiveRect.origin.y * scale));
      
			CGContextTranslateCTM(context, x_translate, y_translate);
      
			CGContextScaleCTM(context, scale, -scale); // Mirror Y
		}
		else // Use CGPDFPageGetDrawingTransform for pages with rotation (AKA kludge)
		{
			CGContextTranslateCTM(context, 0.0f, boundsHeight); CGContextScaleCTM(context, 1.0f, -1.0f);
      
			CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(drawPDFPageRef, kCGPDFCropBox, self.bounds, 0, true));
		}
    
		CGContextDrawPDFPage(context, drawPDFPageRef);
	}
  
	CGPDFPageRelease(drawPDFPageRef); // Cleanup
  
	CGPDFDocumentRelease(drawPDFDocRef);
}

- (void)reloadData
{
  [self.layer setNeedsDisplay];
}

@end
