//
//  GattCharacteristic.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 04/04/2019.
//  Copyright © 2019 Damien Noël Dubuisson. All rights reserved.
//

import CoreBluetooth
import Nevanlinna

/// Gormsson protocol for a characteristic.
public protocol CharacteristicProtocol {
    /// A 128-bit UUID that identifies the characteristic.
    var uuid: CBUUID { get }
    /// The service that this characteristic belongs to.
    var service: GattService { get }
    /// The value's format of the characteristic.
    var format: DataInitializable.Type { get }
}

/// All the base characteristics from: https://www.bluetooth.com/specifications/gatt/characteristics
public enum GattCharacteristic {
//    case aerobicHeartRateLowerLimit
//    case aerobicHeartRateUpperLimit
//    case aerobicThreshold
//    case age
//    case aggregate
//    case alertCategoryID
//    case alertCategoryIDBitMask
//    case alertLevel
//    case alertNotificationControlPoint
//    case alertStatus
//    case altitude
//    case anaerobicHeartRateLowerLimit
//    case anaerobicHeartRateUpperLimit
//    case anaerobicThreshold
//    case analog
//    case analogOutput
//    case apparentWindDirection
//    case apparentWindSpeed
//    case appearance
//    case barometricPressureTrend
    /// Battery Level (0x2A19)
    case batteryLevel
//    case batteryLevelState
//    case batteryPowerState
//    case bloodPressureFeature
//    case bloodPressureMeasurement
//    case bodyCompositionFeature
//    case bodyCompositionMeasurement
    /// Body Sensor Location (0x2A38)
    case bodySensorLocation
//    case bondManagementControlPoint
//    case bondManagementFeatures
//    case bootKeyboardInputReport
//    case bootKeyboardOutputReport
//    case bootMouseInputReport
//    case centralAddressResolution
//    case cgmFeature
//    case cgmMeasurement
//    case cgmSessionRunTime
//    case cgmSessionStartTime
//    case cgmSpecificOpsControlPoint
//    case cgmStatus
//    case clientSupportedFeatures
//    case crossTrainerData
//    case cscFeature
//    case cscMeasurement
//    case currentTime
//    case cyclingPowerControlPoint
//    case cyclingPowerFeature
//    case cyclingPowerMeasurement
//    case cyclingPowerVector
//    case databaseChangeIncrement
//    case databaseHash
//    case dateofBirth
//    case dateofThresholdAssessment
//    case dateTime
//    case dateUTC
//    case dayDateTime
//    case dayofWeek
//    case descriptorValueChanged
    /// Device Name (0x2A00)
    @available(swift, obsoleted: 1.0, message: """
    Use: Gormsson.current.name
    see - https://lists.apple.com/archives/bluetooth-dev/2016/Feb/msg00018.html
    """)
    case deviceName
//    case dewPoint
//    case digital
//    case digitalOutput
//    case dstOffset
//    case elevation
//    case emailAddress
//    case exactTime100
//    case exactTime256
//    case fatBurnHeartRateLowerLimit
//    case fatBurnHeartRateUpperLimit
    /// Firmware Revision String (0x2A26)
    case firmwareRevisionString
//    case firstName
//    case fitnessMachineControlPoint
//    case fitnessMachineFeature
//    case fitnessMachineStatus
//    case fiveZoneHeartRateLimits
//    case floorNumber
//    case gender
//    case glucoseFeature
//    case glucoseMeasurement
//    case glucoseMeasurementContext
//    case gustFactor
    /// Hardware Revision String (0x2A27)
    case hardwareRevisionString
//    case heartRateControlPoint
//    case heartRateMax
    /// Heart Rate Measurement (0x2A37)
    case heartRateMeasurement
//    case heatIndex
//    case height
//    case hidControlPoint
//    case hidInformation
//    case hipCircumference
//    case httpControlPoint
//    case httpEntityBody
//    case httpHeaders
//    case httpStatusCode
//    case httpSSecurity
//    case humidity
//    case iddAnnunciationStatus
//    case iddCommandControlPoint
//    case iddCommandData
//    case iddFeatures
//    case iddHistoryData
//    case iddRecordAccessControlPoint
//    case iddStatus
//    case iddStatusChanged
//    case iddStatusReaderControlPoint
//    case ieee11073_20601RegulatoryCertificationDataList
//    case indoorBikeData
//    case indoorPositioningConfiguration
//    case intermediateCuffPressure
//    case intermediateTemperature
//    case irradiance
//    case language
//    case lastName
//    case latitude
//    case lnControlPoint
//    case lnFeature
//    case localEastCoordinate
//    case localNorthCoordinate
//    case localTimeInformation
//    case locationandSpeedCharacteristic
//    case locationName
//    case longitude
//    case magneticDeclination
//    case magneticFluxDensity_2D
//    case magneticFluxDensity_3D
    /// Manufacturer Name String (0x2A29)
    case manufacturerNameString
//    case maximumRecommendedHeartRate
//    case measurementInterval
    /// Model Number String (0x2A24)
    case modelNumberString
//    case navigation
//    case networkAvailability
//    case newAlert
//    case objectActionControlPoint
//    case objectChanged
//    case objectFirst_Created
//    case objectID
//    case objectLast_Modified
//    case objectListControlPoint
//    case objectListFilter
//    case objectName
//    case objectProperties
//    case objectSize
//    case objectType
//    case otsFeature
//    case peripheralPreferredConnectionParameters
//    case peripheralPrivacyFlag
//    case plxContinuousMeasurementCharacteristic
//    case plxFeatures
//    case plxSpot_CheckMeasurement
//    case pnpID
//    case pollenConcentration
//    case position2D
//    case position3D
//    case positionQuality
//    case pressure
//    case protocolMode
//    case pulseOximetryControlPoint
//    case rainfall
//    case rcFeature
//    case rcSettings
//    case reconnectionAddress
//    case reconnectionConfigurationControlPoint
//    case recordAccessControlPoint
//    case referenceTimeInformation
//    case removable
//    case report
//    case reportMap
//    case resolvablePrivateAddressOnly
//    case restingHeartRate
//    case ringerControlpoint
//    case ringerSetting
//    case rowerData
//    case rscFeature
//    case rscMeasurement
//    case scControlPoint
//    case scanIntervalWindow
//    case scanRefresh
//    case scientificTemperatureCelsius
//    case secondaryTimeZone
//    case sensorLocation
    /// Serial Number String (0x2A25)
    case serialNumberString
//    case serviceChanged
//    case serviceRequired
    /// Software Revision String (0x2A28)
    case softwareRevisionString
//    case sportTypeforAerobicandAnaerobicThresholds
//    case stairClimberData
//    case stepClimberData
//    case string
//    case supportedHeartRateRange
//    case supportedInclinationRange
//    case supportedNewAlertCategory
//    case supportedPowerRange
//    case supportedResistanceLevelRange
//    case supportedSpeedRange
//    case supportedUnreadAlertCategory
//    case systemID
//    case tdsControlPoint
//    case temperature
//    case temperatureCelsius
//    case temperatureFahrenheit
    /// Temperature Measurement String (0x2A1C)
    case temperatureMeasurement
//    case temperatureType
//    case threeZoneHeartRateLimits
//    case timeAccuracy
//    case timeBroadcast
//    case timeSource
//    case timeUpdateControlPoint
//    case timeUpdateState
//    case timeWithDST
//    case timeZone
//    case trainingStatus
//    case treadmillData
//    case trueWindDirection
//    case trueWindSpeed
//    case twoZoneHeartRateLimit
    case txPowerLevel
//    case uncertainty
//    case unreadAlertStatus
//    case uri
//    case userControlPoint
//    case userIndex
//    case uvIndex
//    case vo2Max
//    case waistCircumference
//    case weight
//    case weightMeasurement
//    case weightScaleFeature
//    case windChill

