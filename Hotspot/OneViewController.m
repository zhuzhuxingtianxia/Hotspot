//
//  OneViewController.m
//  Hotspot
//
//  Created by Jion on 2017/12/13.
//  Copyright © 2017年 Jion. All rights reserved.
//

#import "OneViewController.h"
#import "HotspotView.h"
#import "ZJAlertView.h"
@interface OneViewController ()
@property(nonatomic,strong)HotspotView  *hotspotView;
@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self buildHotspotView];
    
}

-(void)buildHotspotView{
    self.hotspotView = [[HotspotView alloc] init];
    [self.view addSubview:self.hotspotView];
    
    self.hotspotView.frame = CGRectMake(0, 240, self.view.bounds.size.width, 68);
    NSArray *hotArray = @[@{@"message":@"今年的年终奖要到年后才能发,真是痛心不已！你们觉得呢",@"createdate":@"01-19"},@{@"message":@"员工都表示出了非常的不满",@"createdate":@"01-20"},@{@"message":@"大家表示都不能愉快的过春节了",@"createdate":@"01-20"},@{@"message":@"挖个坑埋点土数个一二三四五",@"createdate":@"01-21"}];
    UIImage *img = [UIImage imageNamed:@"btn_fwbb"];
   
    [self.hotspotView titleImage:img hotspot:hotArray completion:^(HotspotModel *model) {
        
         [ZJAlertView showAlertViewWithMessage:model.message cancelButtonTitle:@"取消" otherButtonTitle:@"确定" completion:^(NSInteger buttonIndex) {
         
         }];
        
    }];
}

-(void)dealloc{
    [self.hotspotView cancelAllTimer];
    //取消定时器
    NSLog(@"dealoc");
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
