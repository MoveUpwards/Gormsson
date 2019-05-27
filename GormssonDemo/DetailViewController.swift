//
//  DetailViewController.swift
//  GormssonDemo
//
//  Created by Damien Noël Dubuisson on 04/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import UIKit
import Gormsson
import Nevanlinna

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
        manager?.read(.batteryLevel, result: { (result: Result<DataInitializable, Error>) in
            switch result {
            case .success(let value):
                print("batteryLevel:", value as? UInt8 ?? "nil")
            case .failure(let error):
                print("batteryLevel error:", error)
            }
        })
    }

    @IBAction private func readStrings(_ sender: Any) {
        manager?.read(.manufacturerNameString, result: { (result: Result<DataInitializable, Error>) in
            switch result {
            case .success(let value):
                print("manufacturerNameString:", value as? String ?? "nil")
            case .failure(let error):
                print("manufacturerNameString error:", error)
            }
        })
    }

    @IBAction private func freeMemory(_ sender: Any) {
        manager?.read(GPSFreeMemory(), result: { (result: Result<DataInitializable, Error>) in
            switch result {
            case .success(let value):
                print("GPSFreeMemory:", value as? UInt ?? "nil")
            case .failure(let error):
                print("GPSFreeMemory error:", error)
            }
        })
    }

    @IBAction private func gpsStatusStartNotify(_ sender: Any) {
        manager?.read(GPSStatus(), result: { (result: Result<DataInitializable, Error>) in
            switch result {
            case .success(let value):
                print("GPSStatus:", value as? UInt ?? "nil")
            case .failure(let error):
                print("GPSStatus error:", error)
            }
        })
    }

    @IBAction private func gpsStatusStopNotify(_ sender: Any) {
        manager?.stopNotify(GPSStatus())
    }

    @IBAction private func gpsSessionCount(_ sender: Any) {
        manager?.read(GPSSessionCount(), result: { (result: Result<DataInitializable, Error>) in
            switch result {
            case .success(let value):
                print("GPSSessionCount:", value as? UInt ?? "nil")
            case .failure(let error):
                print("GPSSessionCount error:", error)
            }
        })
    }

    @IBAction private func gpsControlWriteStart(_ sender: Any) {
        manager?.write(GPSControl(), value: GPSControlEnum.start, result: { (result: Result<DataInitializable, Error>) in
            switch result {
            case .success(let value):
                print("GPSControl start:", value as? GPSControlEnum ?? "nil")
            case .failure(let error):
                print("GPSControl start error:", error)
            }
        })
    }

    @IBAction private func gpsControlWriteStop(_ sender: Any) {
        manager?.write(GPSControl(), value: GPSControlEnum.stop, result: { (result: Result<DataInitializable, Error>) in
            switch result {
            case .success(let value):
                print("GPSControl stop:", value as? GPSControlEnum ?? "nil")
            case .failure(let error):
                print("GPSControl stop error:", error)
            }
        })
    }
}
