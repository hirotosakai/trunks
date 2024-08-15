/*
 * Copyright (c) 2005 Hiroto Sakai
 * This code is based on expatobjc-1.0 written by Rafael R. Sevilla.
 *
 * Copyright (c) 2002 Rafael R. Sevilla
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

#import "ExpatWrapper.h"

@implementation ExpatWrapper

/* Wrapper functions that are used by Expat.  These are the "real"
   Expat handlers, and they receive the id of the object instance that
   is performing the parsing as their user data argument so they know
   where to send messages.  */
static void
start_elem_handler(void *ud, const XML_Char *name, const XML_Char **atts)
{
    id parserobj;
    int i = 0;
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];

    while (atts[i] != NULL) {
        [attr setObject:[NSString stringWithUTF8String:atts[i+1]]
                 forKey:[NSString stringWithUTF8String:atts[i]]];
        i+=2;
    }

    parserobj = (id)ud;
    [parserobj startElement:[NSString stringWithUTF8String:name] :attr];
}

static void
end_elem_handler(void *ud, const XML_Char *name)
{
    id parserobj;

    parserobj = (id)ud;
    [parserobj endElement:[NSString stringWithUTF8String:name]];
}

static void
char_data_handler(void *ud, const XML_Char *s, int len)
{
    id parserobj;
    NSData *dat = [NSData dataWithBytes:s length:len];

    parserobj = (id)ud;
    [parserobj characters:dat];
}

static void
proc_instr_handler(void *ud, const XML_Char *target, const XML_Char *data)
{
    id parserobj;
    NSString *tgt = [NSString stringWithUTF8String:target];
    NSString *dat = [NSString stringWithUTF8String:data];

    parserobj = (id)ud;
    [parserobj processingInstruction:tgt :dat];
}

static void
comment_handler(void *ud, const XML_Char *s)
{
    id parserobj;
    NSString *str = [NSString stringWithUTF8String:s];

    parserobj = (id)ud;
    [parserobj comment:str];
}

static void
start_cdata_section_handler(void *ud)
{
    id parserobj;

    parserobj = (id)ud;
    [parserobj startCdata];
}

static void
end_cdata_section_handler(void *ud)
{
    id parserobj;

    parserobj = (id)ud;
    [parserobj endCdata];
}

static void
default_handler(void *ud, const XML_Char *s, int len)
{
    id parserobj;
    NSData *dat = [NSData dataWithBytes:s length:len];

    parserobj = (id)ud;
    [parserobj defaultHandler:dat];
}

static void
set_handlers(XML_Parser parser)
{
    XML_SetStartElementHandler(parser, start_elem_handler);
    XML_SetEndElementHandler(parser, end_elem_handler);
    XML_SetCharacterDataHandler(parser, char_data_handler);
    XML_SetProcessingInstructionHandler(parser, proc_instr_handler);
    XML_SetCommentHandler(parser, comment_handler);
    XML_SetStartCdataSectionHandler(parser, start_cdata_section_handler);
    XML_SetEndCdataSectionHandler(parser, end_cdata_section_handler);
    XML_SetDefaultHandler(parser, default_handler);
}

/* These are the default handler methods for all elements.  They all
   do absolutely NOTHING.  To get the parser to do something you have
   to make a subclass that overrides these methods.  */
- (void)startElement:(NSString *)name:(NSDictionary *)attr
{
}

- (void)endElement:(NSString *)name
{
}

- (void)characters:(NSData *)data
{
}

- (void)processingInstruction:(NSString *)target:(NSString *)data
{
}

- (void)comment:(NSString *)data
{
}

- (void)startCdata
{
}

- (void)endCdata
{
}

- (void)defaultHandler:(NSData *)data
{
}

- (void)errorHandler:(int)errCode
{
    NSLog(@"XML_Error(%d) %s\n", errCode, XML_ErrorString(errCode));
}

- (int)errorCode
{
    return XML_GetErrorCode(parser);
}

- (NSString *)errorString:(int)errorCode
{
    return [NSString stringWithUTF8String:XML_ErrorString(errorCode)];
}

- (long)currentByteIndex
{
    return XML_GetCurrentByteIndex(parser);
}

- (int)currentLineNumber
{
    return XML_GetCurrentLineNumber(parser);
}

- (int)currentColumnNumber
{
    return XML_GetCurrentColumnNumber(parser);
}

- (int)currentByteCount
{
    return XML_GetCurrentByteCount(parser);
}

// Encoding is not supported
- (id)init:(NSStringEncoding *)encoding
{
    self = [super init];
    if (self) {
        parser = XML_ParserCreate(NULL);
        XML_SetUserData(parser, self);
        set_handlers(parser);
    }
    return self;
}

- (id)init:(NSStringEncoding *)encoding:(char)sep
{
    self = [super init];
    if (self) {
        parser = XML_ParserCreateNS(NULL, sep);
        XML_SetUserData(parser, self);
        set_handlers(parser);
    }
    return self;
}

- (void)dealloc
{
    XML_ParserFree(parser);
    [super dealloc];
}

- (BOOL)parseWithContentsOfFile:(NSString *)path
{
    int rc;
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    if (data == nil) {
        NSLog(@"Can't read file %@", path);
        return NO;
    }

    rc = XML_Parse(parser, (const char*)[data bytes], [data length], 0);
    if (rc != XML_STATUS_OK) {
        [self errorHandler:XML_GetErrorCode(parser)];
        return NO;
    }

    return YES;
}

- (BOOL)parseWithData:(NSData *)data :(BOOL)isFinal
{
    int rc;

    if (isFinal == YES)
        rc = XML_Parse(parser, (const char*)[data bytes], [data length], 0);
    else
        rc = XML_Parse(parser, (const char*)[data bytes], [data length], 1);

    if (rc != XML_STATUS_OK) {
        [self errorHandler:XML_GetErrorCode(parser)];
        return NO;
    }

    return YES;
}

@end
