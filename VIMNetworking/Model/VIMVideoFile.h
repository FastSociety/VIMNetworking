//
//  VIMVideoFile.h
//  VIMNetworking
//
//  Created by Kashif Mohammad on 4/13/13.
//  Copyright (c) 2014-2015 Vimeo (https://vimeo.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

#import <VIMObjectMapper/VIMModelObject.h>

@class VIMVideoLog;

extern NSString *const __nonnull VIMVideoFileQualityHLS;
extern NSString *const __nonnull VIMVideoFileQualityHD;
extern NSString *const __nonnull VIMVideoFileQualitySD;
extern NSString *const __nonnull VIMVideoFileQualityMobile;

@interface VIMVideoFile : VIMModelObject

@property (nonatomic, strong, nullable) NSDate *expirationDate;
@property (nonatomic, strong, nullable) NSNumber *width;
@property (nonatomic, strong, nullable) NSNumber *height;
@property (nonatomic, strong, nullable) NSNumber *size;
@property (nonatomic, copy, nullable) NSString *link;
@property (nonatomic, copy, nullable) NSString *quality;
@property (nonatomic, copy, nullable) NSString *type;
@property (nonatomic, strong, nullable) VIMVideoLog *log;

- (BOOL)isSupportedMimeType;
- (BOOL)isDownloadable;
- (BOOL)isStreamable;

// TODO: This property and the playbackURL method should live within the app, not within VIMNetworking [AH]

@property (nonatomic, strong, nullable) NSURL *localFileURL;

- (nullable NSURL *)playbackURL;

@end
