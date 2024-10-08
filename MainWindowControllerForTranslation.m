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

#import "MainWindowController.h"

@implementation MainWindowController(ForTranslation)

- (IBAction)translateAll:(id)sender
{
    [NSApp beginSheet:winTrAll
            modalForWindow:[NSApp mainWindow]
            modalDelegate:self
            didEndSelector:@selector(translateAllSheetDidEnd:returnCode:contextInfo:)
            contextInfo:nil];
}

- (IBAction)trAllOKClicked:(id)sender
{
    [NSApp endSheet:winTrAll returnCode:NSOKButton];
}

- (IBAction)trAllCancelClicked:(id)sender
{
    [NSApp endSheet:winTrAll returnCode:NSCancelButton];
}

- (void)translateAllSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    MyDocument *doc = [self document];
    
    // close sheet
    [winTrAll orderOut:self];

    if (returnCode == NSOKButton) { // OK clicked
        [doc translateAllWithWord:[txtTrAllFrom stringValue] to:[txtTrAllTo stringValue]];
        [self clearTextFields];
        [self resetTableView];
    }
}

- (IBAction)translateWithGlossary:(id)sender
{
    // initialize controls in custom view
    [chkReplaceApp setState:NSOffState];
    [txtAppFrom setEditable:NO];
    [txtAppTo setEditable:NO];
    [txtAppFrom setStringValue:@""];
    [txtAppTo setStringValue:@""];

    // attach custom view and show file open dialog
    NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleGlotEnvPath"];
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setAccessoryView:replaceAppView];
    [op beginSheetForDirectory:path
            file:nil
            types:[NSArray arrayWithObjects:@"wg", @"ad", @"lg", nil]
            modalForWindow:[NSApp mainWindow]
            modalDelegate:self
            didEndSelector:@selector(translateWithGlossarySheetDidEnd:returnCode:contextInfo:)
            contextInfo:nil];
}

- (void)translateWithGlossarySheetDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    MyDocument *doc = [self document];
    
    if (returnCode == NSFileHandlingPanelOKButton) { // OK clicked
        if ([chkReplaceApp state] == NSOnState) {
            [doc translateAllWithGlossary:[sheet filename] replace:YES from:[txtAppFrom stringValue] to:[txtAppTo stringValue]];
        } else {
            [doc translateAllWithGlossary:[sheet filename] replace:NO from:nil to:nil];
        }
        [self clearTextFields];
        [self resetTableView];
    }
}

- (IBAction)replaceAppChanged:(id)sender
{
    if ([chkReplaceApp state] == NSOnState) {
        [txtAppFrom setEditable:YES];
        [txtAppTo setEditable:YES];
    } else {
        [txtAppFrom setEditable:NO];
        [txtAppTo setEditable:NO];
    }
}

@end
