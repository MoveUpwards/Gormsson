//
//  Gormsson+Combine.swift
//  
//
//  Created by Damien Noël Dubuisson on 10/03/2021.
//

#if canImport(Combine)
import Combine
import CoreBluetooth

@available(iOS 13.0, *)
extension Gormsson {
    public func connect(_ peripheral: CBPeripheral) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            self?.connect(peripheral, shouldStopScan: false, failure: { _ in
                promise(.failure(GormssonError.deviceDisconnected))
            }, didReady: {
                promise(.success(()))
            })
        }.eraseToAnyPublisher()
    }

    public func disconnect(_ peripheral: CBPeripheral) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            self?.cancel(peripheral)
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
}
#endif
