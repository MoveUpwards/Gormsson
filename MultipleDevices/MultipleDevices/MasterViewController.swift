//
//  MasterViewController.swift
//  MultipleDevices
//
//  Created by Mac on 03/04/2020.
//  Copyright © 2020 vbkam. All rights reserved.
//

import UIKit
import Nevanlinna
import Gormsson
import CoreBluetooth

public final class TBMacAddressType: DataInitializable {
    private let characteristicData: [UInt8]

    /// DataInitializable init.
    required public init(with octets: [UInt8]) {
        characteristicData = octets
    }

    /// The mac address value string representation.
    public var string: String {
        return characteristicData.map({ String(format: "%02hhx", $0).uppercased() })
            .joined(separator: ":")
    }
}

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [CBPeripheral]()

    // ## Added for Gormsson
    private let manager = Gormsson(queue: DispatchQueue(label: "com.ble.manager", attributes: .concurrent))

    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonDisconnect = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(disconnectAllDevices))
        navigationItem.leftBarButtonItem = buttonDisconnect

        let buttonRead = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playReadBattery(_:)))
        navigationItem.rightBarButtonItem = buttonRead

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as? UINavigationController)?.topViewController as? DetailViewController
        }

        observeState()

        let checkScanForever = false
        if checkScanForever {
            // Scan forever to check when new devices appear or some disappear
            manager.scan([.custom("0BD51666-E7CB-469B-8E4D-2742AAAA0100")], delay: 3.0, timeout: 3.0) { [weak self] result in
                switch result {
                case .failure(let error):
                    print("Scan error:", error)
                case .success(let devices):
                    self?.objects = devices.map({ $0.peripheral })
                    self?.tableView.reloadData()
                }
            }
        } else {
            // Scan once and auto connect to founded devices
            manager.scan([.custom("0BD51666-E7CB-469B-8E4D-2742AAAA0100")]) { [weak self] result in
                switch result {
                case .failure(let error):
                    print("Scan error:", error)
                case .success(let device):
                    DispatchQueue.main.async { [weak self] in
                        self?.objects.insert(device.peripheral, at: 0)
                        let indexPath = IndexPath(row: 0, section: 0)
                        if let data = device.advertisement.manufacturerData?[1...6] {
                            print(device.peripheral.identifier, ":", self?.serialNumber(for: TBMacAddressType(with: Array(data)).string))
                        }
                        self?.tableView.insertRows(at: [indexPath], with: .automatic)
                    }
                }
            } // ## Added for Gormsson
        }
    }

    private func serialNumber(for macAddress: String) -> String {
        let firstSerie = "0001-"
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

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Private functions

    @objc
    private func disconnectAllDevices(_ sender: Any) {
        objects.forEach { [weak self] peripheral in
            self?.manager.disconnect(peripheral)
        }
    }

    @objc
    private func playReadBattery(_ sender: Any) {
        let debugReadAll = true
        if debugReadAll {
            print("Will read \(objects.count) objects")
            var dico = [UUID: String]()
            let start = DispatchTime.now()
            manager.execute(.serialNumberString,
                            on: objects, result: { result in
                                // Fire for each CBPeripheral
                                if case let .success(ddd) = result,
                                   let aaa = ddd.data as? String {
                                    dico[ddd.peripheral.identifier] = aaa
                                }
                            },
                            timeout: 30,
                            completion: { error in
                                if let error = error {
                                    print(error)
                                }
                                print(start.distance(to: DispatchTime.now()))
                                print(dico)
                            })
        } else {
        objects.forEach { [weak self] peripheral in
            self?.manager.read(.batteryLevel, on: peripheral) { result in
                print("Battery level:", result, "on", peripheral)
            }
            self?.manager.read(.modelNumberString, on: peripheral) { result in
                print("Device name:", result, "on", peripheral)
            }
        }
        }
    }

    private func observeState() {
        // ## Optional to observe state's changes
        manager.observe(options: [.initial, .distinct]) { [weak self] state in
            switch /*manager.*/state {
            case .unknown:
                print("Gormsson is uninitialized, wait a bit.")
            case .isPoweredOn:
                print("Gromsson is On, everything should be alright.")
            case .needBluetooth:
                print("Gormsson need Bluetooth, please turn it on.")

                let alert = UIAlertController(title: "Import",
                                              message: "You need to turn your bluetooth on to use Gormsson Framework.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
                DispatchQueue.main.async {
                    self?.navigationController?.present(alert, animated: true, completion: nil)
                }
            case .didLostBluetooth:
                print("didLostBluetooth")

                let alert = UIAlertController(title: "Alert",
                                              message: "You lost your bluetooth and Gormsson is reinitialized.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))

                DispatchQueue.main.async {
                    self?.navigationController?.present(alert, animated: true, completion: nil)

                    // Clean all BLE Peripheral as we can't connect anymore
                    self?.objects.removeAll()
                    self?.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let peripheral = objects[indexPath.row]
                let controller = (segue.destination as? UINavigationController)?.topViewController as? DetailViewController
                if peripheral.name == nil {
                    controller?.detailItem = "NO NAME"
                } else {
                    controller?.detailItem = peripheral.name
                }
                controller?.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller?.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row].name
        cell.textLabel?.text = object
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
