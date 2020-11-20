//
//  BluetoothService.swift
//  ExecuteDevices
//
//  Created by Mac on 20/11/2020.
//

import Foundation
import Gormsson

final class BluetoothService {
    let manager = Gormsson(queue: DispatchQueue(label: "com.ble.manager", attributes: .concurrent))
}
