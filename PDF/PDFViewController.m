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

- (void)addPinchRegonizer
{
  _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	_pinch.cancelsTouchesInView = NO; 
  _pinch.delaysTouchesEnded = NO; //tapGesture.delegate = self;
	[_renderView addGestureRecognizer:_pinch]; 
}

- (void)addDoubleTapRecognizer
{
  
}

- (void)createToolBar
{
  _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
  _toolBar.barStyle = UIBarStyleDefault;
  _toolBar.center = CGPointMake(self.view.frame.size.width/2, _toolBar.frame.size.height/2);
  _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  
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
  
  _hostView = [[UIView alloc] initWithFrame:_scrollView.bounds];
  _hostView.autoresizesSubviews = NO;
  _hostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [_scrollView addSubview:_hostView];
               
  _leftTiledRenderView = [[GFRenderTiledView alloc] initWithFrame:_scrollView.bounds];
  _leftTiledRenderView.dataSource = self;
  _leftTiledRenderView.hidden = YES;
  _leftTiledRenderView.mode = GFTiledRenderViewModeLeft;
  [_hostView addSubview:_leftTiledRenderView];
  
  _rightTiledRenderView = [[GFRenderTiledView alloc] initWithFrame:_scrollView.bounds];
  _rightTiledRenderView.dataSource = self;
  [_hostView addSubview:_rightTiledRenderView];
  
  if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) )
  {
    _leftTiledRenderView.hidden = NO; 
    _leftTiledRenderView.frame = CGRectMake(0, 
                                            0, 
                                            _scrollView.frame.size.width/2, 
                                            _scrollView.frame.size.height);
    _leftTiledRenderView.frame = CGRectMake(_leftTiledRenderView.frame.size.width, 
                                            0, 
                                            _leftTiledRenderView.frame.size.width, 
                                            _leftTiledRenderView.frame.size.height); 
  }
  
  // Resizing GFRenderView
  _renderView.frame = CGRectMake(0,
                                 _toolBar.frame.size.height, 
                                 self.view.frame.size.width,
                                 self.view.frame.size.height - _toolBar.frame.size.height);
  
  [self.view bringSubviewToFront:_renderView];
  
  zooming_ = NO;

  [self addPinchRegonizer];
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchesOne:)];
	tapGesture.cancelsTouchesInView = NO; 
  tapGesture.delaysTouchesEnded = NO; //tapGesture.delegate = self;
	tapGesture.numberOfTouchesRequired = 1; 
  tapGesture.numberOfTapsRequired = 2; // One finger double tap
	[self.view addGestureRecognizer:tapGesture]; 
  [tapGesture release];

}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  NSString *path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"pdf"];
  NSURL *fileURL = [NSURL fileURLWithPath:path];
  
  _pdf = CGPDFDocumentCreateWithURL((CFURLRef)fileURL);
  
  _fileName = [[NSString alloc] initWithString:@"Test"];
      
  [super viewDidLoad];
  
  [_rightTiledRenderView reloadData];
  [_leftTiledRenderView reloadData];

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

- (CGPDFPageRef)pageAtIndex:(NSInteger)index
{
  return CGPDFDocumentGetPage(_pdf, index + 1); 
}

- (CGPDFPageRef)pageWithOffset:(NSInteger)offset {
  return CGPDFDocumentGetPage(_pdf, currentIndex_ + offset + 1); 
}

- (void)switchViews:(BOOL)zoomin
{
  if ( zoomin )
  {
    [self.view bringSubviewToFront:_scrollView];
    [_renderView setHidden:YES];
  }
  else
  {
    [_renderView setHidden:NO];
    [self.view bringSubviewToFront:_renderView];
  }
}

- (IBAction)nextPage:(id)sender
{
  if ( _scrollView.zoomScale == 1.f )
  {  
    if ( zooming_ == YES )
    {
      zooming_ = NO;
      [self switchViews:NO];
      _renderView.lockedOtherView = NO;
    }
    
    currentIndex_ = _renderView.currentItem = _renderView.currentItem+1;
    [_rightTiledRenderView reloadData];

  }
}

