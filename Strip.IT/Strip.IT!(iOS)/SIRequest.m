//
//
//      _|          _|_|_|
//      _|        _|
//      _|        _|
//      _|        _|
//      _|_|_|_|    _|_|_|
//
//
//  Copyright (c) 2014-2015, Licheng Guo. ( http://titm.me )
//  http://github.com/titman
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "SIRequest.h"
#import "AFNetworking.h"
#import <WebKit/WebKit.h>

@interface SIRequest() <WKNavigationDelegate>

@property(nonatomic, assign) SIRequestType type;
@property(nonatomic, copy) void(^successBlock) (NSURLSessionDataTask *task, id responseObject);
@property(nonatomic, copy) void(^failureBlock) (NSURLSessionDataTask *task, NSError *error);

//
@property(nonatomic, strong) WKWebView * webView;

@end

@implementation SIRequest

+(instancetype) requestWithType:(SIRequestType)type
                      parameter:(NSString *)parameter
                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
{
    SIRequest * request = [[SIRequest alloc] initWithType:type success:success failure:failure];
    request.parameter = parameter;
    
    [request performSelector:@selector(request) withObject:nil afterDelay:0];
    
    return request;
}

-(instancetype) initWithType:(SIRequestType)type
                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    if (self = [super init]) {
        
        // 如果你的浏览器能打开网站，手机里打不开的话，在这设置成SIRequestModeWebRequest
        self.requestMode = SIRequestModeNormalRequest;
        
        self.type = type;
        self.successBlock = success;
        self.failureBlock = failure;

        
        WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
        config.preferences = [[WKPreferences alloc] init];
        config.preferences.javaScriptEnabled = YES;
        config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        
        self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 1800, 1800) configuration:config];
        self.webView.navigationDelegate = self;
        
        [self.webView scrollView];
    }
    
    return self;
}

-(void) request
{
    NSString * url = nil;
    
    switch (self.type) {
        case SIRequestTypeHomepage:
            url = MAIN_URL;
            break;
        case SIRequestTypeDetailPage:
            url = [self.parameter hasPrefix:@"http"] ? self.parameter : [NSString stringWithFormat:@"%@%@", MAIN_URL, self.parameter];
            break;
        default:
            url = self.parameter;
    }
    
    if (self.requestMode == SIRequestModeNormalRequest) {
     
        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        manager.responseSerializer     = [AFHTTPResponseSerializer serializer];
        
        [manager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
            
            if (request) {
                return request;
            }
            
            return nil;
        }];
        
        [manager GET:url parameters:nil progress:nil success:self.successBlock failure:self.failureBlock];
    }
    else{
     
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

#pragma mark -

-(void) webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (self.failureBlock) {
        self.failureBlock(nil, error);
    }
    
    self.failureBlock = nil;
}

-(void) webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    ;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    __weak typeof(self) weakSelf = self;
    
    [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
        
        if (weakSelf.successBlock) {
            weakSelf.successBlock(nil, [value dataUsingEncoding:NSUTF8StringEncoding]);
        }
        
        weakSelf.successBlock = nil;
    }];
}

@end
