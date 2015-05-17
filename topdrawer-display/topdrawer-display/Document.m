//
//  Document.m
//  topdrawer-display
//
//  Created by Yannick Ulrich on 01/05/15.
//  Copyright (c) 2015 Yannick Ulrich. All rights reserved.
//

#import "Document.h"

#import <WebKit/WebKit.h>





static NSString * const kPluginBundleId = @"com.collinproject.topdrawer-display";


@interface Document ()

@end


@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	
	/*NSURL *url = [NSURL URLWithString:@"http://davehiren.blogspot.com"];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	[[[self webView] mainFrame] loadRequest:urlRequest];
	
	[[self webView] reload:self];*/
	[[[self webView] mainFrame] loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
	
	
	NSLog(@"File type is %@", typeName);
	myinputData = data;
	
	NSString *tURL = [[NSBundle bundleWithIdentifier:kPluginBundleId] pathForResource:@"topdrawer" ofType:@"top"];
	NSString *shellScript = [[NSBundle bundleWithIdentifier:kPluginBundleId] pathForResource:@"td" ofType:@"py"];
	
	[data writeToFile:tURL atomically:YES];
	//[top_content writeToFile:tURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
	
	NSPipe *pipe = [NSPipe pipe];
	
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/usr/bin/python";
	task.standardOutput = pipe;
	
	[task setArguments:[NSArray arrayWithObjects:shellScript, nil]];
	[task launch];
	
	
	NSData *odata = [pipe.fileHandleForReading readDataToEndOfFile];
	
	html = [[NSString alloc] initWithData:odata encoding:NSUTF8StringEncoding];
	
	//[[myWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]]];

	
	
	//[[wview mainFrame] loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
	//[wview.mainFrame loadData:odata MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
	
	[[[self webView] mainFrame] loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
	
	
    return YES;
}


-(IBAction)printDocument:(id)sender
{
	NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
	
	NSPrintOperation *printOperation = [[self webView].mainFrame.frameView printOperationWithPrintInfo:printInfo];
	
	[printOperation runOperation];


}


-(IBAction)performFindPanel:(id)sender
{
	[[self webView] performFindPanelAction:sender];
}

-(IBAction)revert:(id)sender
{
	NSURL *furl = [self fileURL];
	NSError *error;
	
	
	if (furl == nil)
	{
		NSLog(@"File not on disk");
		return;
	}
	
	NSData *d = [NSData dataWithContentsOfURL:furl];
	[self readFromData:d ofType:@".top" error:&error];
	//- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
	
}

-(IBAction)exportPDF:(id)sender
{
	NSLog(@"ETs");
	
	NSSavePanel * savePanel = [NSSavePanel savePanel];
	[savePanel setAllowedFileTypes:@[@"pdf"]];
	[savePanel setDirectoryURL:[[self fileURL] URLByDeletingLastPathComponent]];
	
	NSInteger tvarInt = [savePanel runModal];
	
	if(tvarInt == NSFileHandlingPanelOKButton){
		
	} else if(tvarInt == NSFileHandlingPanelCancelButton) {
		NSLog(@"doSaveAs we have a Cancel button");
		return;
	} else {
		NSLog(@"doSaveAs tvarInt not equal 1 or zero = %3ld",(long)tvarInt);
		return;
	} // end if
	
	
	
	 NSString *tURL = [[NSBundle bundleWithIdentifier:kPluginBundleId] pathForResource:@"topdrawer" ofType:@"top"];
	 NSString *shellScript = [[NSBundle bundleWithIdentifier:kPluginBundleId] pathForResource:@"td2pdf" ofType:@"py"];
	 
	 [myinputData writeToFile:tURL atomically:YES];
	 
	 
	 NSPipe *pipe = [NSPipe pipe];
	 
	 NSTask *task = [[NSTask alloc] init];
	 task.launchPath = @"/usr/bin/python";
	 task.standardOutput = pipe;
	 
	 [task setArguments:[NSArray arrayWithObjects:shellScript, nil]];
	 [task launch];
	 
	 
	 NSData *odata = [pipe.fileHandleForReading readDataToEndOfFile];
	 
	[odata writeToURL:[savePanel URL] atomically:YES];
	
}

@end
