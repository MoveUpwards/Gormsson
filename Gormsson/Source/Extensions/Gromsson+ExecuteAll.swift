//
//  Gromsson+ExecuteAll.swift
//  Gormsson
//
//  Created by Mac on 20/11/2020.
//  Copyright © 2020 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

extension Gormsson {
    /// Action possible on ExecuteAll functions.
    public enum Action { // No notify or connect/disconnect
        case read
        case write(value: DataConvertible, type: CBCharacteristicWriteType = .withResponse)
    }

    /// Start to connect each device, then **execute** the characteristic, return the result and disconnect.
    /// At the end of all requests (or if timeout is reach), call completion.
    public func execute(_ characteristic: GattCharacteristic,
                        on devices: [CBPeripheral],
                        action: Gormsson.Action = .read,
                        result: @escaping (Result<(peripheral: CBPeripheral, data: DataInitializable), Error>) -> Void,
                        timeout: Int = 30,
                        completion: ((Error?) -> Void)? = nil) {
        executeAll(characteristic.characteristic, on: devices, action: action, result: result, timeout: timeout, completion: completion)
    }

    /// Start to connect each device, then **execute** the characteristic, return the result and disconnect.
    /// At the end of all requests (or if timeout is reach), call completion.
    public func execute(_ characteristic: CharacteristicProtocol,
                        on devices: [CBPeripheral],
                        action: Gormsson.Action = .read,
                        result: @escaping (Result<(peripheral: CBPeripheral, data: DataInitializable), Error>) -> Void,
                        timeout: Int = 30,
                        completion: ((Error?) -> Void)? = nil) {
        executeAll(characteristic, on: devices, action: action, result: result, timeout: timeout, completion: completion)
    }

    // MARK: - Private functions

    private func executeAll(_ characteristic: CharacteristicProtocol,
                            on devices: [CBPeripheral],
                            action: Gormsson.Action = .read,
                            result: @escaping (Result<(peripheral: CBPeripheral, data: DataInitializable), Error>) -> Void,
                            timeout: Int = 30,
                            completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let downloadGroup = DispatchGroup()

            devices.forEach { peripheral in
                downloadGroup.enter()

                var hasResult = false
                self?.manager.connect(peripheral, success: {
                    // Everything is fine, wait to be ready
                }, failure: { error in
                    if let error = error, !hasResult {
                        hasResult = true
                        result(.failure(error))
                    }
                }, didReadyHandler: {
                    let block = { (currentResult: Result<DataInitializable, Error>) in
                        if case let .failure(error) = currentResult, !hasResult {
                            hasResult = true
                            result(.failure(error))
                        } else if case let .success(value) = currentResult, !hasResult {
                            hasResult = true
                            result(.success((peripheral, value)))
                        }
                        self?.disconnect(peripheral)
                    }

                    switch action {
                    case .read:
                        self?.manager.read(characteristic, on: peripheral, result: block)
                    case .write(let value, let type):
                        self?.manager.write(characteristic, on: peripheral, value: value, type: type, result: block)
                    }
                }, didDisconnectHandler: { error in
                    if let error = error, !hasResult {
                        hasResult = true
                        result(.failure(error))
                    }

                    downloadGroup.leave()
                })
            }

            // Wait for the timeout, if needed
            let result = downloadGroup.wait(timeout: .now() + .seconds(timeout))

            DispatchQueue.main.async {
                guard result == .timedOut else {
                    completion?(nil) // Completed with success
                    return
                }

                completion?(GormssonError.timedOut)
            }
        }
    }
}
