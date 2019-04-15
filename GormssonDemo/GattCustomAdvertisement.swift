//
//  GattCustomAdvertisement.swift
//  GormssonDemo
//
//  Created by Loïc GRIFFIE on 10/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import Foundation
import Gormsson
import CoreBluetooth

extension GattAdvertisement {
    /// An object containing the manufacturer data of a peripheral.
    open var macAddress: String? {
        guard let data = serviceData?[gpsControlService.uuid] else { return nil }
        return [UInt8](data).map({ String(format: "%02hhx", $0).uppercased() })
            .reversed()
            .joined(separator: ":")
    }
}
