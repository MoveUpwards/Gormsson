//
//  DeviceInformation.swift
//  GormssonDemo
//
//  Created by Damien Noël Dubuisson on 08/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

/// ManufacturerNameString's characteristic of DeviceInformation service
internal final class ManufacturerNameString: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A29")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .deviceInformation
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return String.self
    }
}

/// ModelNumberString's characteristic of DeviceInformation service
internal final class ModelNumberString: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A24")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .deviceInformation
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return String.self
    }
}

/// SerialNumberString's characteristic of DeviceInformation service
internal final class SerialNumberString: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A25")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .deviceInformation
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return String.self
    }
}

/// HardwareRevisionString's characteristic of DeviceInformation service
internal final class HardwareRevisionString: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A27")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .deviceInformation
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return String.self
    }
}

/// FirmwareRevisionString's characteristic of DeviceInformation service
internal final class FirmwareRevisionString: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A26")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .deviceInformation
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return String.self
    }
}

/// SoftwareRevisionString's characteristic of DeviceInformation service
internal final class SoftwareRevisionString: CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    public var uuid: CBUUID {
        return CBUUID(string: "2A28")
    }

    /// The service that this characteristic belongs to.
    public var service: GattService {
        return .deviceInformation
    }

    /// The value's format of the characteristic.
    public var format: DataInitializable.Type {
        return String.self
    }
}

// TODO: Add missing: System ID, IEEE 11073-20601 Regulatory Certification Data List, PnP ID
