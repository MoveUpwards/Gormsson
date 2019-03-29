//
//  Characteristic.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 29/03/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import RxBluetoothKit
import RxSwift
import CoreBluetooth

public class Characteristic<T>: CharacteristicIdentifier {
    private let bag = DisposeBag()
    private let peripheral: Peripheral

    public let service: ServiceIdentifier
    public let uuid: CBUUID
    public let properties: CBCharacteristicProperties

    public init(peripheral: Peripheral,
                service: String,
                uuid: String,
                properties: CBCharacteristicProperties = .read) {
        self.peripheral = peripheral
        self.service = Service(uuid: service)
        self.uuid = CBUUID(string: uuid)
        self.properties = properties
    }

    public func read() -> Single<T> {
        return Single<T>.create { [weak self] single in
            guard let strongSelf = self else {
                return Disposables.create { }
            }

            self?.peripheral.readValue(for: strongSelf)
                .asObservable()
                .subscribe(onNext: {
                    guard let data = ($0.value as? T) else {
                        single(.error(NSError(domain: "No data", code: -1)))
                        return
                    }

                    single(.success(data))
                }).disposed(by: strongSelf.bag)

            return Disposables.create { }
        }
    }
}
