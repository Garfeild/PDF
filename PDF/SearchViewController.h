//
//  SearchViewController.h
//  PDF
//
//  Created by Anton Kolchunov on 20.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFRenderViewController.h"

@protocol SearchViewControllerDelegate <NSObject>

@optional
- (void)showSelectedPage:(NSInteger)index;

@end


@interface SearchTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
  
  UISearchBar *_searchBar;
  UITableView *_tableView;
  
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end


@interface SearchPDFPageViewController : UIViewController {
  
}

@end


@interface SearchViewController : UIViewController <UISplitViewControllerDelegate> {
  
  SearchTableViewController *_tableViewController;
  
  SearchPDFPageViewController *_renderViewController;
  
  UISplitViewController *_splitViewController;
  
  UIToolbar *_toolBar;
  
  id<SearchViewControllerDelegate> _delegate;
  
  NSInteger selectedPage_;
  
}
@property (assign) id<SearchViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;

- (IBAction)dismiss:(id)sender;

@end