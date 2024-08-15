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

#import <Foundation/Foundation.h>
#import <expat.h>

@interface ExpatWrapper : NSObject {
    XML_Parser parser;
}

/** The following methods should probably not be overriden **/
- (id)init:(NSStringEncoding *)encoding;
- (id)init:(NSStringEncoding *)encoding :(char)sep;

- (BOOL)parseWithData:(NSData *)data :(BOOL)isFinal;
- (BOOL)parseWithContentsOfFile:(NSString *)path;
// - (BOOL)parseWithContentsOfURL:(NSURL *)url;

/*** The following methods should be overriden by the caller **/

/* Start and and element notification methods */
- (void)startElement:(NSString *)name :(NSDictionary *)atts;
- (void)endElement:(NSString *)name;

/* Character data notification */
- (void)characters:(NSData *)data;

/* Processing instruction notification */
- (void)processingInstruction:(NSString *)target :(NSString *)data;

/* Comment notification */
- (void)comment:(NSString *)data;

/* CDATA section notification */
- (void)startCdata;
- (void)endCdata;

/* default handler */
- (void)defaultHandler:(NSData *)data;

/* is passed the Expat error code if an error occurs */
- (void)errorHandler:(int)errCode;

/** Parse position and error reporting methods **/

- (int)errorCode;
- (NSString *)errorString:(int)errorCode;
- (long)currentByteIndex;
- (int)currentLineNumber;
- (int)currentColumnNumber;
- (int)currentByteCount;

@end
