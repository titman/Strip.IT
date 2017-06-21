//
//  MBProgressHUD+SIHUD.m
//  Strip.IT!
//
//  Created by Guolicheng on 2017/5/12.
//  Copyright © 2017年 titman. All rights reserved.
//

#import "MBProgressHUD+SIHUD.h"

@implementation MBProgressHUD (SIHUD)

+(MBProgressHUD *) showMessageHud:(NSString *)message
{
    UIView * inView = [UIApplication sharedApplication].keyWindow;
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:inView animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabel.text = message;
    hud.mode = MBProgressHUDModeText;
    
    [hud hideAnimated:YES afterDelay:2];
    
    return hud;
}

+(MBProgressHUD *) showLoadingHud:(NSString *)message
{
    UIView * inView = [UIApplication sharedApplication].keyWindow;

    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:inView animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabel.text = message;
    hud.mode = MBProgressHUDModeIndeterminate;
    
    return hud;
}


@end
