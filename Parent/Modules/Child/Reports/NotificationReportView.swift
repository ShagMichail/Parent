//
//  NotificationReportView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI
import DeviceActivity

struct NotificationReportView: View {
    let childName: String
    
    private let сontext = DeviceActivityReport.Context("App Notifications Report")
    
    var body: some View {
        DeviceActivityReport(сontext)
        .navigationTitle("Уведомления \(childName)")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
