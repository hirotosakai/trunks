/*
 * Copyright (c) 2005 Hiroto Sakai
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

@interface AppController(Private)
- (BOOL)isRunningAppleGlot;
@end

@implementation AppController

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)theApplication
{
    // avoid to show empty window
    return NO;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    if ([AppUtils isURLLoadingAvailable] != YES) {
        NSRunAlertPanel(NSLocalizedString(@"Error", @""),
                        NSLocalizedString(@"Mac OS X 10.2.7 later required.", @""),
                        NSLocalizedString(@"OK", @""), nil, nil);
        [NSApp terminate:self];
    }
    if ([AppUtils isWebKitAvailable] != YES) {
        NSRunAlertPanel(NSLocalizedString(@"Error", @""),
                        NSLocalizedString(@"WebKit is not available.", @""),
                        NSLocalizedString(@"OK", @""), nil, nil);
        [NSApp terminate:self];
    }
    if ([AppUtils isSystemEventsAvailable] != YES) {
        NSRunAlertPanel(NSLocalizedString(@"Error", @""),
                        NSLocalizedString(@"System Events v1.2 later is required.", @""),
                        NSLocalizedString(@"OK", @""), nil, nil);
        [NSApp terminate:self];
    }
}

- (IBAction)showPreferences:(id)sender
{
    [[PrefsController sharedPreferenceController] showWindow:self];
}

- (IBAction)openAppleGlotEnv:(id)sender
{
    BOOL result;

    result = [[NSWorkspace sharedWorkspace] selectFile:nil
        inFileViewerRootedAtPath:[TrunksPrefs appleGlotEnvPath]];
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

- (IBAction)runIncrementalPass:(id)sender
{
    NSString *path, *source;
    NSAppleScript *script;
    NSAppleEventDescriptor *result;
    NSDictionary *errorInfo;

    // prepare to run AppleScript
    path = [[[NSBundle mainBundle] resourcePath]
            stringByAppendingPathComponent:@"doAGIncrementalPass.applescript"];
    source = [NSString stringWithContentsOfFile:path];
    script = [[[NSAppleScript alloc] initWithSource:source] autorelease];

    // run script
    result = [script executeAndReturnError:&errorInfo];
    if (result == nil) {
        NSString *errorMessage = [NSString stringWithFormat:@"%@ (%d)",
                        [errorInfo objectForKey:NSAppleScriptErrorMessage],
                        [errorInfo objectForKey:NSAppleScriptErrorNumber]];
        NSRunAlertPanel([errorInfo objectForKey:NSAppleScriptErrorBriefMessage],
                        errorMessage, NSLocalizedString(@"OK", @""), nil, nil);
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
    if ([anItem tag] == TRMenuLaunchAppleGlot)
        return !([self isRunningAppleGlot]);

    return YES;
}

- (BOOL)isRunningAppleGlot
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

@end
