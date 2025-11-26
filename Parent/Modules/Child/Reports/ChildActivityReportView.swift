//
//  ChildActivityReportView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 24.11.2025.
//

import SwiftUI
import DeviceActivity

struct ChildActivityReportView: View {
    let childName: String
    
    private let сontext = DeviceActivityReport.Context("App Usage")
    
    var body: some View {
        DeviceActivityReport(сontext)
        .navigationTitle("Активность \(childName)")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
