//
//  AISummaryView.swift
//  Parent
//
//  Created by Michail Shagovitov on 10.12.2025.
//

import SwiftUI
import DeviceActivity

struct AISummaryView: View {
    @EnvironmentObject var viewModel: ParentDashboardViewModel
    @State private var selectedCategory: ActionCategory = .communication
    @State private var context = DeviceActivityReport.Context(rawValue: "Hourly Activity Chart")
    @State private var filter = DeviceActivityFilter(
        segment: .hourly(during: DateInterval(
            start: Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!,
            end: Date()
        )),
        users: .children,
        devices: .init([.iPhone, .iPad])
    )
    
    @State private var reportId = UUID()
    @State private var reportRefreshID = UUID()
    @State private var navigateToAppReport = false
    @State private var navigateToWebReport = false
    @State private var navigateToCategoryReport = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavigationBar(
                    model: NavigationBarModel(
                        mainTitle: "AI-сводка",
                        hasNotification: true,
                        hasNewNotification: true,
                        onBackTap: {},
                        onNotificationTap: {},
                        onConfirmTap: {}
                    )
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ChildSelectorView(
                            children: $viewModel.children,
                            selectedChild: $viewModel.selectedChild,
                            showBatteryLevel: false,
                            canChildAdd: false,
                            onAddChild: {
                            }
                        )
                        .padding(.bottom, 10)
                        
                        HStack {
                            Spacer()
                            HStack(spacing: 10) {
                                Text("Сегодня")
                                    .font(.custom("Inter-SemiBold", size: 16))
                                    .foregroundColor(.accent)
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .frame(width: 16, height: 10)
                                    .foregroundStyle(.accent)
                            }
                        }
                        .padding(.bottom, 16)
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("Общий анализ")
                                    .font(.custom("Inter-SemiBold", size: 20))
                                    .foregroundColor(.blackText)
                                
                                AiSummaryCard()
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(ActionCategory.allCases) { category in
                                        ActionTag(
                                            text: category.rawValue,
                                            startColor: category.startColor,
                                            endColor: category.endColor,
                                            icon: category.icon,
                                            isSelected: selectedCategory == category,
                                            onTap: {
                                                withAnimation(.spring()) {
                                                    selectedCategory = category
                                                }
                                            }
                                        )
                                        .padding(.vertical, 6)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            ActionDetailsCard(category: selectedCategory)

                                .id(selectedCategory)
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                                .padding(.horizontal, 20)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Экранное время")
                                    .font(.custom("Inter-SemiBold", size: 20))
                                    .foregroundColor(.blackText)
                                
                                ZStack {
                                    DeviceActivityReport(context, filter: filter)
                                        .frame(height: 230)
                                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                                    
                                    Color.white.opacity(0.001)
                                        .contentShape(Rectangle())
                                }
                                .id(reportId)
                                .onTapGesture {
                                    navigateToCategoryReport = true
                                }
                            }
                            .padding(.horizontal, 20)

                            VStack(spacing: 0) {
                                NavigationLinkRow(title: "Используемые приложения")  {
                                    navigateToAppReport = true
                                }
                                Divider().padding(.horizontal, 10)
                                NavigationLinkRow(title: "Посещаемые сайты")  {
                                    navigateToWebReport = true
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                            )
                            .padding(.horizontal, 20)
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    viewModel.refreshChildStatus()
                    reportRefreshID = UUID()
                    updateReport()
                }
            }
            .navigationBarHidden(true)
            .background(Color.roleBackground.ignoresSafeArea())
            .background(
                NavigationLink(
                    destination: AppsActivityReportView(),
                    isActive: $navigateToAppReport
                ) { EmptyView() }.hidden()
            )
            .background(
                NavigationLink(
                    destination: WebActivityReportView(),
                    isActive: $navigateToWebReport
                ) { EmptyView() }.hidden()
            )
            .background(
                NavigationLink(
                    destination: CategoryActivityReportView(),
                    isActive: $navigateToCategoryReport
                ) { EmptyView() }.hidden()
            )
        }
        .onChange(of: viewModel.selectedChild) { _, _ in
            updateReport()
        }
        .onAppear {
            updateReport()
        }
    }
    
    private func updateReport() {
        print("🔄 AI Summary: Обновляем график для ребенка \(viewModel.selectedChild?.name ?? "nil")")
        let newFilter = DeviceActivityFilter(
            segment: .hourly(during: DateInterval(
                start: Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!,
                end: Date()
            )),
            users: .children,
            devices: .init([.iPhone, .iPad])
        )
        
        withAnimation {
            self.filter = newFilter
            self.reportId = UUID()
        }
    }
}
