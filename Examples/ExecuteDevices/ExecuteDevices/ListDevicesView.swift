//
//  ListDevicesView.swift
//  ExecuteDevices
//
//  Created by Mac on 20/11/2020.
//

import SwiftUI
import Combine
import CoreBluetooth
import Gormsson

struct ListDevicesView: View {
    @StateObject private var viewModel: BluetoothService

    init(viewModel: BluetoothService) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.devices) { device in
            Text(device.peripheral.name ?? "NO NAME")
        }
        .navigationBarTitle("\(viewModel.devices.count) devices", displayMode: .inline)
        .navigationBarItems(trailing: menu)
        .onAppear(perform: {
            viewModel.startScan()
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 30.0) {
                viewModel.stopScan()
            }
        })
    }

    private var menu: some View {
        Menu {
            Section(header: Text("Edition zone")) {
                Button(action: {
                    viewModel.readSerialNumbers()
                }) {
                    Label("Read battery", systemImage: "pencil")
                }

                Button(action: {
                    viewModel.startAll()
                }) {
                    Label("Write start command", systemImage: "wifi")
                }

                Button(action: {
                    viewModel.stopAll()
                }) {
                    Label("Write stop command", systemImage: "wifi")
                }
            }
        }
        label: { Label("", systemImage: "gearshape") }
    }
}

extension CBPeripheral: Identifiable {} // To use CBPeripheral in List or ForEach
