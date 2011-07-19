//
//  ContentViewController.h
//  PDF
//
//  Created by Anton Kolchunov on 19.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ContentDataSource;

@protocol ContentViewControllerDelegate <NSObject>

@required
- (void)goToPageAtIndex:(NSInteger)index;

@end

@interface ContentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>  {
 
  UITableView *_tableView;
    
  NSArray *_items;
  
  NSDictionary *_links;
  
  id<ContentViewControllerDelegate> _delegate;
  
}
@property (assign) id<ContentViewControllerDelegate> delegate;

- (id)initWithPDF:(CGPDFDocumentRef)pdfRef;

@end
