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

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "MyDocument.h"
#import "TrunksPrefs.h"
#import "TrunksMenuItemTag.h"
#import "GlossaryDataset.h"
#import "FindController.h"

@interface MainWindowController : NSWindowController {
    // window
    IBOutlet id window;
    IBOutlet id tab;
    IBOutlet id table;
    IBOutlet id popFilepath;
    IBOutlet id txtDescription;
    IBOutlet id txtPosition;
    IBOutlet id txtBase;
    IBOutlet id txtTran;
    IBOutlet id txtOrigin;
    // TranslateAll panel
    IBOutlet id winTrAll;
    IBOutlet id txtTrAllFrom;
    IBOutlet id txtTrAllTo;
    IBOutlet id btnTrAllOK;
    // for preview
    IBOutlet id webView;
    BOOL HTMLloaded;
}

// Reload... menu
- (IBAction)reloadDocument:(id)sender;
// Use Original Value menu
- (IBAction)copyOrigToTran:(id)sender;

- (void)clearTextFields;
- (void)updateTextFields:(int)rowIndex;
@end

@interface MainWindowController (ForTableView)
- (void)clickColumnHeader:(NSString *)identifier sortAscending:(BOOL)sortAscending;
- (void)selectAndScrollToVisible:(int)rowIndex;
- (void)resetTableView;
- (void)setTitleOfColumn;
@end

@interface MainWindowController (ForFinding)
// Find... menu
- (IBAction)showFindWindow:(id)sender;
- (IBAction)findNext:(id)sender;
- (IBAction)findPrev:(id)sender;

- (int)findIndex;
@end

@interface MainWindowController (ForPrinting)
// Preview... menu
- (IBAction)previewInHTML:(id)sender;
// used for debbug
- (IBAction)previewClicked:(id)sender;

- (void)makePrintview:(NSRect)printSize;
- (void)makeHTMLview;
- (NSView *)printView;
- (BOOL)isHTMLloaded;
- (void)switchTab;
@end

@interface MainWindowController (ForTranslation)
// Localize All... menu
- (IBAction)translateAll:(id)sender;
// Action for TranslateAll sheet
- (IBAction)trAllOKClicked:(id)sender;
- (IBAction)trAllCancelClicked:(id)sender;
// Translate with glossary... menu
- (IBAction)translateWithGlossary:(id)sender;
@end
