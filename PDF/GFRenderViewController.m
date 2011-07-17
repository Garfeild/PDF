//
//  GFRenderViewController.m
//  PDF
//
//  Created by Anton Kolchunov on 11.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GFRenderViewController.h"
#import "GFRenderView.h"
#import "GFImageCache.h"

@implementation GFRenderViewController

@synthesize renderView = _renderView;

- (void)initRender
{
  NSLog(@"Init render");
  _renderView = [[GFRenderView alloc] initWithFrame:CGRectZero];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  NSLog(@"Init");
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    [self initRender];
  }
  return self;
}

- (id)init {
  NSLog(@"Blank init");
  return [self initWithNibName:nil bundle:nil];
}

- (void) awakeFromNib {
  NSLog(@"AwakeFromNib");
	[super awakeFromNib];
}

- (void)dealloc
{ 
  [_renderView release];
  [super dealloc];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
  NSLog(@"Load view");
  [super loadView];
  
  _renderView.frame = self.view.bounds;
	_renderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_renderView];
  
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [[GFImageCache imageCache] setPageSize:_renderView.frame.size];
  
  NSLog(@"Size: %fx%f", _renderView.frame.size.width, _renderView.frame.size.height);
  
  _renderView.delegate = self;
  _renderView.dataSource = self;

  _renderView.renderViewMode = ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) ? GFRenderViewModeSinglePage : GFRenderViewModeFacingPages;

  [_renderView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  _renderView.renderViewMode = ( UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ) ? GFRenderViewModeSinglePage : GFRenderViewModeFacingPages;
}

#pragma mark - Data source methods

- (NSInteger)numberOfItems:(GFRenderView *)renderView
{
  return 0;
}

- (void)renderItemAtIndex:(NSInteger)index inContext:(CGContextRef)context
{
  
}

- (NSString*)fileName
{
  return @"<Noname>";
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"Touch");
  [_renderView touchesBegan:touches withEvent:event];
}
@end

