//
//  GattAdvertisement.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 10/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth

/// Class that provide all advertisement datas with direct access variables.
public final class GattAdvertisement: GattAdvertisementProtocol {
    private let advertisementData: [String: Any]

    /// The current received signal strength indicator (RSSI) of the peripheral, in decibels.
    public let rssi: Int

    /// Creates GattAdvertisement from advertisement dictionary and rssi value.
    public init(with advertisementData: [String: Any], rssi: Int) {
        self.advertisementData = advertisementData
        self.rssi = rssi
    }

    /// Local name of a peripheral.
    public var localName: String? {
        return advertisementData[CBAdvertisementDataLocalNameKey] as? String
    }

    /// Transmit power of a peripheral.
    public var txPowerLevel: Int? {
        return advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Int
    }

    /// A list of one or more CBUUID objects, representing CBService UUIDs.
    public var serviceUUIDs: [CBUUID]? {
        return advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
    }

    /// A dictionary containing service-specific advertisement data.
    /// Keys are CBUUID objects, representing CBService UUIDs. Values are Data objects.
    public var serviceData: [CBUUID: Data]? {
        return advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data]
    }

    /// A dictionary containing service-specific advertisement data.
    /// Keys are CBUUID objects, representing CBService UUIDs. Values are Data objects.
    public var manufacturerData: Data? {
        return advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
    }

    /// A list of one or more CBUUID objects, representing CBService UUIDs that were
    /// found in the "overflow" area of the advertising data. Due to the nature of the data stored in this area,
    /// UUIDs listed here are "best effort" and may not always be accurate.
    public var overflowService: [CBUUID]? {
        return advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID]
    }

    /// Whether or not the advertising event type was connectable.
    public var isConnectable: Bool {
        return advertisementData[CBAdvertisementDataIsConnectable] as? Bool ?? false
    }

    /// A list of one or more CBUUID objects, representing CBService UUIDs.
    public var solicitedService: [CBUUID]? {
        return advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey] as? [CBUUID]
    }
}
