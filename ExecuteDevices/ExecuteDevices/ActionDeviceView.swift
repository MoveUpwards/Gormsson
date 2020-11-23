//
//  ActionDeviceView.swift
//  ExecuteDevices
//
//  Created by Mac on 20/11/2020.
//

import SwiftUI

struct ActionDeviceView: View {
    @StateObject private var viewModel: BluetoothService

    init(viewModel: BluetoothService) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Text(viewModel.values)
    }
}
