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

@implementation MainWindowController(ForFinding)

- (IBAction)showFindWindow:(id)sender
{
    [[FindController sharedFindWindowController] showWindow:sender];
}

- (IBAction)findNext:(id)sender
{
    [[FindController sharedFindWindowController] nextClicked:sender];
}

- (IBAction)findPrev:(id)sender
{
    [[FindController sharedFindWindowController] prevClicked:sender];
}

// call when StartFinding Notification is throw
- (void)startFinding:(NSNotification *)notification
{
	NSMutableDictionary *dict;
    int resultRow;

	if ([self isEqualTo:[[NSApp mainWindow] windowController]] != YES)
		return;

	dict = [NSMutableDictionary dictionaryWithDictionary:[notification object]];
	[dict setObject:[NSNumber numberWithInt:[self findIndex]] forKey:@"index"];

    resultRow = [[[self document] dataset] findRecord:dict];
    if (resultRow >= 0) { // found
		[self selectAndScrollToVisible:resultRow];
    } else { // not found
        NSBeep();
    }
}

- (int)findIndex
{
    int index = [table selectedRow];

    if (index == -1) { // no row is selected
		return -1;
    }

	return index;
}

@end
