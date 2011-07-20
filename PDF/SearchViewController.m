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
  _tableViewController.contentSizeForViewInPopover = CGSizeMake(120, 600);
  
  _renderViewController = [[SearchPDFPageViewController alloc] init];
  
  NSArray *vcs = [[NSArray alloc] initWithObjects:
                  _tableViewController,
                  _renderViewController,
                  nil];
  
  _splitViewController = [[UISplitViewController alloc] init];
  _splitViewController.delegate = self;
  _splitViewController.view.frame = CGRectMake(0, _toolBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-_toolBar.frame.size.height);
  _splitViewController.viewControllers = vcs;
  [vcs release];
  
  [self.view addSubview:_splitViewController.view];
  
  [self.view bringSubviewToFront:_toolBar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)dismiss:(id)sender
{
  if ( _delegate != nil && [_delegate respondsToSelector:@selector(showSelectedPage:)] )
    [_delegate showSelectedPage:selectedPage_];
  
  [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
  NSMutableArray *items = [[_toolBar items] mutableCopy];
  [items insertObject:barButtonItem atIndex:0];
  NSLog(@"Items count: %d", [items count]);
  [_toolBar setItems:items animated:YES];
  [items release];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
  NSMutableArray *items = [[_toolBar items] mutableCopy];
  [items removeObjectAtIndex:0];
  [_toolBar setItems:items animated:YES];
  [items release];
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