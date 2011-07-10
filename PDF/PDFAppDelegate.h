//
//  PDFAppDelegate.h
//  PDF
//
//  Created by Anton Kolchunov on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFViewController;

@interface PDFAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PDFViewController *viewController;

@end
