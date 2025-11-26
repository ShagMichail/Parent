//
//  PickupsReportView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI
import DeviceActivity

struct PickupsReportView: View {
    let childName: String
    
    private let сontext = DeviceActivityReport.Context("App Pickups Report")
    
    var body: some View {
        DeviceActivityReport(сontext)
        .navigationTitle("Поднятия \(childName)")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

