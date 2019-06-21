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
import CoreBluetooth

class DetailViewController: UIViewController {

    @IBOutlet private var detailDescriptionLabel: UILabel!
    @IBOutlet private var buttons: [UIButton]!

    public var manager: Gormsson?
    public var peripheral: CBPeripheral?

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
        manager?.read(.batteryLevel) { result in
            switch result {
            case .success(let value):
                print("batteryLevel:", value as? UInt8 ?? "nil")
            case .failure(let error):
                print("batteryLevel error:", error)
            }
        }
    }

    @IBAction private func readStrings(_ sender: Any) {
        manager?.read(.manufacturerNameString) { result in
            switch result {
            case .success(let value):
                print("manufacturerNameString:", value as? String ?? "nil")
            case .failure(let error):
                print("manufacturerNameString error:", error)
            }
        }
    }

    @IBAction private func freeMemory(_ sender: Any) {
        manager?.read(GPSFreeMemory()) { result in
            switch result {
            case .success(let value):
                print("GPSFreeMemory:", value as? UInt ?? "nil")
            case .failure(let error):
                print("GPSFreeMemory error:", error)
            }
        }
    }

    @IBAction private func gpsStatusStartNotify(_ sender: Any) {
        manager?.read(GPSStatus()) { result in
            switch result {
            case .success(let value):
                print("GPSStatus:", value as? UInt ?? "nil")
            case .failure(let error):
                print("GPSStatus error:", error)
            }
        }
    }

    @IBAction private func gpsStatusStopNotify(_ sender: Any) {
        manager?.stopNotify(GPSStatus())
    }

    @IBAction private func gpsSessionCount(_ sender: Any) {
        manager?.read(GPSSessionCount()) { result in
            switch result {
            case .success(let value):
                print("GPSSessionCount:", value as? UInt ?? "nil")
            case .failure(let error):
                print("GPSSessionCount error:", error)
            }
        }
    }

    @IBAction private func gpsControlWriteStart(_ sender: Any) {
        manager?.write(GPSControl(), value: GPSControlEnum.start) { result in
            switch result {
            case .success(let value):
                print("GPSControl start:", value as? GPSControlEnum ?? "nil")
            case .failure(let error):
                print("GPSControl start error:", error)
            }
        }
    }

    @IBAction private func gpsControlWriteStop(_ sender: Any) {
        manager?.write(GPSControl(), value: GPSControlEnum.stop) { result in
            switch result {
            case .success(let value):
                print("GPSControl stop:", value as? GPSControlEnum ?? "nil")
            case .failure(let error):
                print("GPSControl stop error:", error)
            }
        }
    }

    @IBAction private func gpsControlCustomWrite(_ sender: Any) {
        let cmd: [UInt8] = [0xFB, 0xFA, 0xF1, 0xFB, UInt8.random(in: 0..<255)]
        manager?.write(GPSArrayData(), value: GPSArrayType(with: cmd)) { result in
            switch result {
            case .success(let value):
                print("GPSControl custom:", value as? Int ?? "nil")
            case .failure(let error):
                print("GPSControl custom error:", error)
            }
        }
    }
    
    
    @IBAction func connetPeripheral(_ sender: Any) {
        guard let identifier = peripheral?.identifier else {
            return
        }
        manager?.connect(identifier, success: { cbPeripheral in
            print("connect success: ", cbPeripheral.name ?? "nil")
        })
    }
    
    
    @IBAction func disconnectPeripheral(_ sender: Any) {
        manager?.disconnect()
        print("disconnect Peripheral")
    }
}
