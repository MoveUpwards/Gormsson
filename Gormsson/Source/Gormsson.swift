//
//  Gormsson.swift
//  Gormsson
//
//  Created by Loïc GRIFFIE on 29/03/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import CoreBluetooth
import RxSwift
import RxBluetoothKit

public protocol GormssonDelegate: class {
    func didConnect(manager: Gormsson, to peripheral: Peripheral)
    func didDisconnect(manager: Gormsson, from peripheral: Peripheral)
}

public final class Gormsson {
    // MARK: - Private variables

    private var bag = DisposeBag()
    private var dispose: Disposable?
    private var manager: CentralManager?
    private var restoredDevice: Peripheral?

    // MARK: - Public variables

    /// The delegate called when an action is triggered
    public weak var delegate: GormssonDelegate?

    /// The current connected peripheral
    public var current: Peripheral?

    /// The current state of bluetooth mixed with the connected device
    public var state = BehaviorSubject<BluetoothState>(value: .unknown)

    /// List custom peripheral services
    public var services: [CBUUID]?

    // MARK: - Public functions

    /// Start observe BLE state
    public func start() {
        guard let manager = manager else { return }

        manager.observeState()
            .startWith(manager.state)
            .filter({ $0 == .poweredOn })
            .asObservable()
            .subscribe(onNext: { [weak self] state in
                self?.state.onNext(state)
            }).disposed(by: bag)
    }

    /// Scan peripheral
    public func scan(_ success: @escaping (ScannedPeripheral) -> Void) {
        manager?.scanForPeripherals(withServices: services)
            .subscribe(onNext: { peripheral in
                success(peripheral)
            }).disposed(by: bag)
    }

    /// Disconnect the current connected device
    public func disconnect() {
        if let peripheral = current {
            delegate?.didDisconnect(manager: self, from: peripheral)
        }
        dispose?.dispose()
        current = nil
    }

    // MARK: - Life cycle functions

    /// Initialize a new instance
    public init() {
        let options = [CBCentralManagerOptionRestoreIdentifierKey: "RestoreIdentifierKey"] as [String: AnyObject]
        manager = CentralManager(queue: .main,
                                 options: options,
                                 onWillRestoreCentralManagerState: { [weak self] restoredState in
                                    self?.restoredDevice = restoredState.peripherals.first
        })

        start()
    }

    /// Clean up
    deinit {
        disconnect()
    }
}
