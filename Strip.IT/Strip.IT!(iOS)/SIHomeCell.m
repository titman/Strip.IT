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

#import "SIHomeCell.h"
#import "UIImageView+WebCache.h"

@implementation SIHomeCell

-(void) setVideoModel:(SIVideoModel *)videoModel
{
    _videoModel = videoModel;
    
    self.webImageView.image = nil;
    [self.webImageView sd_setImageWithURL:[NSURL URLWithString:videoModel.previewImageURLString] placeholderImage:nil];

    
    self.titleLabel.text      = videoModel.title;
    self.watchCountLabel.text = videoModel.watchTimes;
    self.durationLabel.text   = [NSString stringWithFormat:@"时长 %@", videoModel.duration];
    self.uploadTimeLabel.text = [NSString stringWithFormat:@"上传时间 %@", videoModel.uploadTime];
    
    self.percentLabel.text = [NSString stringWithFormat:@"%@喜欢", videoModel.rating];
    
    
    CGFloat progress = videoModel.rating.floatValue / 100.;
    
    self.progressConstraint.constant = self.progressBackView.frame.size.width * (1. - progress);
}

@end
