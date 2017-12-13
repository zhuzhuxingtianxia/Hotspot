//
//  ZJAlertView.h
//  Hotspot
//
//  Created by Jion on 2017/12/13.
//  Copyright © 2017年 Jion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJAlertView : UIView

+(instancetype)showAlertViewWithMessage:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitle:(NSString*)otherButtonTitle completion:(void (^)(NSInteger buttonIndex))completion;

@end
