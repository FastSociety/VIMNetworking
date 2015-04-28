//
//  UploadFileTask.h
//  Pegasus
//
//  Created by Alfred Hanssen on 2/27/15.
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

#import "VIMNetworkTask.h"

@interface VIMUploadFileTask : VIMNetworkTask

@property (nonatomic, copy, readwrite) NSString *httpMethod;
@property (nonatomic, copy, readwrite) NSString *contentType;
@property (nonatomic, copy, readwrite) NSString *source;
@property (nonatomic, copy, readwrite) NSString *destination;
@property (nonatomic, copy, readwrite) NSString *md5Sum;


// Output, changed to readwrite for child class setting
@property (nonatomic, strong, readwrite) NSProgress *uploadProgress;

@property (nonatomic, assign) BOOL success;

- (instancetype)initWithSource:(NSString *)source destination:(NSString *)destination;

@end
