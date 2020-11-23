//
//  BluetoothService.swift
//  ExecuteDevices
//
//  Created by Mac on 20/11/2020.
//

import Foundation
import CoreBluetooth
import Gormsson

final class BluetoothService: ObservableObject {
    let manager = Gormsson(queue: DispatchQueue(label: "com.ble.manager", attributes: .concurrent))

    @Published var devices: [GormssonPeripheral] = []
    @Published var values: String = ""

    func startScan() {
        manager.scan([.custom("0BD51666-E7CB-469B-8E4D-2742AAAA0100")]) { [weak self] result in
            switch result {
            case .failure(let error):
                print("Scan error:", error)
            case .success(let device):
                DispatchQueue.main.async { [weak self] in
                    guard self?.devices.contains(where: { $0.peripheral == device.peripheral }) == false else {
                        print("Already present:\n\(device)")
                        return
                    }
                    self?.devices.insert(device, at: 0)
                }
            }
        }
    }

    func stopScan() {
        manager.stopScan()
    }

    func readSerialNumbers() {
        stopScan()
        values = "Reading..."

        var dico = [String:  String]()
        manager.execute(.serialNumberString, on: devices.map(\.peripheral)) { [weak self] result in
            // Fire for each CBPeripheral
            if case let .success(object) = result,
               let data = object.data as? String,
               let device = self?.devices.first(where: { $0.peripheral == object.peripheral }) {
                dico[device.advertisement.macAddress.string] = data
            }
        } completion: { [weak self] error in
            if let error = error { print(error) }
            var allSucceed = true
            dico.keys.forEach { macAddress in
                if dico[macAddress] != self?.serialNumber(for: macAddress) {
                    allSucceed = false
                }
            }
            self?.values = allSucceed ? "All good" : "ERROR: Found mismatch"
        }
    }

    func startAll() {
        stopScan()
        values = "Starting..."

        var deviceCount = 0
        manager.execute(SessionRecord(),
                        on: devices.map(\.peripheral),
                        action: .write(value: SessionRecordEnum.start),
                        result: { result in
                            deviceCount += 1
                        },
                        completion: { [weak self] error in
                            self?.values = deviceCount == self?.devices.count ? "All started" : "ERROR: Some devices not started"
                        })
    }

    func stopAll() {
        stopScan()
        values = "Stopping..."

        var deviceCount = 0
        manager.execute(SessionRecord(),
                        on: devices.map(\.peripheral),
                        action: .write(value: SessionRecordEnum.stop),
                        result: { result in
                            deviceCount += 1
                        },
                        completion: { [weak self] error in
                            self?.values = deviceCount == self?.devices.count ? "All stoped" : "ERROR: Some devices not stoped"
                        })
    }

    // MARK: - Private functions

    private func serialNumber(for macAddress: String) -> String {
        let firstSerie = "0001"
        switch macAddress {
        case "C8:D1:79:B8:D6:02":
            return firstSerie + "0115"
        case "C0:E8:9B:68:42:5C":
            return firstSerie + "0067"
        case "FD:D1:41:36:CE:D0":
            return firstSerie + "0161"
        case "EF:93:C9:6F:B5:F7":
            return firstSerie + "0144"
        case "D5:CC:60:F4:25:F3":
            return firstSerie + "0177"
        case "D5:7A:89:96:78:49":
            return firstSerie + "0050"
        case "E6:A0:03:D3:E8:E8":
            return firstSerie + "0073"
        case "D6:E8:7F:CB:2D:F0":
            return firstSerie + "0165"
        case "DD:3B:6D:5C:9E:A8":
            return firstSerie + "0111"
        case "E8:2E:7B:49:AA:83":
            return firstSerie + "0053"
        case "FD:18:25:B2:2D:08":
            return firstSerie + "0106"
        case "C9:D3:1B:78:74:78":
            return firstSerie + "0105"
        case "DE:87:FB:B5:99:14":
            return firstSerie + "0080"
        case "F7:8E:8E:12:D6:0F":
            return firstSerie + "0134"
        case "C0:42:36:12:40:2B":
            return firstSerie + "0087"
        case "CA:28:D6:AD:2A:4B":
            return firstSerie + "0145"
        case "FE:7B:1B:18:71:F9":
            return firstSerie + "0026"
        case "D8:37:B4:2E:0D:7F":
            return firstSerie + "0160"
        case "D8:6C:B0:48:22:BC":
            return firstSerie + "0171"
        case "E0:39:DB:F1:38:3D":
            return firstSerie + "0141"
        default:
            print("MISSING", macAddress)
            return "S/N NOT FOUND"
        }
    }
}
