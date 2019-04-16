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

    @IBOutlet private var detailDescriptionLabel: UILabel!
    @IBOutlet private var buttons: [UIButton]!

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

        buttons.forEach { button in
            button.setBackgroundImage(image(from: .lightGray), for: .normal)
            button.setBackgroundImage(image(from: .black), for: .highlighted)
        }
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

    // MARK: - Private function

    func image(from color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }

    // MARK: - ## Added for Gormsson

    @IBAction private func readBatteryLevel(_ sender: Any) {
        manager?.read(.batteryLevel, success: { value in
            print("batteryLevel:", value as? UInt8 ?? "nil")
        }, error: { error in
            print("batteryLevel error:", error ?? "nil")
        })
    }

    @IBAction private func readStrings(_ sender: Any) {
        manager?.read(.manufacturerNameString, success: { value in
            print("manufacturerNameString:", value as? String ?? "nil")
        }, error: { error in
            print("manufacturerNameString error:", error ?? "nil")
        })
    }

    @IBAction private func freeMemory(_ sender: Any) {
        manager?.read(GPSFreeMemory(), success: { value in
            print("GPSFreeMemory", value as? UInt ?? "nil")
        }, error: { error in
            print("GPSFreeMemory error:", error ?? "nil")
        })
    }

    @IBAction private func gpsStatusStartNotify(_ sender: Any) {
        manager?.notify(GPSStatus(), success: { value in
            print("GPSStatus", value as? UInt8 ?? "nil")
        }, error: { error in
            print("GPSStatus error:", error ?? "nil")
        })
    }

    @IBAction private func gpsStatusStopNotify(_ sender: Any) {
        manager?.stopNotify(GPSStatus())
    }

    @IBAction private func gpsSessionCount(_ sender: Any) {
        manager?.read(GPSSessionCount(), success: { value in
            print("GPSSessionCount read:", value as? UInt ?? "nil")
        }, error: { error in
            print("GPSSessionCount error:", error ?? "nil")
        })
    }

    @IBAction private func gpsControlWriteStart(_ sender: Any) {
        manager?.write(GPSControl(), value: GPSControlEnum.start, success: { value in
            print("GPSControl start success", value as? GPSControlEnum ?? "nil")
        }, error: { error in
            print("GPSControl start:", error ?? "nil")
        })
    }

    @IBAction private func gpsControlWriteStop(_ sender: Any) {
        manager?.write(GPSControl(), value: GPSControlEnum.stop, success: { value in
            print("GPSControl stop success", value as? GPSControlEnum ?? "nil")
        }, error: { error in
            print("GPSControl stop:", error ?? "nil")
        })
    }
}
