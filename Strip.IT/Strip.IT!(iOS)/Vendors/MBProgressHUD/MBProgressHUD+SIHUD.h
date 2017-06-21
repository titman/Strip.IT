//
//  MBProgressHUD+SIHUD.h
//  Strip.IT!
//
//  Created by Guolicheng on 2017/5/12.
//  Copyright © 2017年 titman. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (SIHUD)

+(MBProgressHUD *) showMessageHud:(NSString *)message;
+(MBProgressHUD *) showLoadingHud:(NSString *)message;

@end
