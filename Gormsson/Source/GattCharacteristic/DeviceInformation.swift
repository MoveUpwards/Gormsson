//
//  DeviceInformation.swift
//  GormssonDemo
//
//  Created by Damien Noël Dubuisson on 08/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth

internal final class ManufacturerNameString: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "2A29")
    }

    public var service: GattService {
        return .deviceInformation
    }

    public var format: Any.Type {
        return String.self
    }
}

internal final class ModelNumberString: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "2A24")
    }

    public var service: GattService {
        return .deviceInformation
    }

    public var format: Any.Type {
        return String.self
    }
}

internal final class SerialNumberString: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "2A25")
    }

    public var service: GattService {
        return .deviceInformation
    }

    public var format: Any.Type {
        return String.self
    }
}

internal final class HardwareRevisionString: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "2A27")
    }

    public var service: GattService {
        return .deviceInformation
    }

    public var format: Any.Type {
        return String.self
    }
}

internal final class FirmwareRevisionString: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "2A26")
    }

    public var service: GattService {
        return .deviceInformation
    }

    public var format: Any.Type {
        return String.self
    }
}

internal final class SoftwareRevisionString: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "2A28")
    }

    public var service: GattService {
        return .deviceInformation
    }

    public var format: Any.Type {
        return String.self
    }
}

// TODO: Add missing: System ID, IEEE 11073-20601 Regulatory Certification Data List, PnP ID
