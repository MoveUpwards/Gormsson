//
//  DetailViewController.swift
//  GormssonDemo
//
//  Created by Damien Noël Dubuisson on 04/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import UIKit
import Gormsson

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    public var manager: Gormsson?

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        manager?.disconnect()
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @IBAction func readBatteryLevel(_ sender: Any) {
        manager?.read(.batteryLevel, success: { (value: UInt8?) in
            guard let batteryLevel = value else { return }
            print("batteryLevel:", batteryLevel)
        })
    }

    @IBAction func readStrings(_ sender: Any) {
        manager?.read(.manufacturerNameString, success: { (value: String?) in
            guard let manufacturerNameString = value else { return }
            print("manufacturerNameString:", manufacturerNameString)
        })
    }

    @IBAction func freeMemory(_ sender: Any) {
        manager?.read(GPSFreeMemory(), success: { (value: UInt?) in
            print("GPSFreeMemory", value ?? "nil")
        })
    }

    @IBAction func gpsStatusStartNotify(_ sender: Any) {
        manager?.notify(GPSStatus(), success: { (value: UInt8?) in
            print("GPSStatus", value ?? "nil")
        })
    }

    @IBAction func gpsSessionCount(_ sender: Any) {
        manager?.read(GPSSessionCount(), success: { (value: UInt?) in
            print("GPSSessionCount read:", value ?? "nil")
        })
        manager?.notify(GPSSessionCount(), success: { (value: UInt?) in
            print("GPSSessionCount notify:", value ?? "nil")
        })
    }

    @IBAction func gpsStatusStopNotify(_ sender: Any) {
        manager?.stopNotify(GPSStatus())
    }

    @IBAction func gpsControlWriteStart(_ sender: Any) {
        manager?.write(GPSControl(), value: UInt8(1), success: { (value: UInt8?) in
            print("GPSControl", value ?? "nil")
        })
    }

    @IBAction func gpsControlWriteStop(_ sender: Any) {
        manager?.write(GPSControl(), value: UInt8(0), success: { (value: UInt8?) in
            print("GPSControl", value ?? "nil")
        })
    }
}
