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
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @State private var selectedCategory: ActionCategory = .communication
    @State private var context = DeviceActivityReport.Context(rawValue: "Hourly Activity Chart")
    @State private var filter = DeviceActivityFilter(
        segment: .hourly(during: DateInterval(
            start: Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!,
            end: Date()
        )),
        users: .children,
        devices: .init([.iPhone])
    )
    
    @State private var reportId = UUID()
    @State private var reportRefreshID = UUID()
    @State private var navigateToAppReport = false
    @State private var navigateToWebReport = false
    @State private var navigateToCategoryReport = false
    @State private var navigateToNotifications = false
    @State private var showHelp = false
    
    @Binding var isTabBarVisible: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavigationBar(
                    model: NavigationBarModel(
                        mainTitle: String(localized: "AI summary"),
                        hasNotification: true,
                        hasNewNotification: notificationViewModel.hasAnyNewNotification,
                        hasQuestions: true,
                        onNotificationTap: {
                            navigateToNotifications.toggle()
                            isTabBarVisible.toggle()
                        },
                        onQuestionsTap: {
                            showHelp.toggle()
                            isTabBarVisible.toggle()
                        }
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
                                Text("Today")
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
                                Text("General analysis")
                                    .font(.custom("Inter-SemiBold", size: 20))
                                    .foregroundColor(.blackText)
                                
                                AiSummaryCard()
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(ActionCategory.allCases) { category in
                                        ActionTag(
                                            text: category.name,
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
                                Text("Screen time")
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
                                NavigationLinkRow(
                                    model: NavigationLinkRowModel(
                                        title: String(localized: "Applications used"),
                                        action: {
                                            navigateToAppReport = true
                                        }
                                    )
                                )
                                Divider().padding(.horizontal, 10)
                                NavigationLinkRow(
                                    model: NavigationLinkRowModel(
                                        title: String(localized: "Sites visited"),
                                        action: {
                                            navigateToWebReport = true
                                        }
                                    )
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                            )
                            .padding(.horizontal, 20)
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                    }
                    .padding(.bottom, 80)
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
            .navigationDestination(isPresented: $navigateToAppReport, destination: { AppsActivityReportView()})
            .navigationDestination(isPresented: $navigateToWebReport, destination: { WebActivityReportView()})
            .navigationDestination(isPresented: $navigateToCategoryReport, destination: { CategoryActivityReportView()})
            .navigationDestination(
                isPresented: $navigateToNotifications,
                destination: { NotificationView(showNavigationBar: $isTabBarVisible) }
            )
            .navigationDestination(
                isPresented: $showHelp,
                destination: { HelpView(showNavigationBar: $isTabBarVisible) }
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
        if let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") {
            defaults.set(viewModel.selectedChild?.childAppleID, forKey: "myChildAppleID")
        }
        let newFilter = DeviceActivityFilter(
            segment: .hourly(during: DateInterval(
                start: Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!,
                end: Date()
            )),
            users: .children,
            devices: .init([.iPhone])
        )
        
        withAnimation {
            self.filter = newFilter
            self.reportId = UUID()
        }
    }
}
