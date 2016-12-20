//
//  ViewController.m
//  StoCard
//
//  Created by yangw on 14-9-23.
//  Copyright (c) 2014年 Zhanghe. All rights reserved.
//

#import "ViewController.h"
#import "ZBarSDK.h"
#import "ShowQRCodeVC.h"
#import "AddCardVC.h"
#import "DBHelper.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,ZBarReaderDelegate,AddCardVCDelegate> {
    UITableView * _tableView;
    NSMutableArray * _dataArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(doRightBarItemPressed:)];
    self.navigationItem.rightBarButtonItem = item;

    self.title = @"StoCard";
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _dataArray = [[NSMutableArray alloc] init];
    [_dataArray addObjectsFromArray:[[DBHelper shared] allCards]];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    NSLog(@"test");

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"didReceiveMemoryWarning");
}

- (void)doRightBarItemPressed:(id)sender {
    [self scanButtonTapped];
}

#pragma mark -- 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = _dataArray.count;
    if (count == 0) {
        count = 1;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIndentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    if (_dataArray.count == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"Add your card !";
    }else {
        CardInfo * info = (CardInfo *)_dataArray[indexPath.row];
        cell.textLabel.text = info.name;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_dataArray.count == 0 && indexPath.row == 0) {
        [self scanButtonTapped];
    }else {
        CardInfo * info = (CardInfo *)_dataArray[indexPath.row];
        ShowQRCodeVC * vc = [[ShowQRCodeVC alloc] init];
        vc.title = info.name;
        vc.card = info;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataArray.count == 0 && indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (_dataArray.count > 0) {
            [[DBHelper shared] deleteCard:_dataArray[indexPath.row]];
            [_dataArray removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        }
    }
}


#pragma mark --- 
- (void) scanButtonTapped
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentViewController:reader animated:YES completion:nil];
}

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
//    resultText.text = symbol.data;
    
    // EXAMPLE: do something useful with the barcode image
//    resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:^{
        AddCardVC * add = [[AddCardVC alloc] init];
        add.symbol = symbol;
        add.delegate = self;
        [self.navigationController pushViewController:add animated:YES];
    }];
}

- (void)addCardVC:(AddCardVC *)addVC withCard:(CardInfo *)info {
    [_dataArray addObject:info];
    [_tableView reloadData];
}

@end
