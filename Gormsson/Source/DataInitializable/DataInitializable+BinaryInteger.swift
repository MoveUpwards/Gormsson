//
//  DataInitializable+BinaryInteger.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 15/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension BinaryInteger where Self: DataInitializable {
    /// Initialize the object from octets' array.
    public init(with data: [UInt8]) {
        var returnValue = Self(0)
        for (index, element) in data.enumerated() {
            returnValue += Self(element) << (8 * index)
        }
        self = returnValue
    }
}

extension UInt: DataInitializable { }
extension UInt8: DataInitializable { }
extension UInt16: DataInitializable { }
extension UInt32: DataInitializable { }
extension UInt64: DataInitializable { }

extension Int: DataInitializable { }
extension Int8: DataInitializable { }
extension Int16: DataInitializable { }
extension Int32: DataInitializable { }
extension Int64: DataInitializable { }
