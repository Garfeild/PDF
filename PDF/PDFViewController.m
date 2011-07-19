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
#import "ContentViewController.h"

#define ZOOM_AMOUNT 0.25f
#define NO_ZOOM_SCALE 1.0f
#define MINIMUM_ZOOM_SCALE 1.0f
#define MAXIMUM_ZOOM_SCALE 5.0f

@interface PDFViewController (Workers)
- (void)updateTiledViewsFrames:(UIInterfaceOrientation)interfaceOrientation;
- (void)clearMemory;
- (void)showContent;
@end


@implementation PDFViewController

#pragma mark - View lifecycle

- (void)clearMemory
{
  [[GFImageCache imageCache] minimizeItems:currentIndex_ dataSource:self];
}

- (void)showContent
{
  UIPopoverController *content = [[UIPopoverController alloc] initWithContentViewController:_contentViewController];
  [content presentPopoverFromBarButtonItem:_contentButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
  
}

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
  
  button = [[UIBarButtonItem alloc] initWithTitle:@"Content" style:UIBarButtonItemStylePlain target:self action:@selector(showContent)];
  [items addObject:button];
  _contentButton = button;
  
  button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  button.width = 10.f;
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
  
  _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
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
  
  NSLog(@"_scrollView bounds: %fx%f (%f, %f)", _scrollView.frame.size.width, _scrollView.frame.size.height, _scrollView.frame.origin.x, _scrollView.frame.origin.y);
  
  _hostView = [[UIView alloc] initWithFrame:_scrollView.bounds];
  _hostView.autoresizesSubviews = NO;
	_hostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [_scrollView addSubview:_hostView];
  
  _rightTiledRenderView = [[GFRenderTiledView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.bounds.size.width/2, _scrollView.bounds.size.height)];
  _rightTiledRenderView.dataSource = self;
  _rightTiledRenderView.mode = GFRenderTiledViewModeRight;
  _rightTiledRenderView.hidden = NO;
  [_hostView addSubview:_rightTiledRenderView];
  
  _leftTiledRenderView = [[GFRenderTiledView alloc] initWithFrame:_scrollView.bounds];
  _leftTiledRenderView.dataSource = self;
  _leftTiledRenderView.mode = GFRenderTiledViewModeLeft;
  _leftTiledRenderView.rotated = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
  [_hostView addSubview:_leftTiledRenderView];
  
  // Resizing GFRenderView
  _renderView.frame = CGRectMake(0,
                                 _toolBar.frame.size.height, 
                                 self.view.frame.size.width,
                                 self.view.frame.size.height - _toolBar.frame.size.height);
  
  [self.view bringSubviewToFront:_renderView];

  [self addPinchRegonizer];
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouchesOne:)];
	tapGesture.cancelsTouchesInView = NO; 
  tapGesture.delaysTouchesEnded = NO; //tapGesture.delegate = self;
	tapGesture.numberOfTouchesRequired = 1; 
  tapGesture.numberOfTapsRequired = 2; // One finger double tap
	[self.view addGestureRecognizer:tapGesture]; 
  [tapGesture release];
    
  zooming_ = NO;
  
  rotating_ = NO;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  NSString *path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"pdf"];
  NSURL *fileURL = [NSURL fileURLWithPath:path];
  
  _pdf = CGPDFDocumentCreateWithURL((CFURLRef)fileURL);

  _contentViewController = [[ContentViewController alloc] initWithPDF:_pdf];

  _fileName = [[NSString alloc] initWithString:@"Test"];
      
  [super viewDidLoad];
  
  [_leftTiledRenderView reloadData];
  [_rightTiledRenderView reloadData];
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
  CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
  CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);
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

- (CGPDFPageRef)pageAtIndex:(NSInteger)index
{
  NSLog(@"Returnin page at index: %d", index);
  return CGPDFDocumentGetPage(_pdf, index + 1); 
}

- (CGPDFPageRef)page
{
  return [self pageAtIndex:currentIndex_]; 
}

- (CGPDFPageRef)pageWithOffset:(NSInteger)offset 
{
  return [self pageAtIndex:currentIndex_ + offset]; 
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
    
    _renderView.currentItem = _renderView.currentItem+1;
    [_leftTiledRenderView reloadData];
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

    _renderView.currentItem = _renderView.currentItem-1;
    [_leftTiledRenderView reloadData];
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

- (void)setCurrentIndex:(NSInteger)currentIndex
{
  currentIndex_ = currentIndex;
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
  
  NSLog(@"Will rotate");
  if ( UIInterfaceOrientationIsPortrait(toInterfaceOrientation) )
      _rightTiledRenderView.hidden = YES;

  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];  
  
  NSLog(@"Will | _hostView: %fx%f, (%f, %f)", _hostView.frame.size.width, _hostView.frame.size.height, _hostView.frame.origin.x, _hostView.frame.origin.y);
 
  [UIView animateWithDuration:duration animations:^(void) {
    CGRect bounds = self.view.bounds;
    CGFloat tmp = 0.f;
    
    tmp = bounds.size.height;
    bounds.size.height = bounds.size.width-44.f;
    bounds.size.width = tmp;
    
    if ( UIInterfaceOrientationIsPortrait(toInterfaceOrientation) )
    {
      _rightTiledRenderView.hidden = YES;
      _leftTiledRenderView.rotated = NO;
      
    }
    else
    {
      _rightTiledRenderView.hidden = NO;
      _leftTiledRenderView.rotated = YES;
      bounds.size.width /=2;
    }

    
    
    _leftTiledRenderView.frame = bounds;
    bounds.origin.x += bounds.size.width;
    _rightTiledRenderView.frame = bounds;
    
  } completion:^(BOOL finished) {
    [_leftTiledRenderView reloadData];
    [_rightTiledRenderView reloadData];
  }];
}

@end
