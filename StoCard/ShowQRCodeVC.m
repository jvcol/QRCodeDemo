//
//  ShowQRCodeVC.m
//  StoCard
//
//  Created by yangw on 14-9-23.
//  Copyright (c) 2014年 Zhanghe. All rights reserved.
//

#import "ShowQRCodeVC.h"
#import "ZBarSDK.h"
#import "BarCodeView.h"
#import "QRCodeGenerator.h"

@interface ShowQRCodeVC () {
    BarCodeView * codeview;
    UIImageView * imageView;
}

@end

@implementation ShowQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.backBarButtonItem = item;
        
    [self initViews];
    
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)mainPath {
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"MyCards"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return path;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initViews {
//    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height-64-100, self.view.frame.size.width-20, 100)];
//    label.text = [NSString stringWithFormat:@"data:%@\ntypeName:%@",self.symbol.data,self.symbol.typeName];
//    label.numberOfLines = 0;
//    label.textColor = [UIColor blackColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:label];
    
    UILabel * despLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 280+64, self.view.frame.size.width, 100)];
    despLabel.backgroundColor = [UIColor clearColor];
    despLabel.text = [NSString stringWithFormat:@"Code Num : %@",self.card.data];
    despLabel.textColor = [UIColor blackColor];
    [self.view addSubview:despLabel];
    
    if (ZBAR_EAN13 == self.card.type) {
        codeview = [[BarCodeView alloc] initWithFrame:CGRectMake(47, 64+10, self.view.frame.size.width-94-2, 113+20)];
        [self.view addSubview:codeview];
        [codeview setBarCodeNumber:self.card.data];
        
        despLabel.text = [NSString stringWithFormat:@"Code Num : %@",self.card.data];
        
        
    }else {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(47, 64+10, self.view.frame.size.width-94, 240)];
        imageView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:imageView];
        imageView.image = [QRCodeGenerator qrImageForString:self.card.data imageSize:imageView.bounds.size.width];
        
        if ([self.card.data rangeOfString:@"http://"].location != NSNotFound) {
            despLabel.text = @"Code Info : ";
            [despLabel sizeToFit];
            
            UILabel * urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(despLabel.frame), CGRectGetMinY(despLabel.frame), 0, 0)];
            urlLabel.textColor = [UIColor blueColor];
            urlLabel.text = self.card.data;
            [self.view addSubview:urlLabel];
            [urlLabel sizeToFit];
            
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = urlLabel.frame;
            [button addTarget:self action:@selector(go2Web) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            
        }else {
            despLabel.text = [NSString stringWithFormat:@"Code Info : %@",self.card.data];
        }
        
    }
    
}

- (void)go2Web {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.card.data]];
}

@end
