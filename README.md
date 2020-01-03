[![Documentation](https://img.shields.io/badge/Read_the-Docs-67ad5c.svg)](https://moveupwards.github.io/Gormsson/)
[![Language: 5](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS 11+](https://img.shields.io/badge/platform-iOS-blue.svg?style=flat)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/Gormsson.svg)](http://cocoapods.org/pods/Gormsson)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/657d5abcfa48463b873ea71ab1cba32e)](https://www.codacy.com/app/MoveUpwards/Gormsson?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=MoveUpwards/Gormsson&amp;utm_campaign=Badge_Grade)
![Build Status](https://app.bitrise.io/app/070473bfbf02055c.svg?token=iiFAh4rQgxDR4JfqH-TkLg)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/MoveUpwards/Gormsson/blob/master/LICENSE)
[![GitHub contributors](https://img.shields.io/github/contributors/MoveUpwards/Gormsson.svg)](https://github.com/MoveUpwards/Gormsson/graphs/contributors)
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://paypal.me/moveupwards)

# Gormsson

Harald "Bluetooth" Gormsson was a king of Denmark and Norway.

## Requirements

- iOS 9.1+
- Xcode 10.2+

## Installation

### use [CocoaPods](https://cocoapods.org) with Podfile

```swift
pod 'Gormsson'
```

open your favorite terminal, go to your project root path:

```shell
pod install
```

### use [Carthage](https://github.com/Carthage/Carthage) with Cartfile

```shell
github "MoveUpwards/Gormsson"
```

open your favorite terminal, go to your project root path and run:

```shell
carthage update
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but Alamofire does support its use on supported platforms.

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
.package(url: "https://github.com/MoveUpwards/Gormsson.git", from: "0.8.0")
]
```

## Usage

![Hear Rate Monitor Demo](Resources/HeartRateDemo.jpg)

### Start the service

Gormsson init method let you define a specific queue to avoid being on `Main thread`. You can also give an optional `Dictionary` for the `CoreBluetooth` manager.

```swift
let manager = Gormsson(queue: DispatchQueue(label: "com.ble.manager", attributes: .concurrent))
```

### Start scan for peripherals

Every peripheral scanned around are return in the `didDiscover` block along with the advertisement data. Check the documentation to see all `GattAdvertisement` properties available.

In the below example, we filter peripheral that provide the `HeartRate` service.

```swift
manager.scan([.heartRate], didDiscover: { [weak self] cbPeripheral, advertisementData in
    print(cbPeripheral)
    print(advertisementData.localName)
    print(advertisementData.txPowerLevel)
    print(advertisementData.isConnectable)
})
```

You can custom's advertisement datas variables. See [Custom advertisement data](https://github.com/MoveUpwards/Gormsson#custom-advertisement-data).

### Connect peripheral

When you connect a peripheral, the library automaticaly stop scan for near peripherals.

```swift
manager.connect(cbPeripheral)
```

### Read characteristic

Let's say you want to read the `Body Sensor Location` provided by your favorite Heart Rate Monitor sensor, you simply ask the manager to read the `.bodySensorLocation` characteristic that will return a value type of `BodySensorLocationEnum`.

```swift
manager.read(.bodySensorLocation, success: { value in
    guard let location = value as? BodySensorLocationEnum else { return }

    print("\(location.description)")
}, error: { error in
    print(error ?? "Unknown error")
})
```

### Subscribe characteristic updates

If you want to get the current Heart Rate and have all updated value, you use the `Notify` capability of the characteristic. To achieve this it's as simple as a simply read.

Now any time the value change, the block will be triggered.

```swift
manager.notify(.heartRateMeasurement, success: { value in
    guard let rate = (value as? HeartRateMeasurementType)?.heartRateValue else { return }

    print("\(rate)")
}, error: { error in
    print(error ?? "Unknown error")
})
```

### Write characteristic

If you want to write value to a characteristic, it's pretty straight forward. You provide the characteristic to be used and the given value to write and optionaly provide BLE write type. Default is `.withResponse`

```swift
manager.write(.setState, value: UInt8(1), type: .withoutResponse, success: {
    print("set state success")
}, error: { error in
    print("set state failure:", error ?? "nil")
})
```

### Custom service

In order to use custom service, you just need to create a custom `GattService`.

```swift
let gpsService = GattService.custom("C94E7734-F70C-4B96-BB48-F1E3CB95F79E")
```

So you can use this custom service to filter the scan peripheral.

```swift
manager.scan([gpsService], didDiscover: { [weak self] peripheral, advertisementData in

})
```

### Custom characteristic

In order to use custom characteristic class that conforms to `CharateristicProtocol`.

```swift
public protocol CharacteristicProtocol {
    var service: GattService { get }
    var uuid: CBUUID { get }
    var format: DataInitializable.Type { get }
}
```

Here is an example of a custom characteristc that will provide the number of recorded GPS session.

```swift
public final class GPSSessionCount: CharacteristicProtocol {
    public var uuid: CBUUID {
        return CBUUID(string: "C94E0001-F70C-4B96-BB48-F1E3CB95F79E")
    }

    public var service: GattService {
        return gpsService
    }

    public var format: DataInitializable.Type {
        return UInt.self
    }
}
```

Then you can use it with read, notify or write BLE command.

```swift
manager.read(GPSSessionCount(), success: { value in
    print("GPSSessionCount read:", value as? UInt ?? "nil")
}, error: { error in
    print(error ?? "Unknown error")
})
```

### Custom advertisement data

In case your BLE peripheral has custom manufacturer data, you can add extension to the `GattAdvertisement` class.

Let's say you have the peripheral MAC address provided in the manufacturer data.

```swift
extension GattAdvertisement {
    /// An object containing the manufacturer data of a peripheral.
    open var macAddress: String? {
        let gpsService = GattService.custom("C94E7734-F70C-4B96-BB48-F1E3CB95F79E")
        guard let data = serviceData?[gpsService.uuid] else { return nil }
        return [UInt8](data).map({ String(format: "%02hhx", $0).uppercased() })
            .reversed()
            .joined(separator: ":")
    }
}
```

### Documentation

Have a look at the [Documentation](https://moveupwards.github.io/Gormsson/) to check all the functionnalities `Gormsson` library can provide.

## Contributing

Please read our [Contributing Guide](https://raw.githubusercontent.com/MoveUpwards/Gormsson/master/CONTRIBUTING.md) before submitting a Pull Request to the project.

## Support

For more information on the upcoming version, please take a look to our [ROADMAP](https://github.com/MoveUpwards/Gormsson/projects/).

#### Community support

For general help using Strapi, please refer to [the official Gormsson documentation](https://moveupwards.github.io/Gormsson/). For additional help, you can use one of this channel to ask question:

- [StackOverflow](http://stackoverflow.com/questions/tagged/Gormsson)
- [Slack](http://moveupwards.slack.com) (highly recommended for faster support)
- [GitHub](https://github.com/MoveUpwards/Gormsson).

#### Professional support

We provide a full range of solutions to get better and faster results. We're always looking for the next challenge: consulting, training, develop mobile and web solution, etc.

[Drop us an email](mailto:contact@moveupwards.dev) to see how we can help you.

## License

Folding cell is released under the MIT license.
See [LICENSE](https://raw.githubusercontent.com/MoveUpwards/Gormsson/master/LICENSE) for details.

If you use the open-source library in your project, please make sure to credit and backlink to www.moveupwards.dev
