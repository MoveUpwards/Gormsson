//
//  ConnectHandler.swift
//  Gormsson
//
//  Created by Mac on 03/04/2020.
//  Copyright © 2020 Loïc GRIFFIE. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Struct to handle connect event
internal struct ConnectHandler {
    /// The block to call each time a peripheral is connected.
    internal var didConnect: (() -> Void)?
    /// The block to call when a peripheral fails to connect.
    internal var didFailConnect: ((Error?) -> Void)?
    /// The block to call once all custom services and characterics.
    internal var didReady: (() -> Void)?
    /// The block to call each time a peripheral is disconnect.
    internal var didDisconnect: ((Error?) -> Void)?

    /// Count the remaining services to discover before sending didReady callback
    internal var remainingServices: Int = 0
}
