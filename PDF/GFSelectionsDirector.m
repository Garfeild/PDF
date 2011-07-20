//
//  GFSelectionsDirector.m
//  PDF
//
//  Created by Anton Kolchunov on 21.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GFSelectionsDirector.h"

static GFSelectionsDirector *sharedDirector = nil;

@implementation GFSelectionsDirector

@synthesize selections = _selections;

+ (id)sharedDirector {
  @synchronized(self) {
    if(sharedDirector == nil)
      sharedDirector = [[super allocWithZone:NULL] init];
  }
  return sharedDirector;
}

+ (id)allocWithZone:(NSZone *)zone {
  return [[self sharedDirector] retain];
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (id)retain {
  return self;
}

- (unsigned)retainCount {
  return UINT_MAX; //denotes an object that cannot be released
}

- (void)release {
  // never release
}

- (id)autorelease {
  return self;
}

- (id)init {
	self = [super init];
	
  if ( self != nil ) {
    
	}
  
	return self;
}
- (void)dealloc {
  // Should never be called, but just here for clarity really.
  [super dealloc];
}

- (void)setSelections:(NSArray *)selections
{
  [_selections release];
  _selections = selections;
  [_selections retain];
  NSLog(@"Settings %d", [_selections count]);
}

- (NSArray*)selectionsForIndex:(NSInteger)index
{
  NSIndexSet *indexes = [_selections indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
    NSLog(@"%@", [(NSDictionary*)obj allKeys] );
    return [[(NSDictionary*)obj objectForKey:@"Page Number"] isEqualToNumber:[NSNumber numberWithInt:index+1]];
  }];
  NSLog(@"Lets check");
  if ( [indexes count] != 0 )
  {
    NSLog(@"We have selections!");
    return [[_selections objectAtIndex:[indexes firstIndex]] objectForKey:@"Selections"];
  }

  return nil;
}

@end
