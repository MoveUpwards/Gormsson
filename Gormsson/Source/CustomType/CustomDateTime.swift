//
//  CustomDateTime.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 18/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation
import Nevanlinna

// See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.date_time.xml

/// The Date Time characteristic is used to represent time.
public final class CustomDateTime: DataInitializable {
    private let characteristicData: [UInt8]

    /// DataInitializable init.
    required public init(with octets: [UInt8]) {
        characteristicData = octets
    }

    /// The current timestamp for the measure.
    public var timestamp: TimeInterval? {
        let dateComponents = DateComponents(calendar: Calendar.current,
                                            timeZone: TimeZone(secondsFromGMT: 0),
                                            year: Int(UInt16(with: Array(characteristicData[0...1]))),
                                            month: Int(characteristicData[2]),
                                            day: Int(characteristicData[3]),
                                            hour: Int(characteristicData[4]),
                                            minute: Int(characteristicData[5]),
                                            second: Int(characteristicData[6]))

        return dateComponents.date?.timeIntervalSince1970
    }
}
