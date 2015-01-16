//
//  AddCardVC.h
//  StoCard
//
//  Created by yangw on 14-9-24.
//  Copyright (c) 2014年 Zhanghe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddCardVCDelegate;

@class ZBarSymbol;

@interface AddCardVC : UIViewController

@property (nonatomic, strong) ZBarSymbol * symbol;
@property (nonatomic, assign) id <AddCardVCDelegate> delegate;

@end

@protocol AddCardVCDelegate <NSObject>

- (void)addCardVC:(AddCardVC *)addVC withCard:(CardInfo *)info;

@end
