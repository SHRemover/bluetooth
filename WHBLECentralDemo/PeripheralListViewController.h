//
//  PeripheralListViewController.h
//  WHBLECentralDemo
//
//  Created by gs_sh on 2017/11/22.
//  Copyright © 2017年 wuhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBPeripheral;
@interface PeripheralListViewController : UIViewController

@property (nonatomic, copy) void (^clickHandler)(CBPeripheral *peripheral);
@property (retain, nonatomic) NSArray *peripheralListArr;

@end
