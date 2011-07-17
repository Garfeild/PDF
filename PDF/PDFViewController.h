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

@interface PDFViewController : GFRenderViewController <GFPDFRenderDataSource, UIScrollViewDelegate> {
  CGPDFDocumentRef _pdf;
  
  NSString *_fileName;
  
  UIToolbar *_toolBar;
  
  UIScrollView *_scrollView;
  
  UIView *_hostView;
  
  GFRenderTiledView *_rightTiledRenderView;
  GFRenderTiledView *_leftTiledRenderView;
  
  NSInteger currentIndex_;
  
  BOOL zooming_;
  
  UIPinchGestureRecognizer *_pinch;

}

- (IBAction)nextPage:(id)sender;
- (IBAction)prevPage:(id)sender;

@end
