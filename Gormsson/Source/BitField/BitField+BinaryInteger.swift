//
//  BitField+BinaryInteger.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 16/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension BinaryInteger {
    public func bool(at index: Int) -> Bool {
        guard index >= 0, index < bitWidth else { return false }

        return self & (1 << index) > 0
    }

    public func value(at index: Int, length: Int) -> Self {
        guard index >= 0, index + length < bitWidth else { return Self(0) }

        var mask = Self(0)
        (index..<index+length).forEach { currIndex in
            mask |= Self(1) << currIndex
        }

        return (self & mask) >> index
    }
}
