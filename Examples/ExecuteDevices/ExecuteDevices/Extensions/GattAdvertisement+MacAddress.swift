//
//  GattAdvertisement+MacAddress.swift
//  ExecuteDevices
//
//  Created by Mac on 23/11/2020.
//

import Foundation
import Gormsson
import Nevanlinna

extension GattAdvertisement {
    public var macAddress: TBMacAddressType {
        // Specific logic from this device
        guard let data = manufacturerData?[1...6] else { return TBMacAddressType(with: []) }
        return TBMacAddressType(with: Array(data))
    }
}

public final class TBMacAddressType: DataInitializable {
    private let characteristicData: [UInt8]

    /// DataInitializable init.
    required public init(with octets: [UInt8]) {
        characteristicData = octets
    }

    /// The mac address value string representation.
    public var string: String {
        return characteristicData.map({ String(format: "%02hhx", $0).uppercased() })
            .joined(separator: ":")
    }
}
