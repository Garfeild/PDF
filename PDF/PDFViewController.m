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

- (void)createToolBar
{
  _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
  _toolBar.barStyle = UIBarStyleDefault;
  _toolBar.center = CGPointMake(self.view.frame.size.width/2, _toolBar.frame.size.height/2);
  
  UIBarButtonItem *button = nil;
  NSMutableArray *items = [[NSMutableArray alloc] init];
  
  button = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(prevPage:)];
  [items addObject:button];
  [button release];

  button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  [items addObject:button];
  [button release];
  
  button = [[UIBarButtonItem alloc] initWithTitle:@">" style:UIBarButtonItemStylePlain target:self action:@selector(nextPage:)];
  [items addObject:button];
  [button release];
  
  [_toolBar setItems:items];
  
  [items release];
  
  [self.view addSubview:_toolBar];
}

- (void)loadView
{
  [super loadView];
  
  [self createToolBar];
  
  _scrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                              _toolBar.frame.size.height, 
                                                              self.view.frame.size.width,
                                                              self.view.frame.size.height - _toolBar.frame.size.height)];
  [_scrollView setHidden:YES];
  [self.view addSubview:_scrollView];
  
  // Resizing GFRenderView
  _renderView.frame = CGRectMake(0,
                                 _toolBar.frame.size.height, 
                                 self.view.frame.size.width,
                                 self.view.frame.size.height - _toolBar.frame.size.height);
  
  [self.view bringSubviewToFront:_renderView];

}

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
