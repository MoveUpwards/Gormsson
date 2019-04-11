//
//  ViewController.swift
//  HeartRateDemo
//
//  Created by Loïc GRIFFIE on 11/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import UIKit
import Gormsson
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet private var heartRate: UILabel!
    @IBOutlet private var sensorLocation: UILabel!

    private let manager = Gormsson(queue: DispatchQueue(label: "com.ble.manager", attributes: .concurrent))

    var observation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.scan([.heartRate], didDiscover: { [weak self] peripheral, _ in
            self?.manager.connect(peripheral)

            self?.manager.read(.bodySensorLocation, success: { (value: BodySensorLocationEnum?) in
                guard let location = value else { return }

                DispatchQueue.main.async {
                    self?.heartRate.text = "\(location.description)"
                }
            })

            self?.manager.notify(.heartRateMeasurement, success: { (value: HeartRateMeasurementType?) in
                guard let rate = value?.heartRateValue else { return }

                DispatchQueue.main.async {
                    self?.heartRate.text = "\(rate)"
                }
            })
        })
    }
}

