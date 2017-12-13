//
//  HotspotView.h
//  MaterialUnion
//
//  Created by Jion on 2017/1/19.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface HotspotModel : NSObject
@property(nonatomic,strong) UIImage  *titleImg;
//公告内容
@property(nonatomic,strong)NSString  *message;
//发布时间
@property(nonatomic,strong)NSString  *createdate;
@property(nonatomic,strong)NSString  *urlStr;

@end

@interface HotspotView : UIView

-(void)titleImage:(UIImage*)titleImage hotspot:(NSArray*)hotArray completion:(void (^)(HotspotModel *model))completion;

-(void)cancelAllTimer;

@end

