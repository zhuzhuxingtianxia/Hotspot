//
//  HotspotView.m
//  MaterialUnion
//
//  Created by Jion on 2017/1/19.
//  Copyright © 2017年 Youjuke. All rights reserved.
//

#import "HotspotView.h"
#import "objc/runtime.h"
@implementation HotspotModel

-(instancetype)initObjcectWithDict:(NSDictionary*)dict{
    self = [super init];
    if (self) {
        unsigned int propertyCount = 0;
        objc_property_t *propertys = class_copyPropertyList([self class], &propertyCount);
        for (int i = 0; i < propertyCount; i ++) {
            ///取出属性
            objc_property_t property = propertys[i];
            
            const char * propertyName = property_getName(property);
            NSString  *propertyString = [NSString stringWithUTF8String:propertyName];
            id propertyValue = [dict valueForKey:propertyString];
            
            [self setValue:propertyValue forKey:propertyString];
            
        }
    }
    
    return self;
}

@end
/********/

@interface HotspotView ()<CAAnimationDelegate>
@property(nonatomic,copy)void (^completionBlock)(HotspotModel *model);
@property(nonatomic,strong)NSArray *modelArray;
@property(nonatomic,assign)BOOL showLine;

@property(nonatomic,strong)UIImageView  *imageView;
@property(nonatomic,strong)UIView      *contentView;
@property (nonatomic,strong)UIButton   *contentBtn;
@property(nonatomic,strong)UILabel    *label;

@property(nonatomic,strong)CATransition *flipTransition;
@property(nonatomic,strong)HotspotModel  *callModel;

@property(nonatomic,strong)NSMutableDictionary *timerContainer;

@end

@implementation HotspotView

static CGFloat splitLine = 80.0;

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        [self addSubview:self.imageView];
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.contentBtn];
        [self.contentView addSubview:self.label];
    }
    
    return  self;
}
-(void)titleImage:(UIImage*)titleImage hotspot:(NSArray*)hotArray completion:(void (^)(HotspotModel *model))completion{
    if (titleImage) {
        self.showLine = YES;
        self.imageView.image = titleImage;
    }else{
        self.showLine = NO;
    }
    if (hotArray.count > 0) {
        id objc = hotArray[0];
        if ([objc isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:hotArray.count];
            for (NSDictionary *objc in hotArray) {
                HotspotModel *model = [[HotspotModel alloc] initObjcectWithDict:objc];
                [array addObject:model];
            }
            self.modelArray = [NSArray arrayWithArray:array];
            
        }else if ([objc isKindOfClass:[NSString class]]){
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:hotArray.count];
            for (NSString *string in hotArray) {
                HotspotModel *model = [HotspotModel new];
                model.message = string;
                [array addObject:model];
            }
            
            self.modelArray = [NSArray arrayWithArray:array];
        }
    }else{
        HotspotModel *model = [HotspotModel new];
        model.message = @"暂无公告消息";
       NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"MM-dd"];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        model.createdate = dateStr;
        self.modelArray = @[model];
    }
    
    
    self.completionBlock = completion;
    
}

-(void)setModelArray:(NSArray *)modelArray{
    _modelArray = modelArray;
    
    [self customTransformationAnimation];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (_showLine) {
        self.imageView.frame = CGRectMake(5, 5, splitLine - 10, self.frame.size.height - 10);
    }
    
    self.contentView.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame)+10, 0, self.bounds.size.width - CGRectGetMaxX(self.imageView.frame) - 10, self.bounds.size.height);
    
    self.label.frame = CGRectMake(self.label.superview.bounds.size.width - 50, 15, 40, 15);
    
    self.contentBtn.frame = CGRectMake(10, 5, CGRectGetMinX(self.label.frame) - 15, self.bounds.size.height - 10);
}

-(void)dealloc{
    //移除动画
    [self.contentView.layer removeAllAnimations];
    //取消定时器
    NSLog(@"取消定时器");
    [self cancelAllTimer];
    
}

