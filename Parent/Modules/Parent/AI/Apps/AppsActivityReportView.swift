//
//  AppsActivityReportView.swift
//  Parent
//
//  Created by Michail Shagovitov on 11.12.2025.
//

import SwiftUI
import DeviceActivity

struct AppsActivityReportView: View {
    let childName: String
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPeriod: TimePeriod = .today
    @Environment(\.presentationMode) var presentationMode
    
    @State private var context = DeviceActivityReport.Context(rawValue: "App Usage Activity")
    @State private var filter = DeviceActivityFilter(
        segment: .hourly(during: DateInterval(
            start: Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!,
            end: Date()
        )),
        users: .children,
        devices: .init([.iPhone, .iPad])
    )
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(
                model: NavigationBarModel(
                    chevronBackward: true,
                    subTitle: "Приложения",
                    onBackTap: {
                        dismiss()
                    },
                    onNotificationTap: {},
                    onConfirmTap: {}
                )
            )
            
            CustomSegmentedControl(
                selection: $selectedTab,
                options: ["День", "Неделя"]
            )
            .frame(height: 34)
            .padding(.horizontal, 90)
            .padding(.bottom, 20)
            .padding(.top, 6)
            .background(.roleBackround)
            
            DeviceActivityReport(context, filter: filter)
                .navigationBarBackButtonHidden(true)
                .ignoresSafeArea(edges: .bottom)
        }
        // 5. Следим за изменением вкладки и меняем фильтр
        .onChange(of: selectedTab) { newValue in
            updateFilter(for: newValue)
        }
    }
    
    private func updateFilter(for index: Int) {
        let calendar = Calendar.current
        let now = Date()
        var start: Date
        
        if index == 0 {
            // ДЕНЬ: Начало сегодняшнего дня
            start = calendar.startOfDay(for: now)
        } else {
            // НЕДЕЛЯ: 7 дней назад от текущего момента
            // Важно: используй adding day -7, чтобы захватить неделю
            start = calendar.date(byAdding: .day, value: -7, to: now)!
        }
        
        filter = DeviceActivityFilter(
            segment: .hourly(during: DateInterval(start: start, end: now)),
            users: .children,
            devices: .init([.iPhone, .iPad])
        )
    }
}
