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

#import "AppController.h"
#import "AppUtils.h"
#import "MainWindowController.h"
#import "PrefsController.h"
#import "TrunksMenuItemTag.h"
#import "AppleGlotController.h"

@interface AppController(Private)
- (BOOL)isLaunchedAppleGlot;
- (BOOL)preRunAppleGlot;
@end

@implementation AppController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)awakeFromNib
{
    isAppleGlotRunning = NO;

    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"]]];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appleGlotStartedNotified:) name:AppleGlotStartedNotification object:nil];
    [center addObserver:self selector:@selector(appleGlotFinishedNotified:) name:AppleGlotFinishedNotification object:nil];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)theApplication
{
    // avoid to show empty window
    return NO;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
    if ([AppUtils isTigerOrHigher] != YES) {
        NSRunAlertPanel(NSLocalizedString(@"Error", @""),
                        NSLocalizedString(@"Mac OS X 10.4 later required.", @""),
                        NSLocalizedString(@"OK", @""), nil, nil);
        [NSApp terminate:self];
    }
#endif
    if ([AppleGlotController isAppleGlotAvailable] != YES) {
        NSRunInformationalAlertPanel(NSLocalizedString(@"Warning", @""),
                                     NSLocalizedString(@"AppleGlot does not found.", @""),
                                     NSLocalizedString(@"OK", @""), nil, nil);
    }
}

- (IBAction)showPreferences:(id)sender
{
    [[PrefsController sharedPreferenceController] showWindow:self];
}

- (IBAction)openAppleGlotEnv:(id)sender
{
    BOOL result;
    NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleGlotEnvPath"];

    result = [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:path];
    if (result != YES) {
        NSRunAlertPanel(NSLocalizedString(@"Error", @""),
                        NSLocalizedString(@"Can't open AppleGlot Environment folder.", @""),
                        NSLocalizedString(@"OK", @""), nil, nil);
    }
}

- (IBAction)launchAppleGlot:(id)sender
{
    BOOL result;

    result = [[NSWorkspace sharedWorkspace] launchApplication:@"AppleGlot"];
    if (result != YES) {
        NSRunAlertPanel(NSLocalizedString(@"Error", @""),
                        NSLocalizedString(@"Can't launch AppleGlot.", @""),
                        NSLocalizedString(@"OK", @""), nil, nil);
    }
}

- (BOOL)preRunAppleGlot
{
    NSDocument *doc = [[[NSApp mainWindow] windowController] document];
    BOOL ret = YES;

    if (![doc isDocumentEdited]) {
        return YES;
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AutoSaveWhenRunAppleGlot"]) {
        [doc saveDocument:self];
        return YES;
    }

    NSAlert *alert = [NSAlert alertWithMessageText:
                                  [NSString stringWithFormat:NSLocalizedString(@"Do you want to save the document \"%@\" before run AppleGlot?", ""), [[[doc fileURL] path] lastPathComponent]]
                    defaultButton:NSLocalizedString(@"Save", "")
                  alternateButton:NSLocalizedString(@"Don't Save", "")
                      otherButton:NSLocalizedString(@"Cancel", "")
        informativeTextWithFormat:@"Your changes will be lost if you don't save them."];

    int clicked = [alert runModal];
    switch (clicked) {
    case NSAlertFirstButtonReturn:  // Save
        [doc saveDocument:self];
        ret = YES;
        break;
    case NSAlertSecondButtonReturn: // Don't Save
        ret = YES;
        break;
    case NSAlertThirdButtonReturn:  // Cancel
    default:
        ret = NO;
        break;
    }

    return ret;
}

- (IBAction)runInitialPass:(id)sender
{
    BOOL rc = [self preRunAppleGlot];
    if (!rc) return;

    MainWindowController *current = [[NSApp mainWindow] windowController];
    AppleGlotController *appleGlot = [AppleGlotController sharedInstance];
    [appleGlot runInitialPass:current];
}

- (IBAction)runIncrementalPass:(id)sender
{
    BOOL rc = [self preRunAppleGlot];
    if (!rc) return;

    MainWindowController *current = [[NSApp mainWindow] windowController];
    AppleGlotController *appleGlot = [AppleGlotController sharedInstance];
    [appleGlot runIncrementalPass:current];
}

- (IBAction)runFinalPass:(id)sender
{
    BOOL rc = [self preRunAppleGlot];
    if (!rc) return;

    MainWindowController *current = [[NSApp mainWindow] windowController];
    AppleGlotController *appleGlot = [AppleGlotController sharedInstance];
    [appleGlot runFinalPass:current];
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
    if ([anItem tag] == TRMenuLaunchAppleGlot || [anItem tag] == TRMenuRunInitialPass || [anItem tag] == TRMenuRunIncrementalPass || [anItem tag] == TRMenuRunFinalPass) {
        if (![AppleGlotController isAppleGlotAvailable])
            return NO;
    }

    if ([anItem tag] == TRMenuLaunchAppleGlot)
        return !([self isLaunchedAppleGlot]);

    if ([anItem tag] == TRMenuRunInitialPass || [anItem tag] == TRMenuRunIncrementalPass || [anItem tag] == TRMenuRunFinalPass) {
        if (isAppleGlotRunning)
            return NO;
        if ([[NSApp orderedDocuments] count] == 0)
            return NO;
    }

    return YES;
}

- (BOOL)isLaunchedAppleGlot
{
    NSArray *apps = [[NSWorkspace sharedWorkspace] launchedApplications];
    int i;

    if (apps == nil)
        return NO;

    for (i=0; i<[apps count]; i++) {
        NSDictionary *dict = [apps objectAtIndex:i];
        if ([[dict objectForKey:@"NSApplicationName"] isEqualToString:@"AppleGlot"] == YES) {
            return YES;
        }
    }
    
    return NO;
}

- (IBAction)showAppleGlotConsole:(id)sender
{
    [[AppleGlotController sharedInstance] showConsole];
}

- (void)appleGlotStartedNotified:(NSNotification *)notification
{
    isAppleGlotRunning = YES;
}

- (void)appleGlotFinishedNotified:(NSNotification *)notification
{
    isAppleGlotRunning = NO;
}

@end