//GCD定时器封装
-(void)scheduledDispatchTimerWithName:(NSString*)timerName timeInterval:(double)interval queue:(dispatch_queue_t)queue repeats:(BOOL)repeats action:(dispatch_block_t)action{
    
    if (timerName == nil) {
        return;
    }
    if (queue == nil) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    if (!self.timerContainer) {
        self.timerContainer = [NSMutableDictionary dictionary];
    }
    
    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_resume(timer);
        
        [self.timerContainer setValue:timer forKey:timerName];
    }
    
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
     __weak typeof(self) weakself = self;
    
    dispatch_source_set_event_handler(timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            action();
            if (!repeats) {
                [weakself cancelTimerWithName:timerName];
            }
        });
        
    });
    
}

-(void)cancelTimerWithName:(NSString*)timerName{
    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];
    if (!timer) {
        return;
    }
    [self.timerContainer removeObjectForKey:timerName];
    
    dispatch_source_cancel(timer);
    timer = nil;
}

-(void)cancelAllTimer{
    if (self.timerContainer.count > 0) {
        for (NSString *key in self.timerContainer.allKeys) {
            [self cancelTimerWithName:key];
        }
    }
}

-(void)customTransformationAnimation{
    __weak typeof(self) weakself = self;
   __block NSUInteger  interval = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (!self.timerContainer) {
        self.timerContainer = [NSMutableDictionary dictionary];
    }
    dispatch_source_t timer = [self.timerContainer objectForKey:@"timer"];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        [self.timerContainer setValue:timer forKey:@"timer"];
    }
    
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 5.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //取消定时器
            //dispatch_source_cancel(timer);
           
            NSInteger index = (interval++)%weakself.modelArray.count;
            if (index%2 == 1) {
                [weakself.contentBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }else{
              [weakself.contentBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            
            weakself.callModel = weakself.modelArray[index];
            [weakself.contentView.layer addAnimation:weakself.flipTransition forKey:@"AnimationKey"];
            
        });
        
    });
    
    dispatch_resume(timer);

}

-(void)btnAction:(UIButton*)sender{
    
    if (self.completionBlock) {
        self.completionBlock(self.callModel);
    }
}

#pragma mark -- CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim{
    if (self.callModel) {
        [self.contentBtn setTitle:self.callModel.message forState:UIControlStateNormal];
        if (self.callModel.createdate.length>=10) {
            NSString *string = [self.callModel.createdate substringWithRange:NSMakeRange(5, 5)];
            self.label.text = string;
        }else{
            self.label.text = self.callModel.createdate;
        }
        
        if (self.label.text.length >0) {
            self.label.hidden = NO;
        }else{
           self.label.hidden = YES;
        }
        
    }
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    //防止循环引用
    _flipTransition.delegate = nil;
}

#pragma mark -- getter

-(CATransition*)flipTransition{
    if (!_flipTransition) {
        _flipTransition = [CATransition animation];
        _flipTransition.delegate = self;
        _flipTransition.duration = 0.5f ;
        _flipTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        _flipTransition.fillMode = kCAFillModeForwards;
        _flipTransition.removedOnCompletion = YES;
        _flipTransition.type = @"push";
        _flipTransition.subtype = @"fromTop";
    }
    return _flipTransition;
}

-(UIImageView*)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    return _imageView;
}
-(UIView*)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

-(UIButton*)contentBtn{
    if (!_contentBtn) {
        _contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contentBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        _contentBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _contentBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _contentBtn.titleLabel.numberOfLines = 2;
        [_contentBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _contentBtn;
}

-(UILabel*)label{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont boldSystemFontOfSize:11];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor colorWithRed:226/255.0 green:226/255.0 blue:229/255.0 alpha:1.0];
        _label.layer.cornerRadius = 2.0;
        _label.layer.masksToBounds = YES;
    }
    return _label;
}

-(void)drawRect:(CGRect)rect{
    
    // Drawing code
    if (!self.showLine) {
        return;
    }
    CGFloat height = rect.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.backgroundColor set];
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 1);
    [[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0] set];
    
    CGContextMoveToPoint(context, splitLine, 10);
    CGContextAddLineToPoint(context, splitLine, height-10);
    CGContextDrawPath(context, kCGPathStroke);
}

@end
