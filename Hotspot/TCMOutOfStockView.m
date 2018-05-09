//
//  TCMOutOfStockView.m
//  Buyer
//
//  Created by ZZJ on 2018/5/9.
//  Copyright © 2018年 Taocaimall Inc. All rights reserved.
//

#import "TCMOutOfStockView.h"

@interface TCMOutOfStockView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (strong, nonatomic) UIView *view;

@property (weak, nonatomic) IBOutlet UIButton *showBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic,strong)NSMutableArray *dataSoure;
@end
@implementation TCMOutOfStockView

/*
+(instancetype)shareOutOfStockView{
    TCMOutOfStockView *view = [[NSBundle mainBundle] loadNibNamed:@"TCMOutOfStockView" owner:self options:nil].lastObject;
    
    return view;
}
*/

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
    [self addSubview:self.view];
    }
    return self;
}

- (UIView *)view{
    if (!_view) {
        _view = [[NSBundle mainBundle] loadNibNamed:@"TCMOutOfStockView" owner:self options:nil].lastObject;
    }
    return _view;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.view.frame = self.bounds;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor yellowColor];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    _dataSoure = [NSMutableArray array];
    [_dataSoure addObject:@"电话与我联系"];
    [_dataSoure addObject:@"继续配送，缺货商品退款"];
    
    if (_dataSoure.count > 0) {
        [_pickerView selectRow:0 inComponent:0 animated:NO];
    }
    
}

#pragma mark --UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (_dataSoure.count > 0) {
        return 1;
    }else{
        return 0;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _dataSoure.count;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 24;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *title = self.dataSoure[row];
    
    return title;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view{
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews){
        if (singleLine.frame.size.height < 1){
            
            singleLine.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
    UILabel* pickerLabel = (UILabel*)view;
    
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.minimumScaleFactor = 8.0;
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:12]];
        pickerLabel.textColor = [UIColor blackColor];
    }
    
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    
    return pickerLabel;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"row==%ld",row);
}
#pragma mark -- Action
- (IBAction)showMoreInfoAction:(UIButton*)sender {
    sender.selected = !sender.selected;
    NSLog(@"取反");
}

@end
