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
        manager?.read(.batteryLevel, success: { value in
            guard let batteryLevel = value as? UInt8 else { return }
            print("batteryLevel:", batteryLevel)
        }, error: { error in
            print("batteryLevel error:", error ?? "nil")
        })
    }

    @IBAction func readStrings(_ sender: Any) {
        manager?.read(.manufacturerNameString, success: { value in
            guard let manufacturerNameString = value as? String else { return }
            print("manufacturerNameString:", manufacturerNameString)
        }, error: { error in
            print("manufacturerNameString error:", error ?? "nil")
        })
    }

    @IBAction func freeMemory(_ sender: Any) {
        manager?.read(GPSFreeMemory(), success: { value in
            print("GPSFreeMemory", value as? UInt ?? "nil")
        }, error: { error in
            print("GPSFreeMemory error:", error ?? "nil")
        })
    }

    @IBAction func gpsStatusStartNotify(_ sender: Any) {
        manager?.notify(GPSStatus(), success: { value in
            print("GPSStatus", value as? UInt8 ?? "nil")
        }, error: { error in
            print("GPSStatus error:", error ?? "nil")
        })
    }

    @IBAction func gpsSessionCount(_ sender: Any) {
        manager?.notify(GPSSessionCount(), success: { value in
            print("GPSSessionCount notify:", value as? UInt ?? "nil")
        }, error: { error in
            print("GPSSessionCount error:", error ?? "nil")
        })

        manager?.read(GPSSessionCount(), success: { value in
            print("GPSSessionCount read:", value as? UInt ?? "nil")
        }, error: { error in
            print("GPSSessionCount error:", error ?? "nil")
        })
    }

    @IBAction func gpsStatusStopNotify(_ sender: Any) {
        manager?.stopNotify(GPSStatus())
    }

    @IBAction func gpsControlWriteStart(_ sender: Any) {
        manager?.write(GPSControl(), value: GPSControlEnum.start, success: { value in
            print("GPSControl start success", value as? GPSControlEnum ?? "nil")
        }, error: { error in
            print("GPSControl start:", error ?? "nil")
        })
    }

    @IBAction func gpsControlWriteStop(_ sender: Any) {
        manager?.write(GPSControl(), value: GPSControlEnum.stop, success: { value in
            print("GPSControl stop success", value as? GPSControlEnum ?? "nil")
        }, error: { error in
            print("GPSControl stop:", error ?? "nil")
        })
    }
}
