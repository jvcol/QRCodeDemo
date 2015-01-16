//
//  AddCardVC.m
//  StoCard
//
//  Created by yangw on 14-9-24.
//  Copyright (c) 2014年 Zhanghe. All rights reserved.
//

#import "AddCardVC.h"
#import "ZBarSymbol.h"
#import "DBHelper.h"

@interface AddCardVC () <UITextFieldDelegate,UIAlertViewDelegate> {
    UITextField * _textField;
    UITextField * _cardTF;
}

@end

@implementation AddCardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.backBarButtonItem = item;
    
    UIBarButtonItem * rightitem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightitem;
    
    [self initViews];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save {
    if (_textField.text == nil || _textField.text.length == 0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入Card Name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else {
        if ([[DBHelper shared] existWithCardName:_textField.text]) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"已经存在名称为%@的卡，是否要覆盖原来的卡？",_textField.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert show];
        }else {
            [self saveCard];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self saveCard];
    }
}

- (void)saveCard {
    CardInfo * info = [[CardInfo alloc] init];
    info.name = _textField.text;
    info.type = self.symbol.type;
    info.data = _cardTF.text;
    [[DBHelper shared] saveCard:info];
    if (self.delegate && [self.delegate respondsToSelector:@selector(addCardVC:withCard:)]) {
        [self.delegate addCardVC:self withCard:info];
    }
    [self performSelector:@selector(back) withObject:nil afterDelay:0.5];
}

- (void)initViews {
    CGFloat width = self.view.frame.size.width;
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 64+10, width, 21)];
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.placeholder = @"Store name";
    _textField.delegate = self;
    _textField.textAlignment = NSTextAlignmentCenter;
    _textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.view addSubview:_textField];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 120, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Card nmber";
    [self.view addSubview:label];
    
    _cardTF = [[UITextField alloc] initWithFrame:CGRectMake(130, 200, width-140, 20)];
    _cardTF.borderStyle = UITextBorderStyleNone;
    _cardTF.text = self.symbol.data;
    [self.view addSubview:_cardTF];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
