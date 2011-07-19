//
//  ContentViewController.m
//  PDF
//
//  Created by Anton Kolchunov on 19.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentViewController.h"


@implementation ContentViewController

@synthesize delegate = _delegate;

// Method to build table of contents
- (void)buildTableOfContents:(CGPDFDocumentRef)pdfRef
{
  /* In this method _items array should be populated with data from pdfRef */
  
  /* Dummy data */
  _items = [[NSArray alloc] initWithObjects:
            nil];
  
  NSArray *links = [[NSArray alloc] initWithObjects:
                    nil];
  
  _links = [[NSDictionary alloc] initWithObjects:links forKeys:_items];
}

- (id)initWithPDF:(CGPDFDocumentRef)pdfRef
{
  
  self = [super init];
  
  if ( self != nil )
  {
    [self buildTableOfContents:pdfRef];
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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
  [super loadView];
  
  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  [self.view addSubview:_tableView];
  
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  [_tableView reloadData];

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
	return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [_items count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identificator = @"ContentCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identificator];
  
  if ( cell == nil )
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identificator];
  }
  
  cell.textLabel.text = [_items objectAtIndex:indexPath.row];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ( _delegate != nil && [_delegate respondsToSelector:@selector(goToPageAtIndex:)] )
    [_delegate goToPageAtIndex:[[_links objectForKey:[_items objectAtIndex:indexPath.row]] intValue]-1];
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
