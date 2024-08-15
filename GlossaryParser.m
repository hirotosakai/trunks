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

#import "GlossaryParser.h"

@implementation GlossaryParser

- (id)init:(NSStringEncoding *)encoding
{
    self = [super init:encoding];
    if (self) {
        lastResult = 0;
        xPath = [[NSString stringWithCString:"/"] retain];
        projCdata = [[NSMutableData dataWithLength:0] retain];
        pathCdata = [[NSMutableData dataWithLength:0] retain];
        descCdata = [[NSMutableData dataWithLength:0] retain];
        posCdata = [[NSMutableData dataWithLength:0] retain];
        baseCdata = [[NSMutableData dataWithLength:0] retain];
        tranCdata = [[NSMutableData dataWithLength:0] retain];
        proj = [[NSMutableString stringWithString:@""] retain];
        baseLoc = [[NSMutableString stringWithString:@""] retain];
        tranLoc = [[NSMutableString stringWithString:@""] retain];
        tranOrigin = [[NSMutableString stringWithString:@""] retain];
        dataset = [[GlossaryDataset alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [projCdata release];
    [pathCdata release];
    [descCdata release];
    [posCdata release];
    [baseCdata release];
    [tranCdata release];
    [proj release];
    [baseLoc release];
    [tranLoc release];
    [tranOrigin release];
    [dataset release];

    [super dealloc];
}

- (GlossaryDataset *)dataset
{
    return dataset;
}

- (void)startElement:(NSString *)name:(NSDictionary *)attr
{
    xPath = [NSString stringWithString:[xPath stringByAppendingPathComponent:name]];
    depth++;

    if ([xPath isEqualToString:@"/Proj/ProjName"] == YES) {
        [projCdata setLength:0];
    }
    else if ([xPath isEqualToString:@"/Proj/File/Filepath"] == YES) {
        [pathCdata setLength:0];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/Description"] == YES) {
        [descCdata setLength:0];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/Position"] == YES) {
        [posCdata setLength:0];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/TranslationSet/base"] == YES) {
        [baseCdata setLength:0];
        [baseLoc setString:[attr objectForKey:@"loc"]];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/TranslationSet/tran"] == YES) {
        [tranCdata setLength:0];
        [tranLoc setString:[attr objectForKey:@"loc"]];
        [tranOrigin setString:[attr objectForKey:@"origin"]];
    }
}

- (void)endElement:(NSString *)name
{
    // terminate characters buffer
    if ([xPath isEqualToString:@"/Proj/ProjName"] == YES) {
        [projCdata appendBytes:"\0" length:1];
    }
    else if ([xPath isEqualToString:@"/Proj/File/Filepath"] == YES) {
        [pathCdata appendBytes:"\0" length:1];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/Description"] == YES) {
        [descCdata appendBytes:"\0" length:1];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/Position"] == YES) {
        [posCdata appendBytes:"\0" length:1];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/TranslationSet/base"] == YES) {
        [baseCdata appendBytes:"\0" length:1];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/TranslationSet/tran"] == YES) {
        [tranCdata appendBytes:"\0" length:1];
    }

    // add item to dataset
    if ([xPath isEqualToString:@"/Proj/File/TextItem/TranslationSet"] == YES) {
        [dataset addRecord:[NSString stringWithUTF8String:[pathCdata bytes]]
                        desc:[NSString stringWithUTF8String:[descCdata bytes]]
                        pos:[NSString stringWithUTF8String:[posCdata bytes]]
                        base:[NSString stringWithUTF8String:[baseCdata bytes]]
                        tran:[NSString stringWithUTF8String:[tranCdata bytes]]
                        origin:[NSString stringWithString:tranOrigin]];
    }

    depth--;
    xPath = [NSString stringWithString:[xPath stringByDeletingLastPathComponent]];
  
    // finally
    if (depth == 0) {
        if ([dataset numberOfLocalizableItems] > 0) {
            [dataset setProj:[NSString stringWithUTF8String:[projCdata bytes]]];
            [dataset setBaseLoc:baseLoc];
            [dataset setTranLoc:tranLoc];
        }
    }
}

- (void)characters:(NSData *)dat
{
    if ([dat length] == 0) return;

    if ([xPath isEqualToString:@"/Proj/ProjName"] == YES) {
        [projCdata appendData:dat];
    }
    else if ([xPath isEqualToString:@"/Proj/File/Filepath"] == YES) {
        [pathCdata appendData:dat];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/Description"] == YES) {
        [descCdata appendData:dat];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/Position"] == YES) {
        [posCdata appendData:dat];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/TranslationSet/base"] == YES) {
        [baseCdata appendData:dat];
    }
    else if ([xPath isEqualToString:@"/Proj/File/TextItem/TranslationSet/tran"] == YES) {
        [tranCdata appendData:dat];
    }
}

- (void)errorHandler:(int)errCode
{
    lastResult = errCode;
    NSLog(@"ExpatErrorHandler(%d) %@", errCode, [self errorString:errCode]);
}

@end
