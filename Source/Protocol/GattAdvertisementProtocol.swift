//
//  GattAdvertisementProtocol.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 21/10/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

public protocol GattAdvertisementProtocol {
    /// The current received signal strength indicator (RSSI) of the peripheral, in decibels.
    var rssi: Int { get }

    /// Local name of a peripheral.
    var localName: String? { get }

    /// Transmit power of a peripheral.
    var txPowerLevel: Int? { get }

    /// A list of one or more CBUUID objects, representing CBService UUIDs.
    var serviceUUIDs: [CBUUID]? { get }

    /// A dictionary containing service-specific advertisement data.
    /// Keys are CBUUID objects, representing CBService UUIDs. Values are Data objects.
    var serviceData: [CBUUID: Data]? { get }

    /// A dictionary containing service-specific advertisement data.
    /// Keys are CBUUID objects, representing CBService UUIDs. Values are Data objects.
    var manufacturerData: Data? { get }

    /// A list of one or more CBUUID objects, representing CBService UUIDs that were
    /// found in the "overflow" area of the advertising data. Due to the nature of the data stored in this area,
    /// UUIDs listed here are "best effort" and may not always be accurate.
    var overflowService: [CBUUID]? { get }

    /// Whether or not the advertising event type was connectable.
    var isConnectable: Bool { get }

    /// A list of one or more CBUUID objects, representing CBService UUIDs.
    var solicitedService: [CBUUID]? { get }

    /// Creates GattAdvertisement from advertisement dictionary and rssi value.
    init(with advertisementData: [String: Any], rssi: Int)
}
