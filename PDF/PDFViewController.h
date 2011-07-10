//
//  PDFViewController.h
//  PDF
//
//  Created by Anton Kolchunov on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFRenderView.h"
#import "GFRenderViewController.h"

@interface PDFViewController : GFRenderViewController {
  CGPDFDocumentRef _pdf;
  
  NSString *_fileName;
}

- (IBAction)nextPage:(id)sender;
- (IBAction)prevPage:(id)sender;

@end