- (IBAction)prevPage:(id)sender
{
  if ( _scrollView.zoomScale == 1.f )
  {
    if ( zooming_ == YES )
    {
      zooming_ = NO;
      [self switchViews:NO];
      _renderView.lockedOtherView = NO;
    }

    currentIndex_ = _renderView.currentItem = _renderView.currentItem-1;
    [_rightTiledRenderView reloadData];

  }
}

- (void)beginZoom
{    
  zooming_ = YES;

  _renderView.lockedOtherView = YES;
    
  CGFloat zoomScale = _scrollView.zoomScale;

  if (zoomScale < MAXIMUM_ZOOM_SCALE) // Zoom in if below maximum zoom scale
  {
    zoomScale = ((zoomScale += ZOOM_AMOUNT) > MAXIMUM_ZOOM_SCALE) ? MAXIMUM_ZOOM_SCALE : zoomScale;
  }

  [_scrollView setZoomScale:zoomScale animated:YES];

  [self switchViews:YES];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _hostView;
}

- (void)handleTouchesOne:(UITapGestureRecognizer *)recognizer
{
  CGRect tapAreaRect = CGRectZero;
	CGRect viewBounds = recognizer.view.bounds;
	CGPoint tapLocation = [recognizer locationInView:recognizer.view];
  NSInteger numberOfTaps = recognizer.numberOfTapsRequired;

  if (numberOfTaps == 2)	// Zoom area handling (double tap)
  {
    tapAreaRect = CGRectInset(viewBounds, 48.f, 48.f);
    
    if (CGRectContainsPoint(tapAreaRect, tapLocation))
    {
      CGFloat zoomScale = _scrollView.zoomScale;
      
      if (zoomScale < MAXIMUM_ZOOM_SCALE) // Zoom in if below maximum zoom scale
      {
        zoomScale = ((zoomScale += ZOOM_AMOUNT) > MAXIMUM_ZOOM_SCALE) ? MAXIMUM_ZOOM_SCALE : zoomScale;
        
        [_scrollView setZoomScale:zoomScale animated:YES];
      }
    }
  }
}

- (void)handlePinch:(UIPinchGestureRecognizer*)recongnizer
{
  NSLog(@"PINCH! %f", recongnizer.scale);
  CGFloat zoomScale = _scrollView.zoomScale;
  
  if (zoomScale < MAXIMUM_ZOOM_SCALE) // Zoom in if below maximum zoom scale
  {
    zoomScale = ((zoomScale += recongnizer.scale/5) > MAXIMUM_ZOOM_SCALE) ? MAXIMUM_ZOOM_SCALE : zoomScale;
    
    [_scrollView setZoomScale:zoomScale animated:YES];
  }


  [self switchViews:YES];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
  if ( scale == 1.f )
  {
    zooming_ = NO;
    [self switchViews:NO];
    _renderView.lockedOtherView = NO;
  }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
  
  [UIView animateWithDuration:duration animations:^(void) {
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) )
    {
      _leftTiledRenderView.hidden = YES;
      _rightTiledRenderView.frame = _scrollView.bounds;
    }
    else
    {
      NSLog(@"_scrollView frame: %fx%f", _scrollView.frame.size.width, _scrollView.frame.size.height);
      _leftTiledRenderView.hidden = NO; 
      _leftTiledRenderView.frame = CGRectMake(0, 
                                              0, 
                                              _scrollView.frame.size.width/2, 
                                              _scrollView.frame.size.height);
      _leftTiledRenderView.frame = CGRectMake(_leftTiledRenderView.frame.size.width, 
                                              0, 
                                              _leftTiledRenderView.frame.size.width, 
                                              _leftTiledRenderView.frame.size.height);
    }
  }];
}
@end
