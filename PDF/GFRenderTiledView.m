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
@synthesize mode = mode_;
@synthesize rotated = rotated_;

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
    self.clipsToBounds = YES;

    self.contentMode = UIViewContentModeScaleAspectFit; // For proper view rotation handling
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // N.B.
    self.autoresizingMask |= UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.backgroundColor = [UIColor clearColor];
    rotated_ = NO;
    mode_ = GFRenderTiledViewModeLeft;
  }
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context
{
  NSLog(@"*********");
   
	CGPDFPageRef drawPageRef = NULL;

	@synchronized(self) // Block any other threads
	{    
    if ( mode_ == GFRenderTiledViewModeLeft )
    {
      drawPageRef = CGPDFPageRetain((rotated_) ? [_dataSource pageWithOffset:-1] : [_dataSource page]);
      NSLog(@"Drawin layer for left page!");
    }
    else
    {

      drawPageRef = CGPDFPageRetain([_dataSource page]);
      NSLog(@"Drawin layer for right page!");
    }
	}
  
  CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White
  
	CGContextFillRect(context, CGContextGetClipBoundingBox(context));
  
  // Drawin left page
  if (drawPageRef != NULL) // Render the page into the context
	{

    NSLog(@"Draw layer: %fx%f | %@", self.bounds.size.width, self.bounds.size.height, ( mode_ == GFRenderTiledViewModeLeft ) ? @"Left" : @"Right");

		CGFloat boundsHeight = self.bounds.size.height;
    
		if (CGPDFPageGetRotationAngle(drawPageRef) == 0)
		{
			CGFloat boundsWidth = self.bounds.size.width; // View width
      
			CGRect cropBoxRect = CGPDFPageGetBoxRect(drawPageRef, kCGPDFCropBox);
			CGRect mediaBoxRect = CGPDFPageGetBoxRect(drawPageRef, kCGPDFMediaBox);
			CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
      
			CGFloat effectiveWidth = effectiveRect.size.width;
			CGFloat effectiveHeight = effectiveRect.size.height;
      
      NSLog(@"Drawin | Effective rect: %fx%f (%f, %f)", effectiveWidth, effectiveHeight, effectiveRect.origin.x, effectiveRect.origin.y);
      
			CGFloat widthScale = (boundsWidth / effectiveWidth);
			CGFloat heightScale = (boundsHeight / effectiveHeight);
      
			CGFloat scale = (widthScale < heightScale) ? widthScale : heightScale;
      
			CGFloat x_offset = ((boundsWidth - (effectiveWidth * scale)) / 2.0f);
			CGFloat y_offset = ((boundsHeight - (effectiveHeight * scale)) / 2.0f);
      
//      if ( mode_ == GFRenderTiledViewModeRight )
//        x_offset += boundsWidth;
      
			y_offset = (boundsHeight - y_offset); // Co-ordinate system adjust
      
			CGFloat x_translate = (x_offset - (effectiveRect.origin.x * scale));
			CGFloat y_translate = (y_offset + (effectiveRect.origin.y * scale));
      
      NSLog(@"Drawin | scale = %f | at point: (%f, %f) | Translate coord: (%f, %f)", scale, x_offset, y_offset, x_translate, y_translate);
      
			CGContextTranslateCTM(context, x_translate, y_translate);
      
			CGContextScaleCTM(context, scale, -scale); // Mirror Y
		}
		else // Use CGPDFPageGetDrawingTransform for pages with rotation (AKA kludge)
		{
			CGContextTranslateCTM(context, 0.0f, boundsHeight); CGContextScaleCTM(context, 1.0f, -1.0f);
      
			CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(drawPageRef, kCGPDFCropBox, self.bounds, 0, true));
		}
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);
		CGContextDrawPDFPage(context, drawPageRef);
	}
  
  CGPDFPageRelease(drawPageRef);
}

- (void)reloadData
{
  [self.layer setNeedsDisplay];
}

@end
