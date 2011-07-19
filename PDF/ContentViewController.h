//
//  ContentViewController.h
//  PDF
//
//  Created by Anton Kolchunov on 19.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ContentDataSource;

@interface ContentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>  {
 
  UITableView *_tableView;
  CGPDFDocumentRef _pdf;
  
}

- (id)initWithPDF:(CGPDFDocumentRef)pdfRef;

@end
