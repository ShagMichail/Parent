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
    @State private var selectedPeriod: TimePeriod = .today
    @State private var refreshID = UUID()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        DeviceActivityReport(
            DeviceActivityReport.Context(rawValue: "App Notifications Report"),
            filter: DeviceActivityFilter(
                segment: selectedPeriod.deviceActivitySegment,
                users: .children,
                devices: .init([.iPhone])
            )
        )
        
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                }
            }
             
            ToolbarItem(placement: .principal) {
                PeriodSelectorToolbar(
                    selectedPeriod: $selectedPeriod,
                    childName: childName,
                    modelButtons: PeriodToolbarButtonModel(selectedBackgroundColor: .orange, unselectedBackgroundColor: .gray.opacity(0.1), selectedTextColor: .white, unselectedTextColor: .primary, selectedIconColor: .white, unselectedIconColor: .orange, selectedBorderColor: .orange, unselectedBorderColor: .gray.opacity(0.3))
                )
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    refreshID = UUID()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }
        }
        .id(refreshID)
    }
}
