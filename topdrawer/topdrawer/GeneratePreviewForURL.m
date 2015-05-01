#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#include <Cocoa/Cocoa.h>
static NSString * const kPluginBundleId = @"com.collinproject.topdrawer";



OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    /*
    // To complete your generator please implement the function GeneratePreviewForURL in GeneratePreviewForURL.c
    NSString *top_content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url encoding:NSUTF8StringEncoding error:nil];
    
    //NSString *tURL = [[NSBundle bundleWithIdentifier:kPluginBundleId] pathForResource:@"topdrawer" ofType:@"top"];
    
    NSError *error;
    
    NSString *tURL = [[NSBundle bundleWithIdentifier:kPluginBundleId] pathForResource:@"topdrawer" ofType:@"top"];
    NSString *shellScript = [[NSBundle bundleWithIdentifier:kPluginBundleId] pathForResource:@"td2pdf" ofType:@"sh"];
    NSString *pdfFile = [[NSBundle bundleWithIdentifier:kPluginBundleId] pathForResource:@"topdrawer" ofType:@"pdf"];
    
    [top_content writeToFile:tURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    
    
    
    NSPipe *pipe = [NSPipe pipe];

    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/sh";
    task.standardOutput = pipe;

    [task setArguments:[NSArray arrayWithObjects:shellScript, nil]];
    [task launch];

    
    NSData *odata = [pipe.fileHandleForReading readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:odata encoding:NSUTF8StringEncoding];
    NSLog(@"%@",output);
    
    
    
    NSData *data = [NSData dataWithContentsOfFile:pdfFile];
    
    
    NSDictionary *properties = @{
        (__bridge NSString *)kQLPreviewPropertyMIMETypeKey : @"application/pdf"
    };

    
    QLPreviewRequestSetDataRepresentation(preview, (__bridge CFDataRef)data, kUTTypePDF, (__bridge CFDictionaryRef)properties);
     
     */
    NSError *error;
    NSString *top_content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url encoding:NSUTF8StringEncoding error:nil];
    NSString *tURL = [[NSBundle bundleWithIdentifier:kPluginBundleId] pathForResource:@"topdrawer" ofType:@"top"];
    NSString *shellScript = [[NSBundle bundleWithIdentifier:kPluginBundleId] pathForResource:@"td" ofType:@"py"];
    
    [top_content writeToFile:tURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSPipe *pipe = [NSPipe pipe];

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/python";
    task.standardOutput = pipe;
    
    [task setArguments:[NSArray arrayWithObjects:shellScript, nil]];
    [task launch];
    
    
    NSData *odata = [pipe.fileHandleForReading readDataToEndOfFile];
    //NSString *html = [[NSString alloc] initWithData:odata encoding:NSUTF8StringEncoding];
    
    
    NSDictionary *properties = @{ // properties for the HTML data
                                 (__bridge NSString *)kQLPreviewPropertyTextEncodingNameKey : @"UTF-8",
                                 (__bridge NSString *)kQLPreviewPropertyMIMETypeKey : @"text/html"
                                 };
    
    QLPreviewRequestSetDataRepresentation(preview, (__bridge CFDataRef)odata, kUTTypeHTML, (__bridge CFDictionaryRef)properties);

    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
