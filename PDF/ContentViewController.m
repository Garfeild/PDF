//
//  ContentViewController.m
//  PDF
//
//  Created by Anton Kolchunov on 19.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentViewController.h"


@implementation ContentViewController

- (id)initWithPDF:(CGPDFDocumentRef)pdfRef
{
  
  self = [super init];
  
  if ( self != nil )
  {
    _pdf = CGPDFDocumentRetain(pdfRef);
  }
  
  return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
  [super loadView];
  
  _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  [self.view addSubview:_tableView];
  
}

void ListDictionaryObjects (const char *key, CGPDFObjectRef object, void *info) {
  NSLog(@"key: %s", key);
  CGPDFObjectType type = CGPDFObjectGetType(object);
  switch (type) { 
    case kCGPDFObjectTypeDictionary: {
      CGPDFDictionaryRef objectDictionary;
      if (CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &objectDictionary)) {
        CGPDFDictionaryApplyFunction(objectDictionary, ListDictionaryObjects, NULL);
      }
    }
    case kCGPDFObjectTypeInteger: {
      CGPDFInteger objectInteger;
      if (CGPDFObjectGetValue(object, kCGPDFObjectTypeInteger, &objectInteger)) {
        NSLog(@"pdf integer value: %ld", (long int)objectInteger); 
      }
    }
      // test other object type cases here
      // cf. http://developer.apple.com/mac/library/documentation/GraphicsImaging/Reference/CGPDFObject/Reference/reference.html#//apple_ref/doc/uid/TP30001117-CH3g-SW1
  }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  [_tableView reloadData];
  
  self.contentSizeForViewInPopover = CGSizeMake(160.f, 320.f);
  
  CGPDFDictionaryRef pdfDocDictionary = CGPDFDocumentGetCatalog(_pdf);
  // loop through dictionary...
  CGPDFDictionaryApplyFunction(pdfDocDictionary, ListDictionaryObjects, NULL);

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identificator = @"ContentCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identificator];
  
  if ( cell == nil )
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identificator];
  }
  
  return cell;
}

@end
