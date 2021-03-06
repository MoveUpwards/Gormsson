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
    /// The manager is not ready for this operation.
    case notReady
    /// The manager is already scanning.
    case alreadyScanning
    /// The current device was disconnected or lost the BLE connection.
    case deviceDisconnected
    /// The characteristic is not present on the peripheral (or not yet initialized).
    case characteristicNotFound
    /// The manager accept only one notify per characteristic.
    case alreadyNotifying
    /// The characteristic's notify was stop.
    case stopNotifying
    /// The operation reach the timed out.
    case timedOut
    /// Each time an action fail where the cause of the failure is nil
    case unexpectedNilError
}
