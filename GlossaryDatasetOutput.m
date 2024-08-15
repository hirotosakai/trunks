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

#define CSS_FILENAME @"Printing.css"
#define MAX_PADDING_LENGTH 256

@interface GlossaryDataset (Private)
- (NSString *)stringByReplacingXMLEscapes:(NSString *)str;
- (NSString *)stringByReplacingHTMLEscapes:(NSString *)str;
- (NSString *)getPaddingStringForOrigin:(NSString *)str;
@end

@implementation GlossaryDataset(Output)

- (NSString *)stringByReplacingXMLEscapes:(NSString *)str
{
    NSMutableString *ret = [NSMutableString stringWithString:str];

    // escape XML special chars, & < > " ' -> &amp; &lt; &gt; &quot; &apos;
    [ret replaceOccurrencesOfString:@"&" withString:@"&amp;"
        options:NSLiteralSearch range:NSMakeRange(0, [ret length])];
    [ret replaceOccurrencesOfString:@"<" withString:@"&lt;"
        options:NSLiteralSearch range:NSMakeRange(0, [ret length])];
    [ret replaceOccurrencesOfString:@">" withString:@"&gt;"
        options:NSLiteralSearch range:NSMakeRange(0, [ret length])];
    [ret replaceOccurrencesOfString:@"'" withString:@"&apos;"
        options:NSLiteralSearch range:NSMakeRange(0, [ret length])];
    [ret replaceOccurrencesOfString:@"\"" withString:@"&quot;"
        options:NSLiteralSearch range:NSMakeRange(0, [ret length])];

    return ret;
}

- (NSString *)stringByReplacingHTMLEscapes:(NSString *)str
{
    if ([str length] == 0) {
        return @"";
    }

    return [self stringByReplacingXMLEscapes:str];
}

- (NSString *)getPaddingStringForOrigin:(NSString *)str
{
    char padding[MAX_PADDING_LENGTH];
    int len; // length of ' origin="..."'

    // initialize padding string
    memset(padding, ' ', MAX_PADDING_LENGTH);

    // make padding string
    len = [str length] + 10;
    if (len >= MAX_PADDING_LENGTH)
        len = 0;
    padding[len] = '\0';

    return [NSString stringWithCString:padding];
}

- (NSString *)XMLOutput
{
    GlossaryDataset *ds;
    NSMutableString *buf = [NSMutableString string];
    NSString *prevPath = @"";
    int i, n;

    // copy dataset and sort by "No"
    ds = [GlossaryDataset datasetWithDataset:self];
    [ds sortRecord:@"no" ascending:YES];

    // header
    [buf appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                       "<!-- Comment here. (1.0a10c2) -->\n<Proj>\n"];

    // Projname
    [buf appendString:[NSString stringWithFormat:@"<ProjName>%@</ProjName>\n\n",
                      [ds proj]]];

    // File...
    for (i=0; i<[ds numberOfLocalizableItems]; i++) {
        // File, Filepath
        if (i > 0 && [prevPath isEqualToString:[ds pathAtIndex:i]] == NO) {
            [buf appendString:@"</File>\n\n"];
        }
        if ([prevPath isEqualToString:[ds pathAtIndex:i]] == NO) {
            NSString *comPath = [NSString stringWithFormat:@"%@/../%@",
                                [ds proj],
                                [[ds pathAtIndex:i] lastPathComponent]];
            NSMutableString *comSpace = [NSMutableString stringWithString:@"<!--    "];
            for (n=0; n<[comPath length]; n++) {
                [comSpace appendString:@" "];
            }
            [comSpace appendString:@"    -->\n"];
            [buf appendString:comSpace];
            [buf appendString:[NSString stringWithFormat:
                @"<!--    %@    -->\n",
                comPath]];
            [buf appendString:comSpace];
            [buf appendString:[NSString stringWithFormat:
                @"<File>\n<Filepath>%@</Filepath>\n\n",
                [ds pathAtIndex:i]]];
        }

        // Textitem,Description,Position,TranslationSet,base,tran
        [buf appendString:[NSString stringWithFormat:@"<TextItem>\n"
            "<Description>%@</Description>\n"
            "<Position>%@</Position>\n"
            "<TranslationSet>\n\n"
            "\t<base loc=\"%@\"%@>%@</base>\n"
            "\t<tran loc=\"%@\" origin=\"%@\">%@</tran>\n\n"
            "</TranslationSet>\n</TextItem>\n\n",
            [self stringByReplacingHTMLEscapes:[ds descAtIndex:i]],
            [self stringByReplacingHTMLEscapes:[ds posAtIndex:i]],
            [self baseLoc], [self getPaddingStringForOrigin:[ds originAtIndex:i]],
            [self stringByReplacingHTMLEscapes:[ds baseAtIndex:i]],
            [self tranLoc], [ds originAtIndex:i],
            [self stringByReplacingHTMLEscapes:[ds tranAtIndex:i]]]];

        // remain current Filepath
        prevPath = [ds pathAtIndex:i];
    }

    // footer
    [buf appendString:@"</File>\n</Proj>\n"];

    return buf;
}

