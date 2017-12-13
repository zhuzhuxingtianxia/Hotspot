//
//  ZJAlertView.m
//  Hotspot
//
//  Created by Jion on 2017/12/13.
//  Copyright © 2017年 Jion. All rights reserved.
//

#import "ZJAlertView.h"

#undef Alert_ScreenHeight

#undef Alert_ScreenWidth

#define Alert_ScreenHeight [[UIScreen mainScreen] bounds].size.height

#define Alert_ScreenWidth [[UIScreen mainScreen] bounds].size.width

inline static  CGSize f_ScreenSize(){
    
    return [[UIScreen mainScreen] bounds].size;
    
};

@interface ZJAlertView()
{
    CGRect grect;
}
@property (nonatomic, strong) UIControl *controlForDismiss;
@property(nonatomic, strong)UIButton *dismissBtn;

@property(nonatomic,strong)UIButton *confirmBtn;
@property(nonatomic,copy)void (^completion)(NSInteger buttonIndex);

@property(nonatomic,strong)UILabel  *messageLabel;
@property(nonatomic,copy)NSString *message;
@property(nonatomic,copy)NSString *cancelTitle;
@property(nonatomic,copy)NSString *comfirmTitle;

@end
@implementation ZJAlertView

+(instancetype)showAlertViewWithMessage:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitle:(NSString*)otherButtonTitle completion:(void (^)(NSInteger buttonIndex))completion{
    if (!(message||cancelButtonTitle||otherButtonTitle)) {
        return nil;
    }
    ZJAlertView *alert = [[ZJAlertView alloc] initWithFrame:CGRectMake(0, 0, 0.75*f_ScreenSize().width, 120)];
    alert.message = message;
    if ([cancelButtonTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length==0) {
        alert.cancelTitle = nil;
    }else{
        alert.cancelTitle = cancelButtonTitle;
    }
    if ([otherButtonTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        alert.comfirmTitle = nil;
    }else{
        alert.comfirmTitle = otherButtonTitle;
    }
    
    alert.completion = completion;
    
    [alert showInBlur:YES];
    return alert;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        grect = frame;
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.comfirmTitle && self.cancelTitle) {
        CGFloat wh = (grect.size.width-3*5)/2;
        self.dismissBtn.frame = CGRectMake(5, CGRectGetMaxY(self.messageLabel.frame)+20, wh, 40);
        self.confirmBtn.frame = CGRectMake(CGRectGetMaxX(self.dismissBtn.frame)+5, CGRectGetMaxY(self.messageLabel.frame)+20, wh, 40);
        
    }else if(self.comfirmTitle){
        CGFloat wh = grect.size.width-2*5;
        self.confirmBtn.frame = CGRectMake(5, CGRectGetMaxY(self.messageLabel.frame)+20, wh, 40);
    }else if(self.cancelTitle){
        CGFloat wh = grect.size.width-2*5;
        self.dismissBtn.frame = CGRectMake(5, CGRectGetMaxY(self.messageLabel.frame)+20, wh, 40);
    }else{
        
    }
    if (!(self.cancelTitle||self.comfirmTitle)) {
        grect.size.height = CGRectGetMaxY(self.messageLabel.frame)+20;
    }else{
        grect.size.height = self.cancelTitle?CGRectGetMaxY(self.dismissBtn.frame):CGRectGetMaxY(self.confirmBtn.frame);
    }
    
    self.bounds = grect;
}
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGFloat bottom = 40.0;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.backgroundColor set];
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 0.5);
    [[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0] set];
    
    CGContextMoveToPoint(context, 0, height-bottom);
    CGContextAddLineToPoint(context, width, height-bottom);
    CGContextDrawPath(context, kCGPathStroke);
    if (self.cancelTitle && self.comfirmTitle) {
        CGContextMoveToPoint(context, width/2, height-bottom);
        CGContextAddLineToPoint(context, width/2, height);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
}

#pragma mark --Action
-(void)actionDismissClick:(UIButton*)sender{
    if (self.completion) {
        self.completion(sender.tag);
    }
    [self animatedOut];
}
#pragma mark -- setter
-(void)setCancelTitle:(NSString *)cancelTitle{
    _cancelTitle = cancelTitle;
    if (_cancelTitle) {
        [self.dismissBtn setTitle:_cancelTitle forState:UIControlStateNormal];
        [self addSubview:self.dismissBtn];
    }
}

-(void)setComfirmTitle:(NSString *)comfirmTitle{
    _comfirmTitle = comfirmTitle;
    if (_comfirmTitle) {
        [self.confirmBtn setTitle:_comfirmTitle forState:UIControlStateNormal];
        [self addSubview:self.confirmBtn];
    }
}
-(void)setMessage:(NSString *)message{
    _message = message;
    if (_message) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.messageLabel.font,NSFontAttributeName, nil];
        //计算总高度
        CGSize  actualsize = CGSizeZero;
        actualsize =[_message  boundingRectWithSize:CGSizeMake(grect.size.width-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin  attributes:dic context:nil].size;
        
        self.messageLabel.text = _message;
        self.messageLabel.frame = CGRectMake(10, 20, grect.size.width-20, actualsize.height);
        [self addSubview:self.messageLabel];
    }
}

#pragma mark -- getter
-(UIButton*)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _dismissBtn.tag = 0;
        _dismissBtn.frame = CGRectMake(self.frame.size.width-30, -40, 40, 40);
        //[_dismissBtn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
        [_dismissBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_dismissBtn setTitleColor:[UIColor colorWithRed:149/255.0 green:149/255.0  blue:149/255.0  alpha:1.0] forState:UIControlStateHighlighted];
        _dismissBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_dismissBtn addTarget:self action:@selector(actionDismissClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
}
-(UIButton*)confirmBtn{
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _confirmBtn.tag = 1;
        [_confirmBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_confirmBtn addTarget:self action:@selector(actionDismissClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

-(UILabel*)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.font = [UIFont systemFontOfSize:15];
    }
    return _messageLabel;
}

#pragma mark -- 添加蒙版
-(void)showInBlur:(BOOL)blur
{
    if (nil == _controlForDismiss && blur)
    {
        _controlForDismiss = [[UIControl alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _controlForDismiss.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:.5];
        
        [_controlForDismiss addTarget:self action:@selector(touchForDismissSelf:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    UIWindow *keywindow = [[UIApplication sharedApplication]keyWindow];
    if (_controlForDismiss)
    {
        [keywindow addSubview:_controlForDismiss];
    }
    
    [keywindow addSubview:self];
    self.center = CGPointMake(keywindow.bounds.size.width/2.0f, keywindow.bounds.size.height/2.0);
    
    [self animatedIn];
    
    
}
#pragma mark - Animated Mthod
- (void)animatedIn
{
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(1.1, 1.1);
    [UIView animateWithDuration:0.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
}
- (void)touchForDismissSelf:(id)sender
{
    //if (!(self.cancelTitle||self.comfirmTitle)) {
    [self animatedOut];
    //}
    
}
- (void)animatedOut{
    
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 0.0;
        _controlForDismiss.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            if (_controlForDismiss)
            {
                [_controlForDismiss removeFromSuperview];
            }
            [self removeFromSuperview];
        }
    }];
}


@end


