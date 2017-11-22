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

#import "SIVideoPlayerViewController.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import "SIRequest.h"
#import "SIHTMLParser.h"
#import "Base64.h"

#import "MBProgressHUD+SIHUD.h"

@interface SIVideoPlayerViewController () <VLCMediaPlayerDelegate>

@property(nonatomic, strong) IBOutlet UILabel * tipLabel;
@property(nonatomic, strong) IBOutlet UILabel * leftLabel;
@property(nonatomic, strong) IBOutlet UILabel * rightLabel;
@property(nonatomic, strong) IBOutlet UISlider * progressView;

@property(nonatomic, strong) IBOutlet UIView * videoView;

@property(nonatomic, strong) VLCMediaPlayer * player;
@property(nonatomic, strong) VLCMedia * media;

@property(nonatomic, strong) NSString * videoURLString;
@property(nonatomic, strong) SIRequest * request;

@end

@implementation SIVideoPlayerViewController

-(void) dealloc
{
    [self.player removeObserver:self forKeyPath:@"state"];

    [self.player stop];
    self.player = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.progressView.enabled = NO;
        
    self.player = [[VLCMediaPlayer alloc] initWithOptions:nil];
    self.player.delegate = self;
    self.player.drawable = self.videoView;

    [self.player addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];

//    MBProgressHUD * hud = [MBProgressHUD showLoadingHud:@""];
//
//    NSLog(@"Loading : %@", self.embedURL);
//
//    self.request = [SIRequest requestWithType:SIRequestTypeGetVideoURL parameter:self.embedURL success:^(NSURLSessionDataTask *task, id responseObject) {
//
//        [hud hideAnimated:YES];
    
        //
       self.videoURLString = self.embedURL;//[SIHTMLParser parsingVideoURLWithObject:responseObject];
        
        if (self.videoURLString.length) {
            
            self.media = [VLCMedia mediaWithURL:[NSURL URLWithString:self.videoURLString]];
            [self.media addOptions:[NSMutableDictionary dictionary]];
            
            self.player.media = self.media;
            
            [self.player performSelectorOnMainThread:@selector(play) withObject:nil waitUntilDone:NO];
        }
        else{
            
            [MBProgressHUD showMessageHud:@"该视频暂时无法播放"];
        }
        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//
//        [hud hideAnimated:YES];
//        [MBProgressHUD showMessageHud:error.description];
//    }];
    
    self.title = self.titleString;
}

#pragma mark - VLCMediaPlayerDelegate

-(void) mediaPlayerStateChanged:(NSNotification *)aNotification
{
    if (self.media.url.relativeString.length == 0) {
        
        [self.player pause];
        return;
    }
}

-(void) mediaPlayerTimeChanged:(NSNotification *)aNotification;
{
    self.leftLabel.text = self.player.time.stringValue;
    self.rightLabel.text = self.player.media.length.stringValue;
    self.progressView.value = self.player.time.intValue;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    VLCMediaPlayerState state = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
    
    switch (state) {
        
        case VLCMediaPlayerStateStopped:
        {
            [self.player stop];
        }
        break;
        case VLCMediaPlayerStateOpening:
        {
            self.tipLabel.text = @"打开中...";
        }
        break;
        case VLCMediaPlayerStateBuffering:
        {
            if (self.media.url == nil || self.media.url.relativeString.length == 0) {
                return;
            }
            
            self.tipLabel.text = @"缓冲中...";
        }
        break;
        case VLCMediaPlayerStateEnded:
        {
            [self.player stop];
            [self.player play];
        }
        
        break;
        case VLCMediaPlayerStateError:
        {
            if (self.media.url.relativePath.length == 0) {
                return;
            }
            
            [MBProgressHUD showMessageHud:@"播放失败"];
        }
        break;
        case VLCMediaPlayerStatePlaying:
        {
            self.rightLabel.text = self.media.length.stringValue;
            
            self.progressView.maximumValue = self.media.length.intValue;
            self.progressView.minimumValue = 0;
            self.progressView.enabled = YES;
            self.tipLabel.hidden = YES;
        }
        break;
        case VLCMediaPlayerStatePaused:
        {
            
        }
        break;
        default:
        break;
    }
}

#pragma mark - Button Action

-(IBAction) dismiss
{
    [self.player removeObserver:self forKeyPath:@"state"];

    [self.player stop];
    self.player = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction) progressChangedByUser
{
    VLCTime * tmpTime = [VLCTime timeWithNumber:[NSNumber numberWithFloat:self.progressView.value]];
    
    [self.player setTime:tmpTime];
    
    //暂停时设置拖拽后的当前时间
    self.leftLabel.text = tmpTime.stringValue;
}


-(IBAction) copyAction:(id)sender
{
    if (self.videoURLString.length) {
        
        [[UIPasteboard generalPasteboard] setString:self.videoURLString];
        [MBProgressHUD showMessageHud:@"已复制到剪贴板"];
    }
}

-(IBAction) xunleiAction:(id)sender
{
    if (!self.videoURLString.length) {
        return;
    }
    
    NSString * xunleiURL = [NSString stringWithFormat:@"AA%@ZZ", self.videoURLString];
    
    if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"thunder://%@", [xunleiURL base64EncodedString]]]]){
        
        [MBProgressHUD showMessageHud:@"请先安装迅雷iOS版"];
    };
}

-(IBAction) refreshAction:(id)sender
{
    [self.player stop];
    [self.player play];
}

@end