- (NSString *)HTMLOutput
{
    GlossaryDataset *ds;
    NSMutableString *buf = [NSMutableString string];
    NSString *prevPath = @"";
    NSString *cssPath, *cssString;
    int i;

    // copy dataset and sort by "No"
    ds = [GlossaryDataset datasetWithDataset:self];
    [ds sortRecord:@"no" ascending:YES];

    // header
    [buf appendString:[NSString stringWithFormat:
        @"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\""
         " \"http://www.w3.org/TR/html4/loose.dtd\">\n"
         "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
         "<header>\n"
         "<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\" />\n"
         "<meta http-equiv=\"Content-Style-Type\" content=\"text/css\" />\n"
         "<title>%@</title>\n</header>\n<body>\n", [ds proj]]];

    // css
    cssPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:CSS_FILENAME];
    cssString = [NSString stringWithContentsOfFile:cssPath];
    if (cssString != nil) {
        [buf appendString:[NSString stringWithFormat:
            @"<style type=\"text/css\"><!--\n"
            "%@\n"
            "--></style>\n", cssString]];
    }

    // Projname -> H1
    [buf appendString:[NSString stringWithFormat:
        @"<h1>Projname: %@</h1>\n", [ds proj]]];

    // Table
    for (i=0; i<[ds numberOfLocalizableItems]; i++) {
        // File, Filepath
        if (i > 0 && [prevPath isEqualToString:[ds pathAtIndex:i]] == NO) {
            [buf appendString:@"</table>\n\n"];
        }
        if ([prevPath isEqualToString:[ds pathAtIndex:i]] == NO) {
            [buf appendString:[NSString stringWithFormat:@"<h2>Filepath: %@</h2>\n",
                              [ds pathAtIndex:i]]];
            [buf appendString:[NSString stringWithFormat:@"<table>\n"
                "<tr><th class=\"desc\">Description</th class=\"pos\"><th>Position</th>"
                "<th class=\"base\">base</th><th class=\"tran\">tran</th></tr>\n"]];
        }

        // Textitem,Description,Position,TranslationSet,base,tran
        [buf appendString:[NSString stringWithFormat:
            @"<tr><td>%@</td><td>%@</td>"
             "<td>%@</td><td>%@</td></tr>\n",
            [self stringByReplacingXMLEscapes:[ds descAtIndex:i]],
            [self stringByReplacingXMLEscapes:[ds posAtIndex:i]],
            [self stringByReplacingXMLEscapes:[ds baseAtIndex:i]],
            [self stringByReplacingXMLEscapes:[ds tranAtIndex:i]]]];

        // remain current Filepath
        prevPath = [ds pathAtIndex:i];
    }

    // footer
    [buf appendString:@"</table>\n\n</body>\n</html>\n"];

    return buf;
}

@end

