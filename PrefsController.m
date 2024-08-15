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

#import "PrefsController.h"

static PrefsController *sharedController = nil;

@implementation PrefsController

+ (id)sharedPreferenceController
{
    if (!sharedController) {
        sharedController = [[PrefsController alloc] init];
    }

    return sharedController;
}

- (id)init
{
    if (self = [super initWithWindowNibName:@"Preferences"]) {
    }
    
    return self;
}

- (void)windowDidLoad
{
	[[self window] center];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)chooseClicked:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    NSString *path;
    int rc;
    
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];

    rc = [panel runModalForDirectory:nil file:nil types:nil];
    if (rc == NSOKButton) {
        path = [[panel filenames] objectAtIndex:0];
        id values = [prefsController values];
        [values setValue:path forKey:@"AppleGlotEnvPath"];
    }
}

@end
