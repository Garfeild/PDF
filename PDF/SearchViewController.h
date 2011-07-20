//
//  SearchViewController.h
//  PDF
//
//  Created by Anton Kolchunov on 20.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchTableViewControllerDelegate <NSObject>

@required
- (void)searchCompleted;

@end

@class PDFViewController;

@interface SearchTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
  
  UISearchBar *_searchBar;
  
  UITableView *_tableView;
  
  PDFViewController *_pdfViewController;
  
  NSArray *_selections;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) PDFViewController *pdfViewController;
@property (nonatomic, readonly) NSArray *selections;

- (void)searchForText:(NSString*)text;

@end