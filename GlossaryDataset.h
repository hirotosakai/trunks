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

#import <Foundation/Foundation.h>

@interface GlossaryDataset : NSObject {
    NSMutableArray *record;
    NSString *proj, *baseLoc, *tranLoc;
}

+ (id)datasetWithDataset:(GlossaryDataset *)data;
- (int)numberOfLocalizableItems;
- (NSMutableArray *)record;
- (NSString *)proj;
- (NSString *)baseLoc;
- (NSString *)tranLoc;
- (NSString *)noAtIndex:(int)index;
- (NSString *)pathAtIndex:(int)index;
- (NSString *)descAtIndex:(int)index;
- (NSString *)posAtIndex:(int)index;
- (NSString *)baseAtIndex:(int)index;
- (NSString *)tranAtIndex:(int)index;
- (NSString *)originAtIndex:(int)index;
- (void)setProj:(NSString *)aProj;
- (void)setBaseLoc:(NSString *)aBaseLoc;
- (void)setTranLoc:(NSString *)aTranLoc;
- (void)addRecord:(NSString *)aPath desc:(NSString *)aDesc pos:(NSString *)aPos base:(NSString *)aBase tran:(NSString *)aTran origin:(NSString *)aOrigin;
- (void)replaceTranAtIndex:(NSString *)value index:(int)index;

@end

// GlossaryDatasetOutput.m
@interface GlossaryDataset(Output)
- (NSString *)XMLOutput;
- (NSString *)HTMLOutput;
@end

// GlossaryDatasetSort.m
@interface GlossaryDataset(Sort)
- (void)sortRecord:(NSString *)key ascending:(BOOL)order;
@end

// GlossaryDatasetFind.m
@interface GlossaryDataset(Find)
- (int)findRecord:(NSDictionary *)dict;
@end
