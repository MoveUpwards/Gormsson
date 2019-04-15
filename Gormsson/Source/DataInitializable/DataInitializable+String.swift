//
//  DataInitializable+String.swift
//  Gormsson
//
//  Created by Damien Noël Dubuisson on 15/04/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

import Foundation

extension String: DataInitializable {
    /// Initialize the object from Data
    public init?(with data: Data) {
        guard let value = String(bytes: [UInt8](data), encoding: .utf8) else {
            return nil
        }
        self = value
    }
}
