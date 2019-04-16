//
//  GormssonState.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 16/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

@objc
/// The manager’s state.
public enum GormssonState: Int {
    /// Uninitialized, wait for a valid state.
    case unknown
    /// BLE is powered on.
    case isPoweredOn
    /// You need to turn on BLE.
    case needBluetooth
    /// BLE was lost or disconnected.
    case didLostBluetooth
}
