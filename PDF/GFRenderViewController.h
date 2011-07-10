//
//  GFRenderViewController.h
//  PDF
//
//  Created by Anton Kolchunov on 11.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFRenderProtocols.h"
@class GFRenderView;

@interface GFRenderViewController : UIViewController <GFRenderDataSource, GFRenderDelegate> {
  GFRenderView *_renderView;
}

@property (nonatomic, retain) IBOutlet GFRenderView *renderView;

- (id)init;

@end
