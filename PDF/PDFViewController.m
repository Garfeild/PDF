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
#import "Selection.h"
#import "GFSelectionsDirector.h"

#define ZOOM_AMOUNT 0.05f
#define NO_ZOOM_SCALE 1.0f
#define MINIMUM_ZOOM_SCALE 1.0f
#define MAXIMUM_ZOOM_SCALE 5.0f

#define SEARCH_BAR_WIDTH 240.f

@interface PDFViewController (Workers)

// UIGestureRecognizers creation methods
- (void)addPinchRegonizer;

// Search placeholder
- (void)createSearchPlaceholder;
- (void)hidePlaceholder;

// Toolbar
- (void)createToolBar;
- (void)fillToolBarWithDefault;
- (void)fillToolBarSearch;
- (void)fillToolBarAfterSearch;
- (void)addOtherResultsButton;
- (void)removeOtherResultsButton;

// Buttons' actions
- (void)showContent:(id)sender;
- (void)showSearchView:(id)sender;
- (void)cancelSearch;
- (void)nextPage:(id)sender;
- (void)prevPage:(id)sender;

// Other methods
- (void)switchViews:(BOOL)zoomin;

@end


@implementation PDFViewController

#pragma mark - View lifecycle

- (void)loadView
{
  [super loadView];
  
  [self createToolBar];
  
  [self createSearchPlaceholder];
  
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
  
  _searchTableViewController = [[SearchTableViewController alloc] initWithNibName:@"SearchTableViewController" bundle:nil];
  _searchTableViewController.contentSizeForViewInPopover = CGSizeMake(240, 640);
  _searchTableViewController.pdfViewController = self;
  
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

  _fileName = [[NSString alloc] initWithString:@"Test"];
      
  [super viewDidLoad];
  
  [_leftTiledRenderView reloadData];
  [_rightTiledRenderView reloadData];
  
  _contentViewController = [[ContentViewController alloc] initWithPDF:_pdf];
  [_contentViewController setDelegate:self];
  
  CGSize size = self.view.bounds.size;
  size.width = 320.f;
  size.height -= 100.f;
  _contentViewController.contentSizeForViewInPopover = size;
  
  searching_ = NO;
  
  shouldBeginEdit_ = YES;
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  CGSize size = self.view.bounds.size;
  size.width = 320.f;
  size.height -= 100.f;
  _contentViewController.contentSizeForViewInPopover = size;
}


#pragma mark -
#pragma mark UIGestureRecognizers creation methods

- (void)addPinchRegonizer
{
  _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	_pinch.cancelsTouchesInView = NO; 
  _pinch.delaysTouchesEnded = NO; //tapGesture.delegate = self;
	[_renderView addGestureRecognizer:_pinch]; 
}


#pragma mark -
#pragma mark Search placeholder methods

- (void)createSearchPlaceholder
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  _searchPlaceholder = [[UIView alloc] initWithFrame:self.view.bounds];
  _searchPlaceholder.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7f];
  _searchPlaceholder.alpha = 0.f;
  _searchPlaceholder.hidden = YES;
  _searchPlaceholder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:_searchPlaceholder];
  
  _searchIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _searchIndicator.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
  _searchIndicator.alpha = 0.f;
  _searchIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  [_searchIndicator startAnimating];
  [_searchPlaceholder addSubview:_searchIndicator];
  
  _searchLabel = [[UILabel alloc] init];
  _searchLabel.font = [UIFont systemFontOfSize:24];
  _searchLabel.textColor = [UIColor whiteColor];
  _searchLabel.backgroundColor = [UIColor clearColor];
  _searchLabel.alpha = 0.f;
  _searchLabel.text = @"Searching...";
  _searchLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  [_searchLabel sizeToFit];
  _searchLabel.center = CGPointMake(_searchIndicator.center.x, _searchIndicator.center.y - 10.f - (_searchIndicator.frame.size.height + _searchIndicator.frame.size.height)/2);
  [_searchPlaceholder addSubview:_searchLabel];
  
  [pool drain];
}

