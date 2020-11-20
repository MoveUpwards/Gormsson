//
//  ContentView.swift
//  ExecuteDevices
//
//  Created by Mac on 20/11/2020.
//

import SwiftUI



struct ContentView: View {
    let bleService = BluetoothService()

    var body: some View {
        NavigationView {
            ListDevicesView(viewModel: ListDevicesViewModel(with: bleService))
            ActionDeviceView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
