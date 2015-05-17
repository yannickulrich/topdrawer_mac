//
//  Document.h
//  topdrawer-display
//
//  Created by Yannick Ulrich on 01/05/15.
//  Copyright (c) 2015 Yannick Ulrich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface Document : NSDocument
{
	NSString * html;
	NSData * myinputData;
}

//@property (retain, nonatomic) IBOutlet WebView *wview;
@property (assign) IBOutlet WebView *webView;

-(IBAction)printDocument:(id)sender;
-(IBAction)revert:(id)sender;
-(IBAction)performFindPanel:(id)sender;
-(IBAction)exportPDF:(id)sender;

@end

