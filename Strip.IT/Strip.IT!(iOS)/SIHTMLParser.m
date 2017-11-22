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
#import "SIHTMLParser.h"
#import "TFHpple.h"
#import "SIVideoModel.h"
#import "SIRequest.h"

@implementation SIHTMLParser

+(NSMutableArray *) parsingWithObject:(id)object
{
    NSMutableArray * result = [NSMutableArray array];

    NSString * raw = [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
    
    raw = [raw stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@"\t" withString:@""];

    
    TFHpple * hpple = [[TFHpple alloc] initWithHTMLData:[raw dataUsingEncoding:NSUTF8StringEncoding]];
    
    //
    NSArray * kt_imgrcElements = [hpple searchWithXPathQuery:@"//a[@class = 'kt_imgrc']"];
    
    for (TFHppleElement * kt_imgrcElement in kt_imgrcElements) {
        
        SIVideoModel * model = [[SIVideoModel alloc] init];
        
        model.detailPageURLString = [kt_imgrcElement objectForKey:@"href"];
        model.title = [kt_imgrcElement objectForKey:@"title"];
        
        //
        NSArray * imgElements = [kt_imgrcElement searchWithXPathQuery:@"//img"];
        
        for (TFHppleElement * imgElement in imgElements) {

            model.previewImageURLString = [imgElement objectForKey:@"src"];
        }
        
        // all span
        NSArray * allspanElements = [kt_imgrcElement searchWithXPathQuery:@"//span"];

        BOOL vipOnly = NO;
        
        for (TFHppleElement * span in allspanElements) {
            
            if ([span.raw rangeOfString:@"vip.png"].length) {
                NSLog(@"跳过");
                vipOnly = YES;
            }
        }
        
        if (vipOnly) {
            continue;
        }

        //
        NSArray * viewsElements = [kt_imgrcElement searchWithXPathQuery:@"//span[@class = 'views']"];

        for (TFHppleElement * viewsElement in viewsElements) {

            model.watchTimes = viewsElement.text;
        }
        
        //
        NSArray * dateElements = [kt_imgrcElement searchWithXPathQuery:@"//span[@class = 'data']"];
        
        for (TFHppleElement * dateElement in dateElements) {
            
            model.uploadTime = dateElement.text;
        }
        
        //
        NSArray * durationElements = [kt_imgrcElement searchWithXPathQuery:@"//span[@class = 'duration']"];
        
        for (TFHppleElement * durationElement in durationElements) {
            
            model.duration = durationElement.text;
        }
        
        //
        NSArray * ratingElements = [kt_imgrcElement searchWithXPathQuery:@"//span[@class = 'rating']"];
        
        for (TFHppleElement * ratingElement in ratingElements) {
            
            model.rating = ratingElement.text;
        }
        
        [result addObject:model];
    }
    
    return result;
}

+(NSString *) parsingEmbedURLWithObject:(id)object host:(NSString *)host
{
    NSString * raw = [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
    
    raw = [raw stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@"\t" withString:@""];

    NSRange srange = [raw rangeOfString:@"video_url: '"];
    NSRange erange = [raw rangeOfString:@"', postfix"];

    if(srange.length && erange.length){
        NSString * string = [raw substringToIndex:erange.location];
        string = [string substringFromIndex:srange.location + srange.length];
        string = [NSString stringWithFormat:@"http://%@%@",host, string];
        return string;
    }
    
    return nil;
    
//    TFHpple * hpple = [[TFHpple alloc] initWithHTMLData:[raw dataUsingEncoding:NSUTF8StringEncoding]];
//
//    TFHppleElement * videoIDElement = [hpple peekAtSearchWithXPathQuery:@"//video[@id = 'kt_player_internal']"];
//
//    NSString * videoURL = [videoIDElement objectForKey:@"src"];
//
//    return [NSString stringWithFormat:@"%@embed/%@", MAIN_URL, videoID];
}

+(NSString *) parsingVideoURLWithObject:(id)object
{
    NSString * raw = [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
    
    raw = [raw stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@"'"  withString:@""];

    
    TFHpple * hpple = [[TFHpple alloc] initWithHTMLData:[raw dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSArray * scriptElements = [hpple searchWithXPathQuery:@"//script"];
    
    for (NSInteger i = 0; i < scriptElements.count; i++) {
        
        TFHppleElement * scriptElement = scriptElements[i];
        
        if (i == 2) {
         
            NSString * value = [scriptElement content];
            
            NSArray * array = [value componentsSeparatedByString:@"video_url:"];
            
            if (array.count >= 2) {
             
                NSString * url = array[1];
                
                NSString * urlValue = [url componentsSeparatedByString:@","][0];
                urlValue = [urlValue stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                return urlValue;
            }
        }
    }
    
    return nil;
}

@end
