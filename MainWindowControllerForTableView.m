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

@interface NSTableView (AvoidWarning)
+ (NSImage *)_defaultTableHeaderSortImage;
+ (NSImage *)_defaultTableHeaderReverseSortImage;
@end

@interface MainWindowController (Private)
- (NSString *)enteredTranValue:(id)anObject;
- (NSImage *)getSortImage:(BOOL)sortAscending;
@end

@implementation MainWindowController(ForTableView)

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    MyDocument *doc = [self document];

    if (!doc) return 0;

    return [[doc dataset] numberOfLocalizableItems];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    id identifier = [aTableColumn identifier];
    MyDocument *doc = [self document];

    if (!doc) return @"";
    
    if ([identifier isEqualToString:@"no"]) {
        return [[doc dataset] noAtIndex:rowIndex];
    } else if ([identifier isEqualToString:@"path"]) {
        return [[[doc dataset] pathAtIndex:rowIndex] lastPathComponent];
    } else if ([identifier isEqualToString:@"desc"]) {
        return [[doc dataset] descAtIndex:rowIndex];
    } else if ([identifier isEqualToString:@"pos"]) {
        return [[doc dataset] posAtIndex:rowIndex];
    } else if ([identifier isEqualToString:@"base"]) {
        return [[doc dataset] baseAtIndex:rowIndex];
    } else if ([identifier isEqualToString:@"tran"]) {
        return [[doc dataset] tranAtIndex:rowIndex];
    }

    // should not reach here
    return nil;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if ([[self document] isModifiedByOthers] == YES) {
        // show alert sheet
        NSBeginCriticalAlertSheet(
            NSLocalizedString(@"This file is modified by other application.", @""),
            NSLocalizedString(@"Reload", @""),
            nil,
            nil,
            [NSApp mainWindow],
            self,
            @selector(reloadAlertSheetDidEnd:returnCode:contextInfo:),
            nil,
            nil,
            NSLocalizedString(@"You need to reload document before continue to edit.", @""));
    }

    return YES;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    MyDocument *doc = [self document];

    // sync data and GUI value
    if ([[aTableColumn identifier] isEqualToString:@"tran"]) {
        [[doc dataset] replaceTranAtIndex:[self enteredTranValue:anObject] index:rowIndex];
        [doc updateChangeCount:NSChangeDone];
    }
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)aTableColumn
{
    id identifier = [aTableColumn identifier];
    static int lastSelectedColumn = 0;
    static BOOL sortAscending = YES;

    // if same column clicked, then reverse sort order
    if ([table columnWithIdentifier:identifier] == lastSelectedColumn) {
        if (sortAscending == YES) {
            sortAscending = NO;
        } else {
            sortAscending = YES;
        }
    } else {
        sortAscending = YES;
    }

    // remember index of selected column
    lastSelectedColumn = [table columnWithIdentifier:identifier];
    
    // sort tableview
    [[[self document] dataset] sortRecord:identifier ascending:sortAscending];    
    // redraw GUI
    [self clickColumnHeader:identifier sortAscending:sortAscending];
    [self resetTableView];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    int rowIndex = [table selectedRow];

    if (rowIndex == -1) { // no row is selected
        [self clearTextFields];
        [popFilepath selectItemAtIndex:0];
    } else {
        [self updateTextFields:rowIndex];
        [popFilepath selectItemWithTitle:[[[self document] dataset] pathAtIndex:rowIndex]];
    }
}

- (NSString *)enteredTranValue:(id)anObject
{
    NSString *entered = [NSString stringWithString:anObject];

    if (entered == nil || [entered length] == 0)
        return [NSString stringWithString:@""];

    return entered;
}

- (void)clickColumnHeader:(NSString *)identifier sortAscending:(BOOL)sortAscending
{
    NSTableColumn *col = [table tableColumnWithIdentifier:identifier];
    NSTableColumn *highlighted = [table highlightedTableColumn];
    
    if (highlighted != nil)
        [table setIndicatorImage:nil inTableColumn:highlighted];
    [table setHighlightedTableColumn:col];
    [table setIndicatorImage:[self getSortImage:sortAscending] inTableColumn:col];
}

- (NSImage *)getSortImage:(BOOL)sortAscending
{
    if (sortAscending == YES) {
        return [NSTableView _defaultTableHeaderSortImage];
    } else {
        return [NSTableView _defaultTableHeaderReverseSortImage];
    }
}

- (void)resetTableView
{
    int selectedRow = [table selectedRow];

    if (selectedRow != -1) { // row is selected
        [table deselectRow:selectedRow];
	}

    // scroll to top of table
    [table scrollRowToVisible:0];
    // redraw table
    [table reloadData];
}

- (void)selectAndScrollToVisible:(int)rowIndex
{
	[table selectRow:rowIndex byExtendingSelection:NO];
	[table scrollRowToVisible:rowIndex];
}

- (void)setTitleOfColumn
{
    GlossaryDataset *ds = [[self document] dataset];

    [[[table tableColumnWithIdentifier:@"base"] headerCell] setStringValue:
        [NSString stringWithFormat:@"%@ (%@)",
        NSLocalizedString(@"Original", @""), [ds baseLoc]]];
    [[[table tableColumnWithIdentifier:@"tran"] headerCell] setStringValue:
        [NSString stringWithFormat:@"%@ (%@)",
        NSLocalizedString(@"Translated", @""), [ds tranLoc]]];
}

@end
