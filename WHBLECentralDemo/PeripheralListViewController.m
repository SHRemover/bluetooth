//
//  PeripheralListViewController.m
//  WHBLECentralDemo
//
//  Created by gs_sh on 2017/11/22.
//  Copyright © 2017年 wuhao. All rights reserved.
//

#import "PeripheralListViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralModel.h"


@interface PeripheralListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView *tableView;

@end

@implementation PeripheralListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.estimatedRowHeight = 100;
//    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self.view addSubview:_tableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _peripheralListArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
//    CBPeripheral *peripheral = _peripheralListArr[indexPath.row];
//    cell.textLabel.text = peripheral.name.length ? peripheral.name : [NSString stringWithFormat:@"%ld", indexPath.row];
    
    PeripheralModel *model = _peripheralListArr[indexPath.row];
//    NSString *str = [NSString stringWithFormat:@"搜索到的设备:%@ RSSI:%@ name:%@ UUID:%@ advertisementData特征数据:%@", model.peripheral, model.RSSI, model.peripheral.name, model.peripheral.identifier, model.advertisementData];
    
    NSString *str = [NSString stringWithFormat:@"name:%@ -- RSSI:%@ \n UUID:%@ \n advertisementData:%@", model.peripheral.name, model.RSSI, model.peripheral.identifier, model.advertisementData];
    
    cell.textLabel.text = str;
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PeripheralModel *model = _peripheralListArr[indexPath.row];
    if (self.clickHandler) {
        self.clickHandler(model.peripheral);
    }
    [self.navigationController popViewControllerAnimated:YES];
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
