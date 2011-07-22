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
  
  
  // Toolbar
  
  UIToolbar *_toolBar;
  
  
  // Zooming in scroll view
  
  UIScrollView *_scrollView;
  
  UIView *_hostView;
  
  GFRenderTiledView *_rightTiledRenderView;
  
  GFRenderTiledView *_leftTiledRenderView;

  UIPinchGestureRecognizer *_pinch;

  
  // Search placeholder
  
  UIView *_searchPlaceholder;
  
  UIActivityIndicatorView *_searchIndicator;
  
  UILabel *_searchLabel;

  
  // Content
      
  ContentViewController *_contentViewController;
  
  UIPopoverController *_popOver;
  
  
  // Search
  
  UIPopoverController *_searchPopover;
  
  UISearchBar *_searchBar;
  
  SearchTableViewController *_searchTableViewController;
  
  
  NSInteger currentIndex_;
  
  BOOL zooming_;
  
  BOOL rotating_;
  
  BOOL alreadyZoomed_;
  
  BOOL searching_;
  
  BOOL shouldBeginEdit_;

}

- (void)goToPageAtIndex:(NSInteger)index;

@end
