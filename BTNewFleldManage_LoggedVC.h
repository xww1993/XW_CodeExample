//
//  BTNewFleldManage_LoggedVC.h
//  nongcaibao
//
//  Created by 谢蔚蔚 on 2017/6/9.
//  Copyright © 2017年 Batian. All rights reserved.
//

#import <UIKit/UIKit.h>
/** 最新的田间管理首页 */
@interface BTNewFleldManage_LoggedVC : UIViewController
+ (instancetype)loadFromStoryboard;
+ (instancetype)loadFromStoryboardWithGrowersName:(NSString *)growerName GrowerID:(NSString *)growerID GrowerRoleID:(NSString *)growerRoleID GrowerMenuId:(NSString *)growerMenuId;
@end

