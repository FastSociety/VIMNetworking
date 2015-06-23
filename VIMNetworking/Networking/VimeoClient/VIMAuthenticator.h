//
//  VIMAuthenticator.h
//  VIMNetworking
//
//  Created by Alfred Hanssen on 6/21/15.
//  Copyright (c) 2015 Vimeo. All rights reserved.
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
#import "VIMRequestOperationManager.h"

@protocol VIMRequestToken;

@class VIMAccount;

typedef void (^VIMAccountCompletionBlock)(VIMAccount *account, NSError *error);

extern NSString * const kVimeoAuthenticatorErrorDomain;

@interface VIMAuthenticator : VIMRequestOperationManager

@property (nonatomic, strong, readonly) NSString *clientKey;
@property (nonatomic, strong, readonly) NSString *clientSecret;
@property (nonatomic, strong, readonly) NSString *scope;

- (instancetype)initWithBaseURL:(NSURL *)url
                      clientKey:(NSString *)clientKey
                   clientSecret:(NSString *)clientSecret
                          scope:(NSString *)scope;

#pragma mark - URLs

- (NSURL *)codeGrantAuthorizationURL;

- (NSString *)codeGrantRedirectURI;

#pragma mark - Authentication

- (id<VIMRequestToken>)authenticateWithClientCredentialsGrant:(VIMAccountCompletionBlock)completionBlock;

- (id<VIMRequestToken>)authenticateWithCodeGrantResponseURL:(NSURL *)responseURL completionBlock:(VIMAccountCompletionBlock)completionBlock;

@end
