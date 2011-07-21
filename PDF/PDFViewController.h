//
//  PDFViewController.h
//  PDF
//
//  Created by Anton Kolchunov on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFRenderView.h"
#import "GFRenderTiledView.h"
#import "GFRenderViewController.h"
#import "ContentViewController.h"
#import "SearchViewController.h"

@interface PDFViewController : GFRenderViewController <GFPDFRenderDataSource, UIScrollViewDelegate, ContentViewControllerDelegate, SearchTableViewControllerDelegate, UISearchBarDelegate> {
  CGPDFDocumentRef _pdf;
  
  NSString *_fileName;
  
  UIToolbar *_toolBar;
  
  UIScrollView *_scrollView;
  
  UIView *_hostView;
  
  UIView *_searchPlaceholder;
  
  GFRenderTiledView *_rightTiledRenderView;
  GFRenderTiledView *_leftTiledRenderView;
  
  NSInteger currentIndex_;
  
  BOOL zooming_;
  
  BOOL rotating_;
  
  BOOL alreadyZoomed_;
  
  UIPinchGestureRecognizer *_pinch;
  
  UIBarButtonItem *_contentButton;
  
  ContentViewController *_contentViewController;
  
  UIPopoverController *_popOver;
  
  UIPopoverController *_searchPopover;
  
  UISearchBar *_searchBar;
  
  SearchTableViewController *_searchTableViewController;

}

- (IBAction)nextPage:(id)sender;
- (IBAction)prevPage:(id)sender;

- (void)goToPageAtIndex:(NSInteger)index;

@end
