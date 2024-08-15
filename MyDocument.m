/*
 * Copyright (c) 2005-2006 Hiroto Sakai
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MyDocument.h"

@interface MyDocument (Private)
- (NSString *)errorReason;
- (void)didParse:(GlossaryParser *)parser;
- (BOOL)parseWithData:(NSData *)data;
- (BOOL)parseWithContentsOfFile:(NSString *)path;
- (void)setLastModified:(NSString *)path;
@end

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
        errString = [[NSMutableString stringWithString:@""] retain];
        lastModified = [NSDate timeIntervalSinceReferenceDate];
        dataset = [[GlossaryDataset alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [errString release];
    [dataset release];

    [super dealloc];
}

- (GlossaryDataset *)dataset
{
    return dataset;
}

- (NSString *)errorReason
{
    return errString;
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
{
    if ([[NSFileManager defaultManager] isReadableFileAtPath:fileName] != YES) {
        NSRunAlertPanel(NSLocalizedString(@"Failed to open file.", @""),
                        NSLocalizedString(@"File does not exist or you may not have permission.", @""),
                        NSLocalizedString(@"OK", @""),
                        nil, nil);
        return NO;
    }

    if ([self parseWithContentsOfFile:fileName] != YES) {
        NSRunAlertPanel(NSLocalizedString(@"XML parsing error", @""),
                        [self errorReason],
                        NSLocalizedString(@"OK", @""),
                        nil, nil);
        return NO;
    }

    if ([[self dataset] numberOfLocalizableItems] == 0) {
        NSRunAlertPanel(NSLocalizedString(@"This document contains no data.", @""),
                        NSLocalizedString(@"There is no item that should be translated.", @""),
                        NSLocalizedString(@"OK", @""),
                        nil, nil);
        return NO;
    }

	[self setLastModified:fileName];

    return YES;
}

- (BOOL)writeToFile:(NSString *)fileName ofType:(NSString *)type
{
	BOOL ret;

	ret = [self writeToXMLFile:fileName];
	if (ret == YES) {
		[self setLastModified:fileName];
	}
	
	return ret;
}

- (void)makeWindowControllers
{
    MainWindowController *windowCtrl;

    windowCtrl = [[[MainWindowController alloc] initWithWindowNibName:@"MyDocument"] autorelease];
    [self addWindowController:windowCtrl];
}

- (void)printShowingPrintPanel:(BOOL)flag
{
    NSPrintInfo *printInfo;
    NSView *printView;

    // get printInfo and set properties
    printInfo = [self printInfo];
    [printInfo setHorizontalPagination:NSFitPagination];
    [printInfo setHorizontallyCentered:NO];
    [printInfo setVerticallyCentered:NO];

    // get mainWindow's controller
    MainWindowController *mainWindow = [[self windowControllers] objectAtIndex:0];
    // update webView of mainWindow
    [mainWindow makePrintview:[printInfo imageablePageBounds]];
    // wait for until to complete loading
    while ([mainWindow isHTMLloaded] == NO) {
        [[NSRunLoop currentRunLoop] limitDateForMode:@"NSDefaultRunLoopMode"];
    }

    // start to print
    printView = [mainWindow printView];
    [self runModalPrintOperation:[NSPrintOperation printOperationWithView:printView printInfo:printInfo]
                        delegate:self
                  didRunSelector:@selector(printOperationDidRun:success:contextInfo:)
                     contextInfo:NULL];
}

- (void)printOperationDidRun:(NSPrintOperation *)printOperation success:(BOOL)success contextInfo:(void *)info
{
    if (success) {
        [self setPrintInfo:[printOperation printInfo]];
    }
}

- (void)translateAllWithGlossary:(NSString *)path replace:(BOOL)replace from:(NSString *)from to:(NSString *)to
{
    int i, n;
    BOOL rc;
    GlossaryDataset *selfDs, *dictDs;
    GlossaryParser *dict = [[[GlossaryParser alloc] init:nil] autorelease];
	int updated = 0;

    rc = [dict parseWithContentsOfFile:path];
    if (rc != YES) {
        NSRunAlertPanel(NSLocalizedString(@"XML parsing error", @""),
                        [self errorReason],
                        NSLocalizedString(@"OK", @""),
                        nil, nil);
        return;
    }

    selfDs = [self dataset];
    dictDs = [dict dataset];
    for (i=0; i<[selfDs numberOfLocalizableItems]; i++) {
        for (n=0; n<[dictDs numberOfLocalizableItems]; n++) {
            NSMutableString *dictBase = [NSMutableString stringWithString:[dictDs baseAtIndex:n]];
            NSMutableString *dictTran = [NSMutableString stringWithString:[dictDs tranAtIndex:n]];
            // replace app name
            if (replace == YES && [from length] > 0 && [to length] > 0) {
                [dictBase replaceOccurrencesOfString:from withString:to options:NSLiteralSearch range:NSMakeRange(0, [dictBase length])];
                [dictTran replaceOccurrencesOfString:from withString:to options:NSLiteralSearch range:NSMakeRange(0, [dictTran length])];
            }
            if ([[selfDs baseAtIndex:i] isEqualToString:dictBase]) {
                [selfDs replaceTranAtIndex:dictTran index:i];
				updated++;
                break;
            }
        }
    }

	if (updated > 0) {
		[self updateChangeCount:NSChangeDone];
	}
}

- (void)translateAllWithWord:(NSString *)from to:(NSString *)to;
{
    int i;
    GlossaryDataset *ds = [self dataset];
	int updated = 0;

    for (i=0; i<[ds numberOfLocalizableItems]; i++) {
        if ([[ds baseAtIndex:i] isEqualToString:from]) {
            [ds replaceTranAtIndex:to index:i];
			updated++;
        }
    }

	if (updated > 0) {
		[self updateChangeCount:NSChangeDone];
	}
}

- (BOOL)parseWithData:(NSData *)data
{
    GlossaryParser *parser = [[[GlossaryParser alloc] init:nil] autorelease];
    BOOL rc;
    
    rc = [parser parseWithData:data :YES];
    if (rc != YES) {
        [errString setString:[parser errorString:[parser errorCode]]];
        return NO;
    }

	if ([[parser dataset] numberOfLocalizableItems] == 0) {
        [errString setString:NSLocalizedString(@"There is no item that should be translated.", @"")];
        return NO;
	}

    [self didParse:parser];

    return YES;
}

- (BOOL)parseWithContentsOfFile:(NSString *)aPath
{
    GlossaryParser *parser = [[[GlossaryParser alloc] init:nil] autorelease];
    BOOL rc;
    
    rc = [parser parseWithContentsOfFile:aPath];
    if (rc != YES) {
        [errString setString:[parser errorString:[parser errorCode]]];
        return NO;
    }

	if ([[parser dataset] numberOfLocalizableItems] == 0) {
        [errString setString:NSLocalizedString(@"There is no item that should be translated.", @"")];
        return NO;
	}

    [self didParse:parser];
	
    return YES;
}

- (void)didParse:(GlossaryParser *)parser
{
	[dataset release];
	dataset = [GlossaryDataset datasetWithDataset:[parser dataset]];
	[dataset retain];
}

- (BOOL)writeToXMLFile:(NSString *)oPath
{
    NSString *xmlOutput = [[self dataset] XMLOutput];

    // NSString uses defaultCStringEncoding, but we need UTF-8 string
    return [[NSData dataWithBytes:[xmlOutput UTF8String] length:strlen([xmlOutput UTF8String])]
                writeToFile:oPath atomically:YES];
}

- (BOOL)isModifiedByOthers
{
    NSTimeInterval mtime = [[[[NSFileManager defaultManager]
                                fileAttributesAtPath:[self fileName] traverseLink:YES]
                            objectForKey:NSFileModificationDate] timeIntervalSinceReferenceDate];

    if (mtime == lastModified) {
        return NO;
    } else {
        return YES;
    }
}

- (void)setLastModified:(NSString *)path
{
    lastModified = [[[[NSFileManager defaultManager]
                            fileAttributesAtPath:path traverseLink:YES]
                        objectForKey:NSFileModificationDate] timeIntervalSinceReferenceDate];
}

- (void)copyBaseToTran:(int)index
{
    GlossaryDataset *ds = [self dataset];

	[ds replaceTranAtIndex:[ds baseAtIndex:index] index:index];
	[self updateChangeCount:NSChangeDone];
}

@end
