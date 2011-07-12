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

#define ZOOM_AMOUNT 0.25f
#define NO_ZOOM_SCALE 1.0f
#define MINIMUM_ZOOM_SCALE 1.0f
#define MAXIMUM_ZOOM_SCALE 5.0f

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
  _scrollView.scrollsToTop = NO;
	_scrollView.directionalLockEnabled = YES;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.contentMode = UIViewContentModeRedraw;
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.minimumZoomScale = MINIMUM_ZOOM_SCALE; _scrollView.maximumZoomScale = MAXIMUM_ZOOM_SCALE;
	_scrollView.contentSize = _scrollView.bounds.size;
	_scrollView.backgroundColor = [UIColor clearColor];
	_scrollView.delegate = self;
  [self.view addSubview:_scrollView];
  
  _tiledRenderView = [[GFRenderTiledView alloc] initWithFrame:_scrollView.bounds];
  _tiledRenderView.dataSource = self;
  [_scrollView addSubview:_tiledRenderView];
  
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

- (CGPDFDocumentRef)document
{
  return _pdf;
}

- (CGPDFPageRef)page
{
  return CGPDFDocumentGetPage(_pdf, currentIndex_ + 1); 
}


- (IBAction)nextPage:(id)sender
{
  if ( _scrollView.zoomScale == 1.f )
  {  
    if ( _scrollView.hidden == NO )
    {
      _scrollView.hidden = YES;      
      
      _renderView.hidden = NO;
    }
    
    currentIndex_ = _renderView.currentItem = _renderView.currentItem+1;
  }
}

- (IBAction)prevPage:(id)sender
{
  if ( _scrollView.zoomScale == 1.f )
  {
    if ( _scrollView.hidden == NO )
    {
      _scrollView.hidden = YES;   
      
      _renderView.hidden = NO;
    }
    
    currentIndex_ = _renderView.currentItem = _renderView.currentItem-1;
  }
}

- (void)beginZoom
{
  _scrollView.hidden = NO;
  
  _renderView.hidden = YES;
  
  [_tiledRenderView reloadData];
  
  [self.view bringSubviewToFront:_scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _tiledRenderView;
}

@end
