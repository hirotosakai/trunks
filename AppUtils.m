/*
 * Copyright (c) 2005-2006 Hiroto Sakai
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

#import "AppUtils.h"

@implementation AppUtils

+ (BOOL)isURLLoadingAvailable
{
    return (NSFoundationVersionNumber >= 462.6);
}

+ (BOOL)isWebKitAvailable
{
    static BOOL _webkitAvailable = NO;
    static BOOL _initialized = NO;

    if (_initialized)
        return _webkitAvailable;

    NSBundle* webKitBundle;
    webKitBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/WebKit.framework"];
    if (webKitBundle) {
        _webkitAvailable = [webKitBundle load];
    }
    _initialized = YES;

    return _webkitAvailable;
}

+ (BOOL)isSystemEventsAvailable
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/System Events.app/Contents/Info.plist"];

    if (!dict)
        return NO;

    return ([[dict objectForKey:@"CFBundleVersion"] floatValue] >= 1.2);
}

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_4
+ (BOOL)isTigerOrHigher
{
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_3_5) {
        return YES;
    }
    return NO;
}
#endif

@end