- (void)hidePlaceholder
{
  [UIView animateWithDuration:.35f animations:^(void) {
    _searchPlaceholder.alpha = 0.f;
    [self fillToolBarAfterSearch];
  } completion:^(BOOL finished) {
    _searchPlaceholder.hidden = YES;
    _searchIndicator.alpha = 0.f;
    _searchLabel.alpha = 0.f;
    [_renderView updateCurrentPage];
  }];
}


#pragma mark - 
#pragma mark Toolbar filling methods

- (void)createToolBar
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
  _toolBar.barStyle = UIBarStyleDefault;
  _toolBar.center = CGPointMake(self.view.frame.size.width/2, _toolBar.frame.size.height/2);
  _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  
  _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SEARCH_BAR_WIDTH, _toolBar.frame.size.height)];
  _searchBar.delegate = self;
  
  [self fillToolBarWithDefault];
  
  [self.view addSubview:_toolBar];
  
  [pool drain];
}

- (void)fillToolBarWithDefault
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  UIBarButtonItem *button = nil;
  NSMutableArray *items = [[NSMutableArray alloc] init];
  
  button = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStyleBordered target:self action:@selector(prevPage:)];
  [items addObject:button];
  [button release];
  
  button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  button.width = 10.f;
  [items addObject:button];
  [button release];
  
  button = [[UIBarButtonItem alloc] initWithTitle:@"Content" style:UIBarButtonItemStyleBordered target:self action:@selector(showContent:)];
  [items addObject:button];
  [button release];
  
  button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  [items addObject:button];
  [button release];
  
  button = [[UIBarButtonItem alloc] initWithCustomView:_searchBar];
  [items addObject:button];
  [button release];
  
  button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  button.width = 10.f;
  [items addObject:button];
  [button release];
  
  button = [[UIBarButtonItem alloc] initWithTitle:@">" style:UIBarButtonItemStyleBordered target:self action:@selector(nextPage:)];
  [items addObject:button];
  [button release];
  
  [_toolBar setItems:items];
  
  [items release];
  [pool drain];
}

- (void)fillToolBarSearch
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  UIBarButtonItem *button = nil;
  NSMutableArray *items = [[NSMutableArray alloc] init];
  
  _searchBar.frame = CGRectMake(0, 0, _toolBar.frame.size.width - 100.f, _toolBar.frame.size.height);
  
  [_toolBar setItems:nil];
  
  button = [[UIBarButtonItem alloc] initWithCustomView:_searchBar];
  [items addObject:button];
  [button release];
  
  button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  button.width = 10.f;
  [items addObject:button];
  [button release];
  
  button = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelSearch)];
  [items addObject:button];
  [button release];
  
  [_toolBar setItems:items];
  
  [items release];
  [pool drain];
}

- (void)fillToolBarAfterSearch
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  [_toolBar setItems:nil];

  _searchBar.frame = CGRectMake(0, 0, SEARCH_BAR_WIDTH, _toolBar.frame.size.height);
  
  [self fillToolBarWithDefault];
  
  if ( [[[GFSelectionsDirector sharedDirector] selections] count] > 1 )
    [self addOtherResultsButton];
  [pool drain];
}

- (void)addOtherResultsButton
{
  NSMutableArray *items = [[_toolBar items] mutableCopy];
  
  UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Other results" style:UIBarButtonItemStyleBordered target:self action:@selector(showSearchView:)];
  [items insertObject:button atIndex:[items count]-1];
  [button release];
  
  button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
  button.width = 10.f;
  [items insertObject:button atIndex:[items count]-1];
  [button release];
  
  _toolBar.items = items;
  [items release];
}

- (void)removeOtherResultsButton
{
  NSMutableArray *items = [[_toolBar items] mutableCopy];
  
  for ( int i=0; i<2; i++ )
    [items removeObjectAtIndex:[items count]-2];  
  
  _toolBar.items = items;
  [items release];
}


