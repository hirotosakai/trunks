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

static int _compareNo(int value1, int value2)
{
    if (value1 < value2)
        return NSOrderedAscending;
    else if (value1 > value2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

static int compareRecordForInt(id p1, id p2, void *context)
{
    NSDictionary *dict = context;
    NSString *key = [dict objectForKey:@"key"];
    BOOL ascending = [[dict objectForKey:@"order"] boolValue];
    int value1 = [[p1 objectForKey:key] intValue];
    int value2 = [[p2 objectForKey:key] intValue];

    if (ascending == YES)
        return _compareNo(value1, value2);
    else
        return _compareNo(value2, value1);
}

static int compareRecordForString(id p1, id p2, void *context)
{
    NSDictionary *dict = context;
    NSString *key = [dict objectForKey:@"key"];
    BOOL ascending = [[dict objectForKey:@"order"] boolValue];
    NSString *value1 = [p1 objectForKey:key];
    NSString *value2 = [p2 objectForKey:key];

    // if same, order by "No"
    if ([value1 compare:value2 options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        if (ascending == YES)
            return _compareNo([[p1 objectForKey:@"no"] intValue], [[p2 objectForKey:@"no"] intValue]);
        else
            return _compareNo([[p2 objectForKey:@"no"] intValue], [[p1 objectForKey:@"no"] intValue]);
    }

    if (ascending == YES)
        return [value1 compare:value2 options:NSCaseInsensitiveSearch];
    else
        return [value2 compare:value1 options:NSCaseInsensitiveSearch];
}

@implementation GlossaryDataset(Sort)

- (void)sortRecord:(NSString *)key ascending:(BOOL)order
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                            key, @"key",
                            [NSNumber numberWithBool:order], @"order",
                            nil];

    if ([key isEqualToString:@"no"]) {
        [record sortUsingFunction:compareRecordForInt context:dict];
    } else {
        [record sortUsingFunction:compareRecordForString context:dict];
    }
}

@end
