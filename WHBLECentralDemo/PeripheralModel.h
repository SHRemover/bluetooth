//
//  PeripheralModel.h
//  WHBLECentralDemo
//
//  Created by gs_sh on 2017/11/25.
//  Copyright © 2017年 wuhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;
@interface PeripheralModel : NSObject

@property (retain, nonatomic) CBPeripheral *peripheral;
@property (retain, nonatomic) NSNumber *RSSI;
@property (retain, nonatomic) NSDictionary *advertisementData;

@end
