//
//  SearchViewController.h
//  PDF
//
//  Created by Anton Kolchunov on 20.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFRenderViewController.h"
#import "IntelligentSplitViewController.h"

@protocol SearchViewControllerDelegate <NSObject>

@optional
- (void)showSelectedPage:(NSInteger)index;

@end

@protocol SearchTableViewControllerDelegate <NSObject>

@required
- (void)searchCompleted;

@end

@class SearchTableViewController, SearchPDFPageViewController;

@interface SearchViewController : UIViewController <UISplitViewControllerDelegate, UIPopoverControllerDelegate, GFPDFRenderDataSource> {
  
  SearchTableViewController *_tableViewController;
  
  SearchPDFPageViewController *_renderViewController;
  
  IntelligentSplitViewController *_splitViewController;
  
  UIPopoverController  *_popOver;
  
  UIToolbar *_toolBar;
  
  UIBarButtonItem *_resultsButton;
  
  NSString *_fileName;
  
  id<SearchViewControllerDelegate> _delegate;
  
  CGPDFDocumentRef _pdfFile;
  
  NSInteger selectedPage_;
  
  BOOL onScreen_;
  
}
@property (assign) id<SearchViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil pdfFile:(CGPDFDocumentRef)pdfRef fileName:(NSString*)fileName;

- (IBAction)dismiss:(id)sender;

- (IBAction)showResults:(id)sender;

- (CGPDFDocumentRef)pdfFile;

@end


@interface SearchTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
  
  UISearchBar *_searchBar;
  
  UITableView *_tableView;
  
  UIViewController<GFPDFRenderDataSource> *_searchViewController;
  
  NSArray *_selections;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign)  UIViewController<GFPDFRenderDataSource> *searchViewController;
@property (nonatomic, readonly) NSArray *selections;

- (void)searchForText:(NSString*)text;

@end


@interface SearchPDFPageViewController : UIViewController {
  
}

@end