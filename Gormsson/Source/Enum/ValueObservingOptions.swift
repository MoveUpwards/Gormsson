//
//  ValueObservingOptions.swift
//  Gormsson
//
//  Created by Mac on 06/11/2019.
//  Copyright © 2019 Loïc GRIFFIE. All rights reserved.
//

/// As NSKeyValueObservingOptions to observe values
public enum ValueObservingOptions {
    /// To send a notification immediately for the current value
    case initial
    /// To send notification only when the value change
    case distinct
}
