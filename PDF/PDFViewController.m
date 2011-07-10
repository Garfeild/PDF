//
//  PDFViewController.m
//  PDF
//
//  Created by Anton Kolchunov on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PDFViewController.h"
#import "GFHelpers.h"
#import "GFImageCache.h"

@implementation PDFViewController

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  NSString *path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"pdf"];
  NSURL *fileURL = [NSURL fileURLWithPath:path];
  
  _pdf = CGPDFDocumentCreateWithURL((CFURLRef)fileURL);
  
  _fileName = [[NSString alloc] initWithString:@"Test"];
  
  [super viewDidLoad];
}




- (NSInteger)numberOfItems:(GFRenderView *)renderView
{
  return CGPDFDocumentGetNumberOfPages(_pdf);
}

- (void)renderItemAtIndex:(NSInteger)index inContext:(CGContextRef)context
{
  CGPDFPageRef page = CGPDFDocumentGetPage(_pdf, index + 1);
	CGAffineTransform transform = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
                                          CGContextGetClipBoundingBox(context));
	CGContextConcatCTM(context, transform);
	CGContextDrawPDFPage(context, page);
}

- (NSString*)fileName
{
  return _fileName;
}



- (IBAction)nextPage:(id)sender
{
  _renderView.currentItem = _renderView.currentItem+1;
}

- (IBAction)prevPage:(id)sender
{
  _renderView.currentItem = _renderView.currentItem-1;
}
@end
