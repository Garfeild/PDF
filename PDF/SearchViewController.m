//
//  SearchViewController.m
//  PDF
//
//  Created by Anton Kolchunov on 20.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"


@implementation SearchViewController

@synthesize delegate = _delegate;
@synthesize toolBar = _toolBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  _tableViewController = [[SearchTableViewController alloc] initWithNibName:@"SearchTableViewController" bundle:nil];
  _tableViewController.contentSizeForViewInPopover = CGSizeMake(320, 640);
  
  _renderViewController = [[SearchPDFPageViewController alloc] init];
  
  NSArray *vcs = [[NSArray alloc] initWithObjects:
                  _tableViewController,
                  _renderViewController,
                  nil];
  
  _splitViewController = [[UISplitViewController alloc] init];
  _splitViewController.view.frame = CGRectMake(0, _toolBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-_toolBar.frame.size.height);
  _splitViewController.viewControllers = vcs;
  [vcs release];
  
  _popOver = [[UIPopoverController alloc] initWithContentViewController:_tableViewController];
  _popOver.delegate = self;
  
  _resultsButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStyleBordered target:self action:@selector(showResults:)];
  
  [self.view addSubview:_splitViewController.view];
  
  [self.view bringSubviewToFront:_toolBar];
  
  onScreen_ = NO;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
  NSLog(@"Appear");
  [super viewDidAppear:animated];

  NSMutableArray *items = [[_toolBar items] mutableCopy];
  if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) )
  {
    [items insertObject:_resultsButton atIndex:0];
  }
  else
  {
    [items removeObject:_resultsButton]; 
  }
  [_toolBar setItems:items];
  [items release];
  
  onScreen_ = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
  return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  NSLog(@"Will Rotate");
  if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && _popOver != nil && [_popOver isPopoverVisible] )
    [_popOver dismissPopoverAnimated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  NSLog(@"Did rotate");
  
  if ( onScreen_ )
  {
    NSMutableArray *items = [[_toolBar items] mutableCopy];
    
    if ( UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) )
    {
      [items removeObject:_resultsButton]; 
    }
    else
    {
      [items insertObject:_resultsButton atIndex:0];
    }
    
    [_toolBar setItems:items];
    [items release];
  }
}

- (IBAction)dismiss:(id)sender
{
  if ( _delegate != nil && [_delegate respondsToSelector:@selector(showSelectedPage:)] )
    [_delegate showSelectedPage:selectedPage_];
  
  [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)showResults:(id)sender
{
  if ( _popOver != nil )
  {
    if ( ![_popOver isPopoverVisible] )
      [_popOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    else
      [_popOver dismissPopoverAnimated:YES];
  }
}

@end


@implementation SearchTableViewController

@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;

- (void)searchForText:(NSString*)text
{
  
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  [self searchForText:searchBar.text];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identificator = @"SearchCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identificator];
  
  if ( cell == nil )
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identificator];
  }
  
  return cell;
}

@end


@implementation SearchPDFPageViewController

- (void)loadView
{
  [super loadView];
  
  self.view.backgroundColor = [UIColor redColor];
}
@end