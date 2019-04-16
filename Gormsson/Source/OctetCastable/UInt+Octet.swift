//
//  UInt+Octet.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 16/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension UInt16 {
    /// Init with an octets' array.
    init(with octets: [UInt8]) {
        guard octets.count == 2 else {
            self = 0
            return
        }
        self = UInt16(octets[0]) + UInt16(octets[1]) << 8
    }
}
