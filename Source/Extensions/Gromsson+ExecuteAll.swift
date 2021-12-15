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
        public let characteristic: CharacteristicProtocol
        public let type: ActionType

        public init(_ characteristic: CharacteristicProtocol, for type: ActionType = .read) {
            self.characteristic = characteristic
            self.type = type
        }

        public init(_ characteristic: GattCharacteristic, for type: ActionType = .read) {
            self.characteristic = characteristic.characteristic
            self.type = type
        }
    }

    public struct ActionResult {
        public let peripheral: CBPeripheral
        public let data: DataInitializable
        public let characteristic: CharacteristicProtocol
    }

    /// Start to connect each peripheral.
    /// Then **execute** all the characteristics in array order, return all the results.
    /// And then disconnect all peripherals.
    /// At the end of all requests (or if timeout is reach), call completion.
    /// Result param will trigger each success or failure, and completion will be trigger just once.
    public func executeAll(_ actions: [Action],
                           on peripherals: [CBPeripheral],
                           timeout: Int = 30,
                           result: ((Result<ActionResult, Error>) -> Void)? = nil,
                           completion: ((Error?) -> Void)? = nil) {
        let currentQueue = OperationQueue.current?.underlyingQueue
//        manager.queue?.async { [weak self] in
        let downloadGroup = DispatchGroup()
        peripherals.forEach { peripheral in
            downloadGroup.enter()
            print("1 on", OperationQueue.current?.underlyingQueue)

            manager.connect(peripheral, on: manager.queue, success: {
                // Everything is fine, wait to be ready
            }, failure: { error in
//                currentQueue?.async {
                    result?(.failure(error))
//                }
            }, didReady: { [weak self] in
                print("2 on", OperationQueue.current?.underlyingQueue)
                self?.execute(actions: actions, on: peripheral, result: { currentResult in
                    print("3 on", OperationQueue.current?.underlyingQueue)
//                    currentQueue?.async {
                        print("4 on", OperationQueue.current?.underlyingQueue)
                        if case let .failure(error) = currentResult {
                            result?(.failure(error))
                        } else if case let .success(value) = currentResult {
                            result?(.success(value))
                        }
//                    }
                }, completion: { error in
                    print("5 on", OperationQueue.current?.underlyingQueue)
                    if let error = error {
//                        currentQueue?.async {
                            result?(.failure(error))
//                        }
                    }

                    self?.cancel(peripheral)
                })
            }, didDisconnect: { disconnectResult in
                if case let .failure(error) = disconnectResult {
//                    currentQueue?.async {
                        result?(.failure(error))
//                    }
                }

                downloadGroup.leave()
            })
        }

        // Wait for the timeout, if needed
        let result = downloadGroup.wait(timeout: .now() + .seconds(timeout))

        guard result == .timedOut else {
            completion?(nil) // Completed with success
            return
        }

        completion?(GormssonError.timedOut)
//        }
    }

    // MARK: - Private functions

    private func execute(at index: Int = 0,
                         actions: [Action],
                         on peripheral: CBPeripheral,
                         result: @escaping (Result<ActionResult, Error>) -> Void,
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
                result(.success(ActionResult(peripheral: peripheral,
                                             data: value,
                                             characteristic: action.characteristic)))
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