#pragma mark -
#pragma mark GFRenderDataSource's methods

//Optional methods

- (NSInteger)numberOfItems:(GFRenderView *)renderView
{
  return CGPDFDocumentGetNumberOfPages(_pdf);
}

- (void)renderItemAtIndex:(NSInteger)index inContext:(CGContextRef)context
{
  NSLog(@"Rendering");
  CGPDFPageRef page = CGPDFDocumentGetPage(_pdf, index + 1);
	CGAffineTransform transform = aspectFit(CGPDFPageGetBoxRect(page, kCGPDFMediaBox),
                                          CGContextGetClipBoundingBox(context));
	CGContextConcatCTM(context, transform);
  CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
  CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);
	CGContextDrawPDFPage(context, page);
  
  for (Selection *s in [[GFSelectionsDirector sharedDirector] selectionsForIndex:index] )
	{
		CGContextSaveGState(context);
		
		CGContextConcatCTM(context, [s transform]);
		CGContextSetFillColorWithColor(context, [[UIColor yellowColor] CGColor]);
		CGContextSetBlendMode(context, kCGBlendModeMultiply);
		CGContextFillRect(context, [s frame]);
		
		CGContextRestoreGState(context);
	}
}

- (NSString*)fileName
{
  return _fileName;
}


#pragma mark -
#pragma mark GFPDFRenderDataSource's methods

// Required methods

- (CGPDFDocumentRef)document
{
  return _pdf;
}

- (CGPDFPageRef)page
{
  return [self pageAtIndex:currentIndex_]; 
}

// Optional methods

- (CGPDFPageRef)pageAtIndex:(NSInteger)index
{
  NSLog(@"Returnin page at index: %d", index);
  return CGPDFDocumentGetPage(_pdf, index + 1); 
}

- (CGPDFPageRef)pageWithOffset:(NSInteger)offset 
{
  return [self pageAtIndex:currentIndex_ + offset]; 
}

- (NSInteger)currentPageIndex
{
  return currentIndex_+1;
  [_leftTiledRenderView reloadData];
  [_rightTiledRenderView reloadData];
}


#pragma mark -
#pragma mark GFRenderDelegate's methods

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
  alreadyZoomed_ = NO;
}


#pragma mark - 
#pragma mark ContentViewControllerDelegate's methods

- (void)goToPageAtIndex:(NSInteger)index
{
  NSLog(@"Go to page: %d", index);
  
  if ( [_popOver isPopoverVisible] )
    [_popOver dismissPopoverAnimated:YES];
  
  if ( [_searchPopover isPopoverVisible] )
  {
    [_searchPopover dismissPopoverAnimated:YES];
    
  }
  
  _renderView.currentItem = index;
  
}


#pragma mark -
#pragma mark SearchTableViewControllerDelegate's methods

- (void)searchCompleted
{  
  [[GFSelectionsDirector sharedDirector] setSelections:_searchTableViewController.selections];
  [self hidePlaceholder];
  searching_ = NO;
}


#pragma mark -
#pragma mark UISearchBar delegate's methods

