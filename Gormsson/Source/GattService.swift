//
//  GattService.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 04/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth

public enum GattService {
    case custom(String)

    // From: https://www.bluetooth.com/specifications/gatt/services
    case genericAccess
    case alertNotificationService
    case automationIO
    case batteryService
    case bloodPressure
    case bodyComposition
    case bondManagementService
    case continuousGlucoseMonitoring
    case currentTimeService
    case cyclingPower
    case cyclingSpeedAndCadence
    case deviceInformation
    case environmentalSensing
    case fitnessMachine
    case genericAttribute
    case glucose
    case healthThermometer
    case heartRate
    case httpProxy
    case humanInterfaceDevice
    case immediateAlert
    case indoorPositioning
    case insulinDelivery
    case internetProtocolSupportService
    case linkLoss
    case locationAndNavigation
    case meshProvisioningService
    case meshProxyService
    case nextDstChangeService
    case objectTransferService
    case phoneAlertStatusService
    case pulseOximeterService
    case reconnectionConfiguration
    case referenceTimeUpdateService
    case runningSpeedAndCadence
    case scanParameters
    case transportDiscovery
    case txPower
    case userData
    case weightScale

    public static func == (lhs: GattService, rhs: CBService) -> Bool {
        return lhs.uuidString == rhs.uuid.uuidString
    }

    public var uuid: CBUUID {
        switch self {
        case let .custom(arg):
            return CBUUID(string: arg)
        default:
            return CBUUID(string: uuidString)
        }
    }

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
