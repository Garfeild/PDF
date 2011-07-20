//
//  SearchViewController.m
//  PDF
//
//  Created by Anton Kolchunov on 20.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "Scanner.h"


@implementation SearchViewController

@synthesize delegate = _delegate;
@synthesize toolBar = _toolBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil pdfFile:(CGPDFDocumentRef)pdfRef fileName:(NSString *)fileName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      _fileName = [fileName retain];
      
      _pdfFile = CGPDFDocumentRetain(pdfRef);
      
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
  _tableViewController.searchViewController = self;
  
  _renderViewController = [[SearchPDFPageViewController alloc] init];
  
  NSArray *vcs = [[NSArray alloc] initWithObjects:
                  _tableViewController,
                  _renderViewController,
                  nil];
  
  _splitViewController = [[IntelligentSplitViewController alloc] init];
  _splitViewController.view.frame = CGRectMake(0, _toolBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-_toolBar.frame.size.height);
  _splitViewController.viewControllers = vcs;
  _splitViewController.delegate = self;
  [vcs release];
  
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
  if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) )
  { 
    if ( _popOver != nil && [_popOver isPopoverVisible] )
      [_popOver dismissPopoverAnimated:YES];
  }
}

- (IBAction)dismiss:(id)sender
{
  if ( _delegate != nil && [_delegate respondsToSelector:@selector(showSelectedPage:)] )
    [_delegate showSelectedPage:selectedPage_];
  
  if ( _popOver != nil && [_popOver isPopoverVisible] )
    [_popOver dismissPopoverAnimated:YES];
  
  [self.navigationController popViewControllerAnimated:YES];
  
//  [self.parentViewController dismissModalViewControllerAnimated:YES];
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

- (CGPDFDocumentRef)pdfFile
{
  return _pdfFile;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
  NSLog(@"???");
  
  if ( _resultsButton == nil )
    NSLog(@"WTF?");

  NSMutableArray *items = [[_toolBar items] mutableCopy];
  [items removeObject:_resultsButton]; 
  [_toolBar setItems:items];
  [items release];
  
  _popOver = [pc retain];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
  NSLog(@"!!!");
  NSMutableArray *items = [[_toolBar items] mutableCopy];
  [items removeObject:_resultsButton]; 
  [_toolBar setItems:items];
  [items release];
  
  [_popOver release];
  _popOver = nil;
}

- (NSString*)fileName
{
  return _fileName;
}

- (CGPDFDocumentRef)document
{
  return _pdfFile;
}

- (CGPDFPageRef)pageAtIndex:(NSInteger)index
{
  NSLog(@"Returnin page at index: %d", index);
  return CGPDFDocumentGetPage(_pdfFile, index + 1); 
}

- (CGPDFPageRef)page
{
  return [self pageAtIndex:0]; 
}

@end


@implementation SearchTableViewController

@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize searchViewController = _searchViewController;
@synthesize selections = _selections;

#define kSelections @"Selections"
#define kPageNumber @"Page Number"

- (void)searchForText:(NSString*)text
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  [NSThread sleepForTimeInterval:1.5f];
  
  NSMutableArray *selections = [[NSMutableArray alloc] init];
  
  if ( _selections != nil )
    [_selections release];
  
  Scanner *scanner = [[Scanner alloc] initWithDocument:[_searchViewController document]];
	[scanner setKeyword:text];
  
  for ( int i=1; i<=CGPDFDocumentGetNumberOfPages([_searchViewController document]); i++ )
  {
    [scanner scanPage:i];
    if ( [[scanner selections] count] > 0 )
    {
      NSLog(@"Page %d | Occures %d", i, [[scanner selections] count]);
      NSArray *selection = [[NSArray alloc] initWithArray:[scanner selections]];
      NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys: 
                            selection, kSelections,
                            [NSNumber numberWithInt:i], kPageNumber,
                            nil];
      [selections addObject:dict];
      [dict release];
      [selection release];
    }
  }
  
	[scanner release]; scanner = nil;
  
  _selections = [selections retain];
  [selections release];
  
  [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
  
  if ( [_searchViewController respondsToSelector:@selector(searchCompleted)] )
    [_searchViewController performSelectorOnMainThread:@selector(searchCompleted) withObject:nil waitUntilDone:NO];
  
  [pool drain];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [self searchForText:searchBar.text];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  [self searchForText:searchBar.text];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_selections count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identificator = @"SearchCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identificator];
  
  if ( cell == nil )
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identificator];
  }
  
  NSDictionary *dict = [_selections objectAtIndex:indexPath.row];
  
  NSLog(@"Dict %@", dict);
  
  cell.textLabel.text = [NSString stringWithFormat:@"Page #%d", [[dict objectForKey:kPageNumber] intValue]];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"Occures %d time", [[dict objectForKey:kSelections] count]];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *dict = [_selections objectAtIndex:indexPath.row];

  if ( [_searchViewController respondsToSelector:@selector(goToIndex:)] )
      [_searchViewController goToIndex:[[dict objectForKey:kPageNumber] intValue]];
}

@end


@implementation SearchPDFPageViewController

- (void)loadView
{
  [super loadView];
  
  self.view.backgroundColor = [UIColor redColor];
}
@end