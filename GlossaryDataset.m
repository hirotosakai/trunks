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

#import "GlossaryDataset.h"

@implementation GlossaryDataset

+ (id)datasetWithDataset:(GlossaryDataset *)data
{
    id me = [[[self alloc] init] autorelease];
    [me setProj:[data proj]];
    [me setBaseLoc:[data baseLoc]];
    [me setTranLoc:[data tranLoc]];
    [[me record] setArray:[data record]];
    return me;
}

- (id)init
{
    self = [super init];
    if (self) {
        record = [[NSMutableArray array] retain];
        proj = [[NSString alloc] initWithString:@""];
        baseLoc = [[NSString alloc] initWithString:@""];
        tranLoc = [[NSString alloc] initWithString:@""];
    }
    return self;
}

- (void)dealloc
{
    [proj release];
    [baseLoc release];
    [tranLoc release];
    [record release];
    [super dealloc];
}

- (int)numberOfLocalizableItems
{
    return [record count];
}

- (NSMutableArray *)record
{
    return record;
}

- (NSString *)proj
{
    return proj;
}

- (NSString *)baseLoc
{
    return baseLoc;
}

- (NSString *)tranLoc
{
    return tranLoc;
}

- (NSString *)noAtIndex:(int)index
{
    if ([record count] < index) return nil;

    return [[record objectAtIndex:index] objectForKey:@"no"];
}

- (NSString *)pathAtIndex:(int)index
{
    if ([record count] < index) return nil;

    return [[record objectAtIndex:index] objectForKey:@"path"];
}

- (NSString *)descAtIndex:(int)index
{
    if ([record count] < index) return nil;

    return [[record objectAtIndex:index] objectForKey:@"desc"];
}

- (NSString *)posAtIndex:(int)index
{
    if ([record count] < index) return nil;

    return [[record objectAtIndex:index] objectForKey:@"pos"];
}

- (NSString *)baseAtIndex:(int)index
{
    if ([record count] < index) return nil;

    return [[record objectAtIndex:index] objectForKey:@"base"];
}

- (NSString *)tranAtIndex:(int)index
{
    if ([record count] < index) return nil;

    return [[record objectAtIndex:index] objectForKey:@"tran"];
}

- (NSString *)originAtIndex:(int)index
{
    if ([record count] < index) return nil;

    return [[record objectAtIndex:index] objectForKey:@"origin"];
}

- (void)setProj:(NSString *)aProj
{
    id old = proj;
    proj = [aProj retain];
    [old release];
}

- (void)setBaseLoc:(NSString *)aBaseLoc
{
    id old = baseLoc;
    baseLoc = [aBaseLoc retain];
    [old release];
}

- (void)setTranLoc:(NSString *)aTranLoc
{
    id old = tranLoc;
    tranLoc = [aTranLoc retain];
    [old release];
}

- (void)addRecord:(NSString *)aPath desc:(NSString *)aDesc pos:(NSString *)aPos base:(NSString *)aBase tran:(NSString *)aTran origin:(NSString *)aOrigin
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%d",
                                    [self numberOfLocalizableItems] + 1], @"no",
                                    aPath, @"path",
                                    aDesc, @"desc",
                                    aPos, @"pos",
                                    aBase, @"base",
                                    aTran, @"tran",
                                    aOrigin, @"origin",
                                    nil];
    [record addObject:dict];
}

- (void)replaceTranAtIndex:(NSString *)value index:(int)index
{
    [[record objectAtIndex:index] setObject:value forKey:@"tran"];
}

@end