- (void)beginSearch:(NSString*)text
{
  NSLog(@"Begin search");
  
  searching_ = YES;
  
  [NSThread detachNewThreadSelector:@selector(searchForText:) toTarget:_searchTableViewController withObject:text];
  
  [UIView animateWithDuration:.35f animations:^(void) {
    _searchIndicator.alpha = 1.f;
    _searchLabel.alpha = 1.f;
  }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  NSLog(@"Search 1");
  if ( searchBar.text.length > 0 )
    [self beginSearch:searchBar.text];
  
  [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  NSLog(@"Search 2 | %@", searchBar.text);
  if ( searching_ == NO )
  {
    if ( searchBar.text.length > 0 )
    {
      [self beginSearch:searchBar.text];
    }
    [searchBar resignFirstResponder];
  }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
  if ( shouldBeginEdit_ == NO ) 
  {
    shouldBeginEdit_ = YES;
    return NO;
  }
  
  [self.view bringSubviewToFront:_searchPlaceholder];
  
  [self.view bringSubviewToFront:_toolBar];
  
  _searchPlaceholder.hidden = NO;
  
  [UIView animateWithDuration:.35f animations:^(void) {
    [self fillToolBarSearch];
    _searchPlaceholder.alpha = 1.f;
    
  }];
  return !searching_;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  if ([searchText length] == 0)
  {
    if ( _searchPlaceholder.hidden == YES )
    {
      [self removeOtherResultsButton];
      shouldBeginEdit_ = NO;
    }
    
    [[GFSelectionsDirector sharedDirector] setSelections:nil];
    
    [_renderView updateCurrentPage];

  }
}


#pragma mark -
#pragma mark UIScrollView delegate's methods

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
  //  [_leftTiledRenderView reloadData];
  //  [_rightTiledRenderView reloadData];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _hostView;
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


#pragma mark -
#pragma mark Buttons' actions

- (void)checkOtherPopovers:(UIPopoverController*)popover
{
  if ( ![_popOver isEqual:popover] )
    [_popOver dismissPopoverAnimated:YES];
  
  if ( ![_searchPopover isEqual:popover] )
    [_searchPopover dismissPopoverAnimated:YES];
}

- (void)showContent:(id)sender
{
  if ( ![_popOver isPopoverVisible] )
  {
    [self checkOtherPopovers:_popOver];
    if ( _popOver == nil )
      _popOver = [[UIPopoverController alloc] initWithContentViewController:_contentViewController];
    [_popOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
  }
  else
    [_popOver dismissPopoverAnimated:YES];
}

- (void)showSearchView:(id)sender
{
  if ( ![_searchPopover isPopoverVisible] )
  {
    [self checkOtherPopovers:_searchPopover];
    if ( _searchPopover == nil )
      _searchPopover = [[UIPopoverController alloc] initWithContentViewController:_searchTableViewController];
    [_searchPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
  }
  else
    [_searchPopover dismissPopoverAnimated:YES];
}

- (void)cancelSearch
{
  _searchBar.text = @"";
  [_searchBar resignFirstResponder];
  
  [self hidePlaceholder];
}

- (void)nextPage:(id)sender
{
  if ( _scrollView.zoomScale == 1.f )
  {  
    if ( zooming_ == YES )
    {
      zooming_ = NO;
      [self switchViews:NO];
      _renderView.lockedOtherView = NO;
    }
    
    alreadyZoomed_ = NO;
    
    [_leftTiledRenderView reloadData];
    [_rightTiledRenderView reloadData];
    
  }
}

- (void)prevPage:(id)sender
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


#pragma mark -
#pragma mark Gestures recognizers

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
  NSLog(@"PINCH! %f | %f", recongnizer.scale, recongnizer.velocity);
  CGFloat velocity = ( recongnizer.velocity >= 0 ) ? 1 : -1;  
  CGFloat zoomScale = _scrollView.zoomScale;
  
  if (zoomScale < MAXIMUM_ZOOM_SCALE) // Zoom in if below maximum zoom scale
  {
    zoomScale = ((zoomScale += velocity*recongnizer.scale/7) > MAXIMUM_ZOOM_SCALE) ? MAXIMUM_ZOOM_SCALE : zoomScale;
    
    [_scrollView setZoomScale:zoomScale animated:YES];
  }
  
  if ( zooming_ == NO )
    [self switchViews:YES];
}


#pragma mark -
#pragma mark Other methods

- (void)switchViews:(BOOL)zoomin
{
  if ( zoomin )
  {
    [self.view bringSubviewToFront:_scrollView];
    [_renderView setHidden:YES];
    
    if ( alreadyZoomed_ == NO ) 
    {
      alreadyZoomed_ = YES;
      [_leftTiledRenderView reloadData];
      [_rightTiledRenderView reloadData];
    }
    
  }
  else
  {
    [_renderView setHidden:NO];
    [self.view bringSubviewToFront:_renderView];
  }
}

@end
