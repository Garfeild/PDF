//
//  SearchViewController.m
//  PDF
//
//  Created by Anton Kolchunov on 20.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "PDFViewController.h"
#import "ContentViewController.h"
#import "Scanner.h"

@implementation SearchTableViewController

@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize pdfViewController = _pdfViewController;
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
  
  Scanner *scanner = [[Scanner alloc] initWithDocument:[_pdfViewController document]];
	[scanner setKeyword:text];
  int i =1;

  while ( i<=CGPDFDocumentGetNumberOfPages([_pdfViewController document]) )
  {  
    if ( [[NSThread currentThread] isCancelled] == YES )
      break;
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
    i++;
  }
  
	[scanner release]; scanner = nil;

  
  if ( [[NSThread currentThread] isCancelled] == NO )
  {
    
    _selections = [selections retain];
    [selections release];
    
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    if ( [_pdfViewController respondsToSelector:@selector(searchCompleted)] )
      [_pdfViewController performSelectorOnMainThread:@selector(searchCompleted) withObject:nil waitUntilDone:NO];
  }
  [pool drain];
  if ( [[NSThread currentThread] isCancelled] == YES )
    [NSThread exit];
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
    
  cell.textLabel.text = [NSString stringWithFormat:@"Page #%d", [[dict objectForKey:kPageNumber] intValue]];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"Occures %d times", [[dict objectForKey:kSelections] count]];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *dict = [_selections objectAtIndex:indexPath.row];

  if ( [(PDFViewController<ContentViewControllerDelegate>*)_pdfViewController respondsToSelector:@selector(goToPageAtIndex:)] )
      [(PDFViewController<ContentViewControllerDelegate>*)_pdfViewController goToPageAtIndex:[[dict objectForKey:kPageNumber] intValue]-1];
}

@end
