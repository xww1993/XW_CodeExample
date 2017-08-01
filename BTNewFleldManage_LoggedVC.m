//
//  BTNewFleldManage_LoggedVC.m
//  nongcaibao
//
//  Created by 谢蔚蔚 on 2017/6/9.
//  Copyright © 2017年 Batian. All rights reserved.
//

#import "BTNewFleldManage_LoggedVC.h"
#import "UserInformationModle.h"
#import "BTVM_NewFieldManage_Logged.h"
#import "BTFleldFunctionCVC.h"
#import "BTNewCropSelectCVC.h"
#import "BTUnCropBBView.h"
#import "BTSchemeTabC.h"
#import <ReactiveObjC.h>
#import <SVProgressHUD.h>

#define FunctionSelectVc ((BTFleldFunctionCVC *)self.childViewControllers[0])
#define CropSelectVc ((BTNewCropSelectCVC *)self.childViewControllers[1])
#define SchemeVC  ((BTSchemeTabC *)self.childViewControllers[2])

@interface BTNewFleldManage_LoggedVC ()
@property (nonatomic, strong) BTVM_NewFieldManage_Logged * viewModel;
@property (weak, nonatomic) IBOutlet UIView *cropSelectView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cropSelectViewHeight;

@property (nonatomic, copy) BTUnCropBBView * unCropView;
@end

@implementation BTNewFleldManage_LoggedVC{
    UserInformationModle * _info;
    BTUnCropBBView * _unCropView;
}
+ (instancetype)loadFromStoryboard{
    BTNewFleldManage_LoggedVC * VC = [[UIStoryboard storyboardWithName:@"NewFieldManage" bundle:nil]instantiateViewControllerWithIdentifier:@"BTNewFleldManage_Logged"];
    VC.title = @"田间管理";
    return VC;
}
+ (instancetype)loadFromStoryboardWithGrowersName:(NSString *)growerName GrowerID:(NSString *)growerID GrowerRoleID:(NSString *)growerRoleID GrowerMenuId:(NSString *)growerMenuId {
    BTNewFleldManage_LoggedVC * VC = [[UIStoryboard storyboardWithName:@"NewFieldManage" bundle:nil]instantiateViewControllerWithIdentifier:@"BTNewFleldManage_Logged"];
    VC.title = growerName;
   
    [VC.viewModel setGrowersID:growerID GrowersRoleID:growerRoleID GrowersMenuId:growerMenuId];
    return VC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    
    DLog(@"%@",self.childViewControllers);
    /*
     "<BTFleldFunctionCVC: 0x7fe307474560>",
     "<UICollectionViewController: 0x7fe30a9fac60>",
     "<BTSchemeTabC: 0x7fe307475760>"
     */
    // Do any additional setup after loading the view.
}
- (void)initialize{
    if (self.viewModel.isGrowersVC) {
        self.bottomViewHight.constant = CGFLOAT_MIN;
    }
    [self allSignal];
}

- (void)allSignal{
    @weakify(self);
    [self dataSignal];
    //
    [SchemeVC returnHightBlock:^(NSInteger hight) {
        @strongify(self);
        if (self && !self.viewModel.isGrowersVC) {
           self.bottomViewHight.constant = 40+60*hight;
        }
    }];
    
    //MARK: 作物模块点击的操作
    [CropSelectVc returnSelectBlock:^(BTListModle_Crop *mod) {
        @strongify(self);
        [self.viewModel gotoCropLandDeteilWithModel:mod];
    }];
    CropSelectVc.addCropLand = ^{
        @strongify(self);
        [self.viewModel addNewCropLand];
    };
    
    //MARK: 由于界面重用 这个界面的我的作物
    [FunctionSelectVc returnSelectBlock:^(NSString *actionName, NSString *idStr) {
        @strongify(self);
        SEL ActionSel = NSSelectorFromString(actionName);
        if ([self.viewModel respondsToSelector:ActionSel]) {
            [self.viewModel performSelector:ActionSel];
        }
    }];

}
- (void)dataSignal{
    @weakify(self);
     [SVProgressHUD showWithStatus:@"获取界面数据中..."];
    [[self.viewModel loadFieldManageData] subscribeNext:^(RACTuple*  _Nullable x) {
        @strongify(self);
        [FunctionSelectVc setMenuListWithArr:x.first];
        [CropSelectVc setCropDataWithArr:x.second];
        [self setCropViewHightWithCropCount:((NSMutableArray*)x.second).count];
        [SVProgressHUD dismiss];
        
    } error:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error.domain]];
    }];
}
- (void)setCropViewHightWithCropCount:(NSInteger )num{
    if (num == 0 ) {
        @weakify(self);
        self.cropSelectViewHeight.constant = 300;
        _unCropView = [BTUnCropBBView loadFromXIBWithClick:^{
            @strongify(self);
            [self.viewModel addNewCropLand];
        } WithFrame:CGRectMake(0, 0,ScreenWidth, 300)];
        
        [self.cropSelectView addSubview:_unCropView];
        return;
    }
    if (_unCropView) {
        [_unCropView removeFromSuperview];
        _unCropView = nil;
    }
    CGFloat num_float = num+0.0f;
    NSInteger count= ceil((num_float + 1)/2);
   
    self.cropSelectViewHeight.constant = 50 + count*100 +(count+1)*5;

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)dealloc{
    
    DLog(@"%@ to be dealloc!",NSStringFromClass(self.class));
}
- (BTVM_NewFieldManage_Logged *)viewModel{
    if (!_viewModel) {
        _viewModel = [BTVM_NewFieldManage_Logged new];
        _viewModel.viewController = self;
    }
    return _viewModel;
}

@end
