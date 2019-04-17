//
//  GattService.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 04/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth

/// All the base services from: https://www.bluetooth.com/specifications/gatt/services
public enum GattService {
    /// Custom service with your own 128bits UUID
    case custom(String)

    /// Generic Access (0x1800)
    case genericAccess
    /// Alert Notification Service (0x1811)
    case alertNotificationService
    /// Automation IO (0x1815)
    case automationIO
    /// Battery Service (0x180F)
    case batteryService
    /// Blood Pressure (0x1810)
    case bloodPressure
    /// Body Composition (0x181B)
    case bodyComposition
    /// Bond Management Service (0x181E)
    case bondManagementService
    /// Continuous Glucose Monitoring (0x181F)
    case continuousGlucoseMonitoring
    /// Current Time Service (0x1805)
    case currentTimeService
    /// Cycling Power (0x1818)
    case cyclingPower
    /// Cycling Speed and Cadence (0x1816)
    case cyclingSpeedAndCadence
    /// Device Information (0x180A)
    case deviceInformation
    /// Environmental Sensing (0x181A)
    case environmentalSensing
    /// Fitness Machine (0x1826)
    case fitnessMachine
    /// Generic Attribute (0x1801)
    case genericAttribute
    /// Glucose (0x1808)
    case glucose
    /// Health Thermometer (0x1809)
    case healthThermometer
    /// Heart Rate (0x180D)
    case heartRate
    /// HTTP Proxy (0x1823)
    case httpProxy
    /// Human Interface Device (0x1812)
    case humanInterfaceDevice
    /// Immediate Alert (0x1802)
    case immediateAlert
    /// Indoor Positioning (0x1821)
    case indoorPositioning
    /// Insulin Delivery (0x183A)
    case insulinDelivery
    /// Internet Protocol Support Service (0x1820)
    case internetProtocolSupportService
    /// Link Loss (0x1803)
    case linkLoss
    /// Location and Navigation (0x1819)
    case locationAndNavigation
    /// Mesh Provisioning Service (0x1827)
    case meshProvisioningService
    /// Mesh Proxy Service (0x1828)
    case meshProxyService
    /// Next DST Change Service (0x1807)
    case nextDstChangeService
    /// Object Transfer Service (0x1825)
    case objectTransferService
    /// Phone Alert Status Service (0x180E)
    case phoneAlertStatusService
    /// Pulse Oximeter Service (0x1822)
    case pulseOximeterService
    /// Reconnection Configuration (0x1829)
    case reconnectionConfiguration
    /// Reference Time Update Service (0x1806)
    case referenceTimeUpdateService
    /// Running Speed and Cadence (0x1814)
    case runningSpeedAndCadence
    /// Scan Parameters (0x1813)
    case scanParameters
    /// Transport Discovery (0x1824)
    case transportDiscovery
    /// Tx Power (0x1804)
    case txPower
    /// User Data (0x181C)
    case userData
    /// Weight Scale (0x181D)
    case weightScale

    /// Comparaison between GattService and CBService
    public static func == (lhs: GattService, rhs: CBService) -> Bool {
        return lhs.uuidString == rhs.uuid.uuidString
    }

    /// A 128-bit UUID that identifies the service.
    public var uuid: CBUUID {
        switch self {
        case let .custom(arg):
            return CBUUID(string: arg)
        default:
            return CBUUID(string: uuidString)
        }
    }

    /// A string representation of the UUID.
    public var uuidString: String {
        switch self {
        case let .custom(arg):
            return arg
        case .genericAccess:
            return "1800"
        case .alertNotificationService:
            return "1811"
        case .automationIO:
            return "1815"
        case .batteryService:
            return "180F"
        case .bloodPressure:
            return "1810"
        case .bodyComposition:
            return "181B"
        case .bondManagementService:
            return "181E"
        case .continuousGlucoseMonitoring:
            return "181F"
        case .currentTimeService:
            return "1805"
        case .cyclingPower:
            return "1818"
        case .cyclingSpeedAndCadence:
            return "1816"
        case .deviceInformation:
            return "180A"
        case .environmentalSensing:
            return "181A"
        case .fitnessMachine:
            return "1826"
        case .genericAttribute:
            return "1801"
        case .glucose:
            return "1808"
        case .healthThermometer:
            return "1809"
        case .heartRate:
            return "180D"
        case .httpProxy:
            return "1823"
        case .humanInterfaceDevice:
            return "1812"
        case .immediateAlert:
            return "1802"
        case .indoorPositioning:
            return "1821"
        case .insulinDelivery:
            return "183A"
        case .internetProtocolSupportService:
            return "1820"
        case .linkLoss:
            return "1803"
        case .locationAndNavigation:
            return "1819"
        case .meshProvisioningService:
            return "1827"
        case .meshProxyService:
            return "1828"
        case .nextDstChangeService:
            return "1807"
        case .objectTransferService:
            return "1825"
        case .phoneAlertStatusService:
            return "180E"
        case .pulseOximeterService:
            return "1822"
        case .reconnectionConfiguration:
            return "1829"
        case .referenceTimeUpdateService:
            return "1806"
        case .runningSpeedAndCadence:
            return "1814"
        case .scanParameters:
            return "1813"
        case .transportDiscovery:
            return "1824"
        case .txPower:
            return "1804"
        case .userData:
            return "181C"
        case .weightScale:
            return "181D"
        }
    }
}
