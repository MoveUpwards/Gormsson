//
//  MasterViewController.swift
//  GormssonDemo
//
//  Created by Damien Noël Dubuisson on 04/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import UIKit
import Gormsson
import CoreBluetooth

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [CBPeripheral]()

    private let manager = Gormsson(queue: DispatchQueue(label: "com.ble.manager", attributes: .concurrent))
    private let imuService = GattService.custom("326A9000-85CB-9195-D9DD-464CFBBAE75A")

    var observation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()

        // ### Gormsson ###
        manager.scan([gpsControlService], didDiscover: didDiscover)

        // ### Gormsson ###

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)

        // ### Gormsson ###
        observation = manager.observe(\.state, options: [.initial, .new], changeHandler: { [weak self] manager, change in
            switch manager.state {
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
        })
        // ### Gormsson ###
    }

    deinit {
        observation?.invalidate()
    }

    func didDiscover(_ peripheral: CBPeripheral, _ advertisementData: GattAdvertisement) {
        print("rssi:", advertisementData.rssi)
        print("localName:", advertisementData.localName ?? "nil")
        print("isConnectable:", advertisementData.isConnectable)
        print("mac address:", advertisementData.macAddress ?? "nil")

        DispatchQueue.main.async { [weak self] in
            self?.objects.insert(peripheral, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self?.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    @objc
    func insertNewObject(_ sender: Any) {
//        objects.insert(NSDate(), at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let peripheral = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = peripheral.name
                // ### Gormsson ###
                controller.manager = manager
                manager.connect(peripheral)
                // ### Gormsson ###
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
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
        cell.textLabel!.text = object?.description
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
