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

#import "MainWindowController.h"

@implementation MainWindowController(ForPrinting)

- (IBAction)previewInHTML:(id)sender
{
	[self makeHTMLview];
}

// used for debbug
- (IBAction)previewClicked:(id)sender
{
	[self switchTab];
}

- (void)makeHTMLview
{
    // create HTML view
    HTMLloaded = NO;
    [[webView mainFrame] loadHTMLString:[[[self document] dataset] HTMLOutput] baseURL:nil];
    // wait until the loading complete
    while (HTMLloaded == NO) {
        [[NSRunLoop currentRunLoop] limitDateForMode:@"NSDefaultRunLoopMode"];
    }
}

- (void)makePrintview:(NSRect)printSize
{
    // fit to paper size
    [webView setFrame:printSize];
    // start to load HTML to WebView
    [self makeHTMLview];
}

- (void)webView:(WebView*)sender didFinishLoadForFrame:(WebFrame*)frame
{
    if (frame == [sender mainFrame]) {
        HTMLloaded = YES;
    }
}

- (NSView *)printView
{
    return [[[webView mainFrame] frameView] documentView];
}

- (BOOL)isHTMLloaded
{
    return HTMLloaded;
}

- (void)switchTab
{
    static int lastSelectedTab = 0; // Main

    if (lastSelectedTab == 0) {
        // update WebView
		[self makeHTMLview];
        // show Preview tab
        [tab selectTabViewItemAtIndex:1];
        lastSelectedTab = 1;
    } else {
        // show Main tab
        [tab selectTabViewItemAtIndex:0];
        lastSelectedTab = 0;
    }
}

@end
