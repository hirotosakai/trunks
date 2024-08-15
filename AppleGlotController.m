/*
 * Copyright (c) 2006 Hiroto Sakai
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

#import "AppleGlotController.h"

#define APPLEGLOT_PATH @"/Developer/Applications/AppleGlot/AppleGlot.app/Contents/Resources/appleglot"

// see appleglot -h
#define APPLEGLOT_CMD_INITIALPASS       @"populate"
#define APPLEGLOT_CMD_INCLEMENTALPASS   @"update"
#define APPLEGLOT_CMD_FINALPASS         @"finalize"

static AppleGlotController *gSharedInstance = nil;
static MainWindowController *gProcessingItem = nil;

@interface AppleGlotController (Private)
- (void)runAppleGlot:(NSString *)path command:(NSString *)command;
- (void)appendProcessingLog:(NSString *)log;
- (void)clearProcessingLog;
@end

@implementation AppleGlotController

+ (BOOL)isAppleGlotAvailable
{
    return [[NSFileManager defaultManager] isExecutableFileAtPath:APPLEGLOT_PATH];
}

+ (AppleGlotController *)sharedInstance
{
    if (!gSharedInstance) {
        gSharedInstance = [[AppleGlotController alloc] init];
    }
    return gSharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        [NSBundle loadNibNamed:@"AppleGlotConsole" owner:self];
        itemName = [[NSMutableString alloc] initWithString:NSLocalizedString(@"Ready", @"")];
        isAppleGlotRunning = NO;
        isPanelOpenedByUser = NO;
    }
    
    return self;
}

- (void)dealloc
{
    if (self == gSharedInstance) {
        [itemName release];
        gProcessingItem = nil;
        gSharedInstance = nil;
    }
    [super dealloc];
}

- (void)awakeFromNib
{
    [panel setFrameAutosaveName:@"AppleGlotConsoleWindow"];
    [statusLabel setStringValue:NSLocalizedString(@"Ready", @"")];
}

- (void)runInitialPass:(MainWindowController *)procItem
{
    gProcessingItem = procItem;

    NSString *path = [[[procItem document] fileURL] path];
    [self runAppleGlot:path command:APPLEGLOT_CMD_INITIALPASS];
}

- (void)runIncrementalPass:(MainWindowController *)procItem
{
    gProcessingItem = procItem;

    NSString *path = [[[procItem document] fileURL] path];
    [self runAppleGlot:path command:APPLEGLOT_CMD_INCLEMENTALPASS];
}

- (void)runFinalPass:(MainWindowController *)procItem
{
    gProcessingItem = procItem;

    NSString *path = [[[procItem document] fileURL] path];
    [self runAppleGlot:path command:APPLEGLOT_CMD_FINALPASS];
}

- (void)runAppleGlot:(NSString *)path command:(NSString *)command
{
    NSString *workDir;
    NSString *appName;
    NSArray *args;

    workDir = [[path stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    if ([workDir length] <= 1) // "/" or empty
        return;

    appName = [[path lastPathComponent] stringByDeletingPathExtension];
    args = [NSArray arrayWithObjects:APPLEGLOT_PATH, command, appName, nil];
    [itemName setString:[path lastPathComponent]];

    // allocate memory for and initialize a new TaskWrapper object
    if (jobController != nil)
        [jobController release];
    jobController = [[AMShellWrapper alloc] initWithController:self
                    inputPipe:nil outputPipe:nil errorPipe:nil
                    workingDirectory:workDir environment:nil
                    arguments:args];
    // kick off the process asynchronously
    [jobController startProcess];
}

#pragma AMShellWrapperController_protocol

- (void)appendOutput:(NSString *)output
{
    [self appendProcessingLog:output];
}

- (void)appendError:(NSString *)error
{
    [self appendProcessingLog:error];
}

- (void)processStarted:(id)sender
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:AppleGlotStartedNotification object:self];

    [self clearProcessingLog];
    [indicator startAnimation:self];
    [statusLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Processing %@...", @""), [itemName stringByDeletingPathExtension]]];

    isAppleGlotRunning = YES;
    session = [NSApp beginModalSessionForWindow:panel];
}

- (void)processFinished:(id)sender withTerminationStatus:(int)resultCode
{
    [NSApp endModalSession:session];
    isAppleGlotRunning = NO;

    if (resultCode != 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"An error occurred while processing %@.", ""), itemName]
                            defaultButton:NSLocalizedString(@"OK", "")
                          alternateButton:nil
                              otherButton:nil
                informativeTextWithFormat:NSLocalizedString(@"For more detail, see AppleGlot Console.", "")];
        [alert runModal];
    } else {
        if (!isPanelOpenedByUser)
            [panel close];
    }

    [indicator stopAnimation:self];
    [statusLabel setStringValue:NSLocalizedString(@"Ready", @"")];

    [gProcessingItem reloadDocument:self];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:AppleGlotFinishedNotification object:self];
}

- (void)appendProcessingLog:(NSString *)log
{
    NSMutableAttributedString *string;
    NSFont *font;

    string = [[[NSMutableAttributedString alloc] initWithString:log] autorelease];
    font = [NSFont userFixedPitchFontOfSize:10];

    [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [log length])];

    [[textview textStorage] appendAttributedString:string];
    [textview scrollRangeToVisible:NSMakeRange([[textview string] length], 0)];
}

- (void)clearProcessingLog
{
    NSMutableAttributedString *string;
    NSFont *font;

    string = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    font = [NSFont userFixedPitchFontOfSize:10];

    [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, 0)];

    [[textview textStorage] setAttributedString:string];
    [textview scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void)showConsole
{
    [panel makeKeyAndOrderFront:self];
    isPanelOpenedByUser = YES;
}

- (BOOL)windowShouldClose:(id)sender
{
    if (isAppleGlotRunning)
        return NO;

    isPanelOpenedByUser = NO;
    return YES;
}

@end