    /// CharacteristicProtocol from the enum.
    internal var characteristic: CharacteristicProtocol {
        switch self {
//        case let .custom(arg):
//            return arg
//        case .aerobicHeartRateLowerLimit:
//            return ""
//        case .aerobicHeartRateUpperLimit:
//            return ""
//        case .aerobicThreshold:
//            return ""
//        case .age:
//            return ""
//        case .aggregate:
//            return ""
//        case .alertCategoryID:
//            return ""
//        case .alertCategoryIDBitMask:
//            return ""
//        case .alertLevel:
//            return ""
//        case .alertNotificationControlPoint:
//            return ""
//        case .alertStatus:
//            return ""
//        case .altitude:
//            return ""
//        case .anaerobicHeartRateLowerLimit:
//            return ""
//        case .anaerobicHeartRateUpperLimit:
//            return ""
//        case .anaerobicThreshold:
//            return ""
//        case .analog:
//            return ""
//        case .analogOutput:
//            return ""
//        case .apparentWindDirection:
//            return ""
//        case .apparentWindSpeed:
//            return ""
//        case .appearance:
//            return ""
//        case .barometricPressureTrend:
//            return ""
        case .batteryLevel:
            return BatteryLevel()
//        case .batteryLevelState:
//            return ""
//        case .batteryPowerState:
//            return ""
//        case .bloodPressureFeature:
//            return ""
//        case .bloodPressureMeasurement:
//            return ""
//        case .bodyCompositionFeature:
//            return ""
//        case .bodyCompositionMeasurement:
//            return ""
        case .bodySensorLocation:
            return BodySensorLocation()
//        case .bondManagementControlPoint:
//            return ""
//        case .bondManagementFeatures:
//            return ""
//        case .bootKeyboardInputReport:
//            return ""
//        case .bootKeyboardOutputReport:
//            return ""
//        case .bootMouseInputReport:
//            return ""
//        case .centralAddressResolution:
//            return ""
//        case .cgmFeature:
//            return ""
//        case .cgmMeasurement:
//            return ""
//        case .cgmSessionRunTime:
//            return ""
//        case .cgmSessionStartTime:
//            return ""
//        case .cgmSpecificOpsControlPoint:
//            return ""
//        case .cgmStatus:
//            return ""
//        case .clientSupportedFeatures:
//            return ""
//        case .crossTrainerData:
//            return ""
//        case .cscFeature:
//            return ""
//        case .cscMeasurement:
//            return ""
//        case .currentTime:
//            return ""
//        case .cyclingPowerControlPoint:
//            return ""
//        case .cyclingPowerFeature:
//            return ""
//        case .cyclingPowerMeasurement:
//            return ""
//        case .cyclingPowerVector:
//            return ""
//        case .databaseChangeIncrement:
//            return ""
//        case .databaseHash:
//            return ""
//        case .dateofBirth:
//            return ""
//        case .dateofThresholdAssessment:
//            return ""
//        case .dateTime:
//            return ""
//        case .dateUTC:
//            return ""
//        case .dayDateTime:
//            return ""
//        case .dayofWeek:
//            return ""
//        case .descriptorValueChanged:
//            return ""
        case .deviceName:
            return DeviceName()
//        case .dewPoint:
//            return ""
//        case .digital:
//            return ""
//        case .digitalOutput:
//            return ""
//        case .dstOffset:
//            return ""
//        case .elevation:
//            return ""
//        case .emailAddress:
//            return ""
//        case .exactTime100:
//            return ""
//        case .exactTime256:
//            return ""
//        case .fatBurnHeartRateLowerLimit:
//            return ""
//        case .fatBurnHeartRateUpperLimit:
//            return ""
        case .firmwareRevisionString:
            return FirmwareRevisionString()
//        case .firstName:
//            return ""
//        case .fitnessMachineControlPoint:
//            return ""
//        case .fitnessMachineFeature:
//            return ""
//        case .fitnessMachineStatus:
//            return ""
//        case .fiveZoneHeartRateLimits:
//            return ""
//        case .floorNumber:
//            return ""
//        case .gender:
//            return ""
//        case .glucoseFeature:
//            return ""
//        case .glucoseMeasurement:
//            return ""
//        case .glucoseMeasurementContext:
//            return ""
//        case .gustFactor:
//            return ""
        case .hardwareRevisionString:
            return HardwareRevisionString()
//        case .heartRateControlPoint:
//            return HeartRateControlPoint()
//        case .heartRateMax:
//            return ""
        case .heartRateMeasurement:
            return HeartRateMeasurement()
//        case .heatIndex:
//            return ""
//        case .height:
//            return ""
//        case .hidControlPoint:
//            return ""
//        case .hidInformation:
//            return ""
//        case .hipCircumference:
//            return ""
//        case .httpControlPoint:
//            return ""
//        case .httpEntityBody:
//            return ""
//        case .httpHeaders:
//            return ""
//        case .httpStatusCode:
//            return ""
//        case .httpSSecurity:
//            return ""
//        case .humidity:
//            return ""
//        case .iddAnnunciationStatus:
//            return ""
//        case .iddCommandControlPoint:
//            return ""
//        case .iddCommandData:
//            return ""
//        case .iddFeatures:
//            return ""
//        case .iddHistoryData:
//            return ""
//        case .iddRecordAccessControlPoint:
//            return ""
//        case .iddStatus:
//            return ""
//        case .iddStatusChanged:
//            return ""
//        case .iddStatusReaderControlPoint:
//            return ""
//        case .ieee11073_20601RegulatoryCertificationDataList:
//            return ""
//        case .indoorBikeData:
//            return ""
//        case .indoorPositioningConfiguration:
//            return ""
//        case .intermediateCuffPressure:
//            return ""
//        case .intermediateTemperature:
//            return ""
//        case .irradiance:
//            return ""
//        case .language:
//            return ""
//        case .lastName:
//            return ""
//        case .latitude:
//            return ""
//        case .lnControlPoint:
//            return ""
//        case .lnFeature:
//            return ""
//        case .localEastCoordinate:
//            return ""
//        case .localNorthCoordinate:
//            return ""
//        case .localTimeInformation:
//            return ""
//        case .locationandSpeedCharacteristic:
//            return ""
//        case .locationName:
//            return ""
//        case .longitude:
//            return ""
//        case .magneticDeclination:
//            return ""
//        case .magneticFluxDensity_2D:
//            return ""
//        case .magneticFluxDensity_3D:
//            return ""
        case .manufacturerNameString:
            return ManufacturerNameString()
//        case .maximumRecommendedHeartRate:
//            return ""
//        case .measurementInterval:
//            return ""
        case .modelNumberString:
            return ModelNumberString()
//        case .navigation:
//            return ""
//        case .networkAvailability:
//            return ""
//        case .newAlert:
//            return ""
//        case .objectActionControlPoint:
//            return ""
//        case .objectChanged:
//            return ""
//        case .objectFirst_Created:
//            return ""
//        case .objectID:
//            return ""
//        case .objectLast_Modified:
//            return ""
//        case .objectListControlPoint:
//            return ""
//        case .objectListFilter:
//            return ""
//        case .objectName:
//            return ""
//        case .objectProperties:
//            return ""
//        case .objectSize:
//            return ""
//        case .objectType:
//            return ""
//        case .otsFeature:
//            return ""
//        case .peripheralPreferredConnectionParameters:
//            return ""
//        case .peripheralPrivacyFlag:
//            return ""
//        case .plxContinuousMeasurementCharacteristic:
//            return ""
//        case .plxFeatures:
//            return ""
//        case .plxSpot_CheckMeasurement:
//            return ""
//        case .pnpID:
//            return ""
//        case .pollenConcentration:
//            return ""
//        case .position2D:
//            return ""
//        case .position3D:
//            return ""
//        case .positionQuality:
//            return ""
//        case .pressure:
//            return ""
//        case .protocolMode:
//            return ""
//        case .pulseOximetryControlPoint:
//            return ""
//        case .rainfall:
//            return ""
//        case .rcFeature:
//            return ""
//        case .rcSettings:
//            return ""
//        case .reconnectionAddress:
//            return ""
//        case .reconnectionConfigurationControlPoint:
//            return ""
//        case .recordAccessControlPoint:
//            return ""
//        case .referenceTimeInformation:
//            return ""
//        case .removable:
//            return ""
//        case .report:
//            return ""
//        case .reportMap:
//            return ""
//        case .resolvablePrivateAddressOnly:
//            return ""
//        case .restingHeartRate:
//            return ""
//        case .ringerControlpoint:
//            return ""
//        case .ringerSetting:
//            return ""
//        case .rowerData:
//            return ""
//        case .rscFeature:
//            return ""
//        case .rscMeasurement:
//            return ""
//        case .scControlPoint:
//            return ""
//        case .scanIntervalWindow:
//            return ""
//        case .scanRefresh:
//            return ""
//        case .scientificTemperatureCelsius:
//            return ""
//        case .secondaryTimeZone:
//            return ""
//        case .sensorLocation:
//            return ""
        case .serialNumberString:
            return SerialNumberString()
//        case .serviceChanged:
//            return ""
//        case .serviceRequired:
//            return ""
        case .softwareRevisionString:
            return SoftwareRevisionString()
//        case .sportTypeforAerobicandAnaerobicThresholds:
//            return ""
//        case .stairClimberData:
//            return ""
//        case .stepClimberData:
//            return ""
//        case .string:
//            return ""
//        case .supportedHeartRateRange:
//            return ""
//        case .supportedInclinationRange:
//            return ""
//        case .supportedNewAlertCategory:
//            return ""
//        case .supportedPowerRange:
//            return ""
//        case .supportedResistanceLevelRange:
//            return ""
//        case .supportedSpeedRange:
//            return ""
//        case .supportedUnreadAlertCategory:
//            return ""
//        case .systemID:
//            return ""
//        case .tdsControlPoint:
//            return ""
//        case .temperature:
//            return ""
//        case .temperatureCelsius:
//            return ""
//        case .temperatureFahrenheit:
//            return ""
        case .temperatureMeasurement:
            return TemperatureMeasurement()
//        case .temperatureType:
//            return ""
//        case .threeZoneHeartRateLimits:
//            return ""
//        case .timeAccuracy:
//            return ""
//        case .timeBroadcast:
//            return ""
//        case .timeSource:
//            return ""
//        case .timeUpdateControlPoint:
//            return ""
//        case .timeUpdateState:
//            return ""
//        case .timeWithDST:
//            return ""
//        case .timeZone:
//            return ""
//        case .trainingStatus:
//            return ""
//        case .treadmillData:
//            return ""
//        case .trueWindDirection:
//            return ""
//        case .trueWindSpeed:
//            return ""
//        case .twoZoneHeartRateLimit:
//            return ""
        case .txPowerLevel:
            return TxPowerLevel()
//        case .uncertainty:
//            return ""
//        case .unreadAlertStatus:
//            return ""
//        case .uri:
//            return ""
//        case .userControlPoint:
//            return ""
//        case .userIndex:
//            return ""
//        case .uvIndex:
//            return ""
//        case .vo2Max:
//            return ""
//        case .waistCircumference:
//            return ""
//        case .weight:
//            return ""
//        case .weightMeasurement:
//            return ""
//        case .weightScaleFeature:
//            return ""
//        case .windChill:
//            return ""
        }
    }
} //swiftlint:disable:this file_length
