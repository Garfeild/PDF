//
//  GFSelectionsDirector.h
//  PDF
//
//  Created by Anton Kolchunov on 21.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Selection.h"

@interface GFSelectionsDirector : NSObject {
  NSArray *_selections;
}

@property (nonatomic, retain) NSArray *selections;

+ (id)sharedDirector;

- (NSArray*)selectionsForIndex:(NSInteger)index;

@end
