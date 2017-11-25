//
//  ViewController.m
//  WHBLECentralDemo
//  https://github.com/remember17/WHBLEDemo
//  Created by 吴浩 on 2017/7/18.
//  Copyright © 2017年 wuhao. All rights reserved.
//  http://www.jianshu.com/p/38a4c6451d93

#import "ViewController.h"
#import "PeripheralListViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralModel.h"

#define SERVICE_UUID        @"CDD1"
#define CHARACTERISTIC_UUID @"CDD2"

@interface ViewController () <CBCentralManagerDelegate,CBPeripheralDelegate>
{
    BOOL isNotifying; // 订阅状态
    PeripheralModel *model;
}
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, retain) NSMutableArray *peripheralMArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"蓝牙中心设备";

    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"选取设备" style:(UIBarButtonItemStylePlain) target:self action:@selector(choosePeripheral:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIButton *clickBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    clickBtn.frame = CGRectMake(100, 400, 80, 50);
    clickBtn.titleLabel.text = @"上升";
    clickBtn.backgroundColor = [UIColor cyanColor];
    [clickBtn addTarget:self action:@selector(touchDown:) forControlEvents:(UIControlEventTouchDown)];
    [clickBtn addTarget:self action:@selector(touchUpInside:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:clickBtn];
    _peripheralMArr = [NSMutableArray arrayWithCapacity:30];
}

- (void)choosePeripheral:(UIBarButtonItem *)item {
    NSLog(@"选取设备");
    PeripheralListViewController *vc = [[PeripheralListViewController alloc] init];
    vc.peripheralListArr = _peripheralMArr;
    
    vc.clickHandler = ^(CBPeripheral *peripheral) {
        // 连接外设
        [self.centralManager connectPeripheral:peripheral options:nil];
    };
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)touchDown:(UIButton *)sender {
    NSLog(@"上升 ...ing");
}
- (void)touchUpInside:(UIButton *)sender {
    NSLog(@"停止 上升");
}

/** 判断手机蓝牙状态
    CBManagerStateUnknown = 0,  未知
    CBManagerStateResetting,    重置中
    CBManagerStateUnsupported,  不支持
    CBManagerStateUnauthorized, 未验证
    CBManagerStatePoweredOff,   未启动
    CBManagerStatePoweredOn,    可用
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // 蓝牙可用，开始扫描外设
    if (central.state == CBManagerStatePoweredOn) {
        NSLog(@"蓝牙可用");
        // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
//        [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
//        [central scanForPeripheralsWithServices:nil options:nil];
        // 扫描所有设备服务
        [central scanForPeripheralsWithServices:nil options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
    }
    if(central.state==CBManagerStateUnsupported) {
        NSLog(@"该设备不支持蓝牙");
    }
    if (central.state==CBManagerStatePoweredOff) {
        NSLog(@"蓝牙已关闭");
    }
}

/**
 发现外围设备

 @param central 中心设备
 @param peripheral 外围设备
 @param advertisementData 特征数据
 @param RSSI 信号质量（信号强度）
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 对外设对象进行强引用
    self.peripheral = peripheral;
    
    PeripheralModel *model = [[PeripheralModel alloc] init];
    model.peripheral = peripheral;
    model.RSSI = RSSI;
    model.advertisementData = advertisementData;
    
    for (PeripheralModel *model in _peripheralMArr) {
        if ([peripheral.identifier isEqual:model.peripheral.identifier]) {
            return;
        }
    }
    [_peripheralMArr addObject:model];
    
    NSString *str = [NSString stringWithFormat:@"搜索到的设备:%@ RSSI:%@ name:%@ UUID:%@ advertisementData特征数据:%@", peripheral, RSSI, peripheral.name, peripheral.identifier, advertisementData];
    
    NSLog(@"%@", str);
}

/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    // 可以停止扫描
    [self.centralManager stopScan];
    // 设置代理
    peripheral.delegate = self;
    // 根据UUID来寻找服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
    // 扫描所有服务
//    [peripheral discoverServices:nil];
    
    NSLog(@"连接成功");
}

/** 连接失败的回调 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接失败");
}

//断开蓝牙：[_centeralManager cancelPeripheralConnection:_peripheral];
/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"断开连接");
    // 断开连接可以设置重新连接
    [central connectPeripheral:peripheral options:nil];
}

#pragma mark -
#pragma mark - CBPeripheralDelegate

/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    // 遍历出外设中所有的服务
    for (CBService *service in peripheral.services) {
        NSLog(@"所有的服务：%@",service);
        
//        [peripheral discoverCharacteristics:nil forService:service];
    }
    
    // 这里仅有一个服务，所以直接获取
    CBService *service = peripheral.services.lastObject;
//    // 根据UUID寻找服务中的特征
    [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] forService:service];
}

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    if (error) {
        NSLog(@"外围设备寻找特征中发生错误，错误信息：%@", error.localizedDescription);
        return;
    }
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"所有特征：%@", characteristic);
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
        
        CBCharacteristicProperties properties = characteristic.properties;
        if (properties & CBCharacteristicPropertyBroadcast) {
            // 如果是广播特性
            NSLog(@"%@ 广播", characteristic);
//            self.characteristic = characteristic;
        }
        if (properties & CBCharacteristicPropertyRead) {
            // 如果具备读特性，即可读取特性的value
            NSLog(@"%@ 可读", characteristic);
//            [peripheral readValueForCharacteristic:characteristic];
        }
        if (properties & CBCharacteristicPropertyWrite) {
            // 如果具备写入值的特性，这个应该会有一些响应
            NSLog(@"%@ 可写，有回调", characteristic);
//            [peripheral writeValue:<#(nonnull NSData *)#> forCharacteristic:characteristic type:<#(CBCharacteristicWriteType)#>]
        }
        if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
            // 如果具备写入值 不需要响应的特性
            // 这里可以保存这个可以写的特性，便于后面往这个特性中写数据
            NSLog(@"%@ 可写，无回调", characteristic);
        }
        if (properties & CBCharacteristicPropertyNotify) {
            // 如果具备通知的特性，无响应
            NSLog(@"%@ 通知", characteristic);
//            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
//        self.characteristic = service.characteristics.lastObject;
    }
    
    if (service.characteristics.count) {

        // 这里只获取一个特征，写入数据的时候需要用到这个特征
        self.characteristic = service.characteristics.lastObject;

        // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
        [peripheral readValueForCharacteristic:self.characteristic];

        // 订阅通知
        [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
    }
}

/** 订阅状态的改变 */
// 特征值被更新后 setNotifyValue 方法回调
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"订阅失败");
        NSLog(@"%@",error);
        return;
    }
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功");
        isNotifying = YES;
    } else {
        NSLog(@"取消订阅");
    }
}

/** 接收到数据回调 */
// 没有更新特征值后 （调用readValueForCharacteristic:方法 或者外围设备在订阅后更新特征值 都会调用此代理方法）
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    // 拿到外设发送过来的数据
    NSData *data = characteristic.value;
    self.textField.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

/** 写入特征值回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"写入特征值失败");
    } else {
        NSLog(@"写入成功 回调值%@", characteristic);
    }
}

// 写入回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    if (error) {
        NSLog(@"写入失败%@", error);
        return;
    }
}

/** 读取数据 */
- (IBAction)didClickGet:(id)sender {
    [self.peripheral readValueForCharacteristic:self.characteristic];
}

/** 写入数据 */
- (IBAction)didClickPost:(id)sender {
    
    if (isNotifying) {
        // 用NSData类型来写入
        NSData *data = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
        // 根据上面的特征self.characteristic来写入数据
        [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }
}

@end
