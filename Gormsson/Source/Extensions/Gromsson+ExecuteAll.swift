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
    /// ActionType is the possible type of the characteristic.
    public enum ActionType { // No notify or connect/disconnect
        case read
        case write(value: DataConvertible, type: CBCharacteristicWriteType = .withResponse)
    }

    /// Action is the action to proceed.
    public struct Action {
        var characteristic: CharacteristicProtocol
        var type: ActionType
    }

    /// Start to connect each device, then **execute** the characteristic, return the result and disconnect.
    /// At the end of all requests (or if timeout is reach), call completion.
    @available(*, deprecated, message: "Will be remove in next minor version", renamed: "executeAll")
    public func execute(_ characteristic: GattCharacteristic,
                        on devices: [CBPeripheral],
                        action: Gormsson.ActionType = .read,
                        result: @escaping (Result<(peripheral: CBPeripheral, data: DataInitializable), Error>) -> Void,
                        timeout: Int = 30,
                        completion: ((Error?) -> Void)? = nil) {
        executeAll([Action(characteristic: characteristic.characteristic, type: action)],
                   on: devices,
                   timeout: timeout,
                   result: result,
                   completion: completion)
    }

    /// Start to connect each device, then **execute** the characteristic, return the result and disconnect.
    /// At the end of all requests (or if timeout is reach), call completion.
    @available(*, deprecated, message: "Will be remove in next minor version", renamed: "executeAll")
    public func execute(_ characteristic: CharacteristicProtocol,
                        on devices: [CBPeripheral],
                        action: Gormsson.ActionType = .read,
                        result: @escaping (Result<(peripheral: CBPeripheral, data: DataInitializable), Error>) -> Void,
                        timeout: Int = 30,
                        completion: ((Error?) -> Void)? = nil) {
        executeAll([Action(characteristic: characteristic, type: action)],
                   on: devices,
                   timeout: timeout,
                   result: result,
                   completion: completion)
    }

    /// Start to connect each device, then **execute** all the characteristics in array order, return all the results and disconnect.
    /// At the end of all requests (or if timeout is reach), call completion.
    /// Result param will trigger each success or failure, and completion will be trigger just once.
    public func executeAll(_ actions: [Action],
                           on peripherals: [CBPeripheral],
                           timeout: Int = 30,
                           result: ((Result<(peripheral: CBPeripheral,
                                             data: DataInitializable), Error>) -> Void)? = nil,
                           completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let downloadGroup = DispatchGroup()

            peripherals.forEach { peripheral in
                downloadGroup.enter()

                self?.manager.connect(peripheral, success: {
                    // Everything is fine, wait to be ready
                }, failure: { error in
                    if let error = error {
                        result?(.failure(error))
                    }
                }, didReadyHandler: {
                    self?.execute(actions: actions, on: peripheral, result: { currentResult in
                        if case let .failure(error) = currentResult {
                            result?(.failure(error))
                        } else if case let .success(value) = currentResult {
                            result?(.success((peripheral, value)))
                        }
                    }, completion: { error in
                        self?.disconnect(peripheral)
                    })
                }, didDisconnectHandler: { error in
                    if let error = error {
                        result?(.failure(error))
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

    // MARK: - Private functions

    private func execute(at index: Int = 0,
                         actions: [Action],
                         on peripheral: CBPeripheral,
                         result: @escaping (Result<DataInitializable, Error>) -> Void,
                         completion: ((Error?) -> Void)? = nil) {
        guard index < actions.count else {
            completion?(nil)
            return
        }
        let action = actions[index]
        let block = { [weak self] (currentResult: Result<DataInitializable, Error>) in
            if case let .failure(error) = currentResult {
                result(.failure(error))
            } else if case let .success(value) = currentResult {
                result(.success(value))
            }
            self?.execute(at: index + 1, actions: actions, on: peripheral, result: result, completion: completion)
        }

        switch action.type {
        case .read:
            manager.read(action.characteristic, on: peripheral, result: block)
        case .write(let value, let type):
            manager.write(action.characteristic, on: peripheral, value: value, type: type, result: block)
        }
    }
}
