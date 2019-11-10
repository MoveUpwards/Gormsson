//
//  GormssonError.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 12/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

/// An enum representing all Gormsson's error that can be thrown.
public enum GormssonError: Error {
    /// The value was uncastable to expected type (removed error).
    case uncastableValue
    /// The write request has no value (shouldn't happens).
    case missingValue
    /// The manager's state got a BLE shutdown, you should restart it.
    case powerOff
    /// The current device was disconnected or lost the BLE connection.
    case deviceUnconnected
    /// The characteristic is not present on the peripheral (or not yet initialized).
    case characteristicNotFound
    /// The manager accept only one notify per characteristic.
    case alreadyNotifying
    /// The characteristic's notify was stop.
    case stopNotifying
}
