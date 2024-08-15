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

@interface MainWindowController (Private)
- (void)copyBaseToTran:(int)rowIndex;
- (BOOL)canCopyBaseToTran;
- (void)doReload;
- (void)setPopFilepathItems;
- (int)indexOfSelectedFilepath:(NSString *)title;
@end

@implementation MainWindowController

- (void)windowDidLoad
{
    if (![self document]) return;

    [table setDelegate:self];
	[table setAutosaveName:@"GlossaryView"];
	[table setAutosaveTableColumns:YES];
    [webView setFrameLoadDelegate:self];
	[self setWindowFrameAutosaveName:@"MainWindow"];

    // initialize GUI
    [self clearTextFields];
    [self setPopFilepathItems];
    [self setTitleOfColumn];
    [self clickColumnHeader:@"no" sortAscending:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(startFinding:)
			name:@"StartFinding"
		  object:nil];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
			name:@"StartFinding"
		  object:nil];
}

- (void)document:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)contextInfo
{
    // clear dirty flag
    [[self document] updateChangeCount:NSChangeCleared];
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
    if ([anItem tag] == TRMenuFindNext || [anItem tag] == TRMenuFindPrev)
        return [[FindController sharedFindWindowController] canStartToFind];
	if ([anItem tag] == TRMenuCopyOrigToTran)
		return [self canCopyBaseToTran];

    return YES;
}

- (IBAction)copyOrigToTran:(id)sender
{
	int rowIndex = [table selectedRow];

	if ([self canCopyBaseToTran] != YES)
		return;

	[[self document] copyBaseToTran:rowIndex];	// for model
	[self copyBaseToTran:rowIndex];				// for view
}

- (void)copyBaseToTran:(int)rowIndex
{
	// copy base value to tran
	[[[table tableColumnWithIdentifier:@"tran"] dataCellForRow:rowIndex]
		setStringValue:[[[self document] dataset] baseAtIndex:rowIndex]];
	// redraw updated cell
	[table deselectRow:rowIndex];
	[table selectRow:rowIndex byExtendingSelection:NO];
}

- (BOOL)canCopyBaseToTran
{
	if ([table selectedRow] == -1) { // no row is selected
		return NO;
	} else {
		return YES;
	}
}

- (IBAction)reloadDocument:(id)sender
{
    if ([[self document] isDocumentEdited] == YES) {
        // show warning sheet
        NSBeginCriticalAlertSheet(
            NSLocalizedString(@"Do you want to reload this document before saving ?", @""),
            NSLocalizedString(@"Reload", @""),
            NSLocalizedString(@"Cancel", @""),
            nil,
            [NSApp mainWindow],
            self,
            @selector(reloadAlertSheetDidEnd:returnCode:contextInfo:),
            nil,
            nil,
            NSLocalizedString(@"Your changes will be lost if you reload.", @""));
    } else {
        [self doReload];
    }
}

- (void)reloadAlertSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode != NSAlertDefaultReturn)
		return;

	[self doReload];
}

- (void)doReload
{
    MyDocument *doc = [self document];
	BOOL ret;

	[doc updateChangeCount:NSChangeCleared];

    ret = [doc readFromFile:[doc fileName] ofType:[doc fileType]];
	if (ret != YES) {
		[doc close];
		return;
	}

	// update GUI
	[self clearTextFields];
	[self resetTableView];
}

- (IBAction)popFilepathSelected:(id)sender
{
    int rowIndex;

    rowIndex = [self indexOfSelectedFilepath:[sender titleOfSelectedItem]];

    if (rowIndex < 0) { // not found
        [self clearTextFields];
		int selectedRow = [table selectedRow];
		if (selectedRow != -1) { // row is selected
			[table deselectRow:selectedRow];
		}
        if ([sender indexOfSelectedItem] > 0) {
            [table scrollRowToVisible:0];
        }
		return;
	}

	[self selectAndScrollToVisible:rowIndex];
}

- (int)indexOfSelectedFilepath:(NSString *)title
{
    GlossaryDataset *ds = [[self document] dataset];
    int i;

    for (i=0; i<[ds numberOfLocalizableItems]; i++) {
        if ([[ds pathAtIndex:i] isEqualToString:title] == YES) {
            return i;
        }
    }

    return -1;
}

- (void)setPopFilepathItems
{
    GlossaryDataset *ds = [[self document] dataset];
    NSString *prev, *cur;
    int i;

    prev = [NSString stringWithString:@""];

    [popFilepath removeAllItems];
    [popFilepath addItemWithTitle:@"-"]; // 1st item for not selected
    for (i=0; i<[ds numberOfLocalizableItems]; i++) {
        cur = [ds pathAtIndex:i];
        if ([cur isEqualToString:prev] == NO) {
            [popFilepath addItemWithTitle:cur];
        }
        prev = cur;
    }
}

- (void)clearTextFields
{
    [txtDescription setStringValue:@""];
    [txtPosition setStringValue:@""];
    [txtBase setStringValue:@""];
    [txtTran setStringValue:@""];
    [txtOrigin setStringValue:@""];
}

- (void)updateTextFields:(int)rowIndex
{
    GlossaryDataset *ds = [[self document] dataset];

    [txtDescription setStringValue:[ds descAtIndex:rowIndex]];
    [txtPosition setStringValue:[ds posAtIndex:rowIndex]];
    [txtBase setStringValue:[ds baseAtIndex:rowIndex]];
    [txtTran setStringValue:[ds tranAtIndex:rowIndex]];
    [txtOrigin setStringValue:[ds originAtIndex:rowIndex]];
}

@end
