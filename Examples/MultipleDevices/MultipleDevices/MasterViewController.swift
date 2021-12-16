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
    private let gormsson = Gormsson()

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

        let checkScanForever = true
        if checkScanForever {
            // Scan forever to check when new devices appear or some disappear
            gormsson.scan([.custom("0BD51666-E7CB-469B-8E4D-2742AAAA0100")], delay: 3.0, lifetime: 3.0) { [weak self] result in
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
            gormsson.scan([.custom("0BD51666-E7CB-469B-8E4D-2742AAAA0100")]) { [weak self] result in
                switch result {
                    case .failure(let error):
                        print("Scan error:", error)
                    case .success(let device):
                        self?.objects.insert(device.peripheral, at: 0)
                        let indexPath = IndexPath(row: 0, section: 0)
                        self?.tableView.insertRows(at: [indexPath], with: .automatic)
                }
            } // ## Added for Gormsson
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
            self?.gormsson.cancel(peripheral)
        }
    }

    @objc
    private func playReadBattery(_ sender: Any) {
        let allDevices = true
        if allDevices {
            gormsson.executeAll([.init(.batteryLevel), .init(.serialNumberString)], on: objects, result: { result in
                if case let .success(value) = result {
                    print(value.peripheral.name ?? "--", ":", value.characteristic.service, "=", value.data)
                }
            }, completion: { error in
                print(error ?? "TERMINATED")
            })
        } else {
            guard let device = objects.first else { return }
            gormsson.connect(device, success: {
                print("connected")
            }, failure: { error in
                print("failure")
            }, didReady: { [weak self] in
                print("ready")
                self?.gormsson.cancel(device)
            }, didDisconnect: { result in
                print("disconnected")
            })
        }
    }

    private func observeState() {
        // ## Optional to observe state's changes
        gormsson.observe(options: [.initial, .distinct]) { [weak self] state in
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
