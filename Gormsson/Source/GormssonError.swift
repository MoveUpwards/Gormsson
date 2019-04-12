//
//  GormssonError.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 12/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

public enum GormssonError: Error {
    case uncastableValue
    case missingValue
    case powerOff
    case deviceUnconnected
    case characteristicNotFound
    case alreadyNotifying
}
