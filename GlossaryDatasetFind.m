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

@interface GlossaryDataset(Private)
- (BOOL)isMatchText:(NSDictionary *)data dict:(NSDictionary *)dict target:(NSArray *)target;
@end

@implementation GlossaryDataset(Find)

- (int)findRecord:(NSDictionary *)dict
{
    int result, i;
    NSArray *target;
    int startRow;
	BOOL canHit0 = NO;
	
	startRow = [[dict objectForKey:@"index"] intValue];
	if (startRow < 0) {
		startRow = 0;
		canHit0 = YES;
	}

    switch ([[dict objectForKey:@"scope"] intValue]) {
    case 1: // tran
        target = [NSArray arrayWithObjects:@"tran", nil];
        break;
    case 2: // base
        target = [NSArray arrayWithObjects:@"base", nil];
        break;
    default:
        target = [NSArray arrayWithObjects:@"desc",@"pos",@"base",@"tran",nil];
    }

    if ([[dict objectForKey:@"goForward"] boolValue] == YES) {
        for (i=startRow; i<[record count]; i++) {
            result = [self isMatchText:[record objectAtIndex:i] dict:dict target:target];
            if (result == YES && (i != startRow || canHit0 == YES)) {
                return i;
            }
        }
        if ([[dict objectForKey:@"wrap"] boolValue] == YES) {
            for (i=0; i<startRow; i++) {
                result = [self isMatchText:[record objectAtIndex:i] dict:dict target:target];
                if (result == YES) {
                    return i;
                }
            }
        }
    } else {
        for (i=startRow; i>=0; i--) {
            result = [self isMatchText:[record objectAtIndex:i] dict:dict target:target];
            if (result == YES && (i != startRow || (i == 0 && canHit0 == YES))) {
                return i;
            }
        }
        if ([[dict objectForKey:@"wrap"] boolValue] == YES) {
            for (i=[record count]-1; i>startRow; i--) {
                result = [self isMatchText:[record objectAtIndex:i] dict:dict target:target];
                if (result == YES) {
                    return i;
                }
            }
        }
    }

    return -1;
}

- (BOOL)isMatchText:(NSDictionary *)data dict:(NSDictionary *)dict target:(NSArray *)target;
{
    int i;
    unsigned mask;

    if ([[dict objectForKey:@"caseSensitive"] boolValue] == YES) {
        mask = NSLiteralSearch;
    } else {
        mask = NSCaseInsensitiveSearch;
    }

    for (i=0; i<[target count]; i++) {
        NSString *value = [data objectForKey:[target objectAtIndex:i]];
        NSRange result = [value rangeOfString:[dict objectForKey:@"text"] options:mask];
        if (result.location != NSNotFound && result.length != 0) {
            return YES;
        }
    }
    
    return NO;
}

@end
