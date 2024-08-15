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

#import "FindController.h"

static FindController *sharedController = nil;

@interface FindController(Private)
- (id)initWithWindowNib;
- (void)startToFind;
- (void)updateUIState:(BOOL)state;
@end

@implementation FindController

+ (id)sharedFindWindowController
{
    if (!sharedController) {
        sharedController = [[FindController allocWithZone:NULL] initWithWindowNib];
    }

    return sharedController;
}

- (id)initWithWindowNib
{
    self = [super initWithWindowNibName:@"FindPanel"];
    if (self) {
        [txtFind setDelegate:self];
        [txtFind setStringValue:@""];
        [self updateUIState:NO];
		goForward = YES;
    }

    return self;
}

- (void)windowDidLoad
{
	[self setWindowFrameAutosaveName:@"FindPanel"];
}

- (IBAction)nextClicked:(id)sender
{
	[self setGoForward:YES];
    [self startToFind];
}

- (IBAction)prevClicked:(id)sender
{
	[self setGoForward:NO];
    [self startToFind];
}

- (BOOL)goForward
{
	return goForward;
}

- (void)setGoForward:(BOOL)value
{
	goForward = value;
}

- (void)startToFind
{
    BOOL wrap, caseSensitive;

    if ([chkCase state] == NSOnState)
        caseSensitive = YES;
    else
        caseSensitive = NO;
        
    if ([chkWrap state] == NSOnState)
        wrap = YES;
    else
        wrap = NO;

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [txtFind stringValue], @"text",
        [NSNumber numberWithInt:0], @"index",
        [NSNumber numberWithBool:[self goForward]], @"goForward",
        [NSNumber numberWithBool:caseSensitive], @"caseSensitive",
        [NSNumber numberWithBool:wrap], @"wrap",
        [NSNumber numberWithInt:[[tglScope selectedCell] tag]], @"scope",
        nil];

	// throw Notification
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StartFinding" object:dict];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [self updateUIState:[self canStartToFind]];
}

- (void)updateUIState:(BOOL)state
{
    [btnNext setEnabled:state];
    [btnPrev setEnabled:state];
}

- (BOOL)canStartToFind
{
    if ([[txtFind stringValue] length] > 0)
        return YES;

    return NO;
}

@end
