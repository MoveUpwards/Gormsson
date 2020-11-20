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

final class ListDevicesViewModel: ObservableObject {
    @Published var devices: [CBPeripheral] = []

    let bleService: BluetoothService

    init(with bleService: BluetoothService) {
        self.bleService = bleService
    }

    func startScan() {
        bleService.manager.scan([.custom("0BD51666-E7CB-469B-8E4D-2742AAAA0100")]) { [weak self] result in
            switch result {
            case .failure(let error):
                print("Scan error:", error)
            case .success(let device):
                DispatchQueue.main.async { [weak self] in
                    self?.devices.insert(device.peripheral, at: 0)
                }
            }
        }
    }
}

struct ListDevicesView: View {
    @StateObject private var viewModel: ListDevicesViewModel

    init(viewModel: ListDevicesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.devices) { device in
            Text(device.name ?? "NO NAME")
        }
        .navigationBarTitle("\(viewModel.devices.count) devices", displayMode: .inline)
        .navigationBarItems(trailing: menu)
        .onAppear(perform: {
            viewModel.startScan()
        })
    }

    private var menu: some View {
        Menu {
            Section(header: Text("Edition zone")) {
                Button(action: {
//                    currentSheet = .edit
//                    showSheet.toggle()
                }) {
                    Label("Read battery", systemImage: "pencil")
                }

                Button(action: {
//                    currentSheet = .wifi
//                    showSheet.toggle()
                }) {
                    Label("Write start command", systemImage: "wifi")
                }

                Button(action: {
                    //currentSheet = .wifi
                    //showSheet.toggle()
                }) {
                    Label("Write stop command", systemImage: "wifi")
                }
            }
        }
        label: { Label("", systemImage: "gearshape") }
    }
}

extension CBPeripheral: Identifiable {} // To use CBPeripheral in ForEach
