//
//  CategoryActivityReportView.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import SwiftUI
import DeviceActivity

struct CategoryActivityReportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 1
    @State private var context = DeviceActivityReport.Context(rawValue: "Category Usage Activity")
    
    @State private var isLoading = true
    
    @State private var filter = DeviceActivityFilter(
        segment: .hourly(during: DateInterval(
            start: Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date()))!,
            end: Date()
        )),
        users: .children,
        devices: .init([.iPhone])
    )
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(
                model: NavigationBarModel(
                    chevronBackward: true,
                    subTitle: String(localized: "Active time"),
                    onBackTap: { dismiss() }
                )
            )
            
            CustomSegmentedControl(selection: $selectedTab, options: [String(localized: "Day"), String(localized: "Week")])
                .frame(height: 34)
                .padding(.horizontal, 90)
                .padding(.vertical, 16)
                .background(.roleBackground)
            
            ZStack {
                ReportLoadingView()
                
                DeviceActivityReport(context, filter: filter)
                    .opacity(isLoading ? 0 : 1)
            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(edges: .bottom)
        }
        .onChange(of: selectedTab) { _, newValue in
            updateFilter(for: newValue)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
    
    private func updateFilter(for index: Int) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        var start: Date
        
        if index == 0 {
            start = calendar.date(byAdding: .day, value: -1, to: startOfDay)!
        } else {
            start = calendar.date(byAdding: .day, value: -6, to: startOfDay)!
        }
        
        filter = DeviceActivityFilter(
            segment: .hourly(during: DateInterval(start: start, end: now)),
            users: .children,
            devices: .init([.iPhone])
        )
    }
}
