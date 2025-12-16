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
    @State private var navigateToFocus = false
    
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
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
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
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
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
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(.blackText)
                                
                                ZStack {
                                    DeviceActivityReport(context, filter: filter)
                                        .frame(height: 230)
                                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
                                    
                                    Color.white.opacity(0.001)
                                        .contentShape(Rectangle())
                                }
                                .id(reportId)
                            }
                            .padding(.horizontal, 20)

                            VStack(spacing: 0) {
                                NavigationLinkRow(title: "Используемые приложения")  {
                                    navigateToFocus = true
                                }
                                Divider().padding(.horizontal, 10)
                                NavigationLinkRow(title: "Посещаемые сайты")  {
                                    navigateToFocus = true
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
            }
            .navigationBarHidden(true)
            .background(Color.roleBackround.ignoresSafeArea())
            .background(
                NavigationLink(
                    destination: AppsActivityReportView(),
                    isActive: $navigateToFocus
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

//import SwiftUI
//import DeviceActivity
//import FamilyControls
//
//struct AISummaryView: View {
//    @EnvironmentObject var viewModel: ParentDashboardViewModel
//    @State private var selectedCategory: ActionCategory = .communication
//    @State private var activitySelection = FamilyActivitySelection()
//    @State private var context = DeviceActivityReport.Context(rawValue: "Hourly Activity Chart")
//    @State private var filter = DeviceActivityFilter(
//        segment: .hourly(during: DateInterval(
//            start: Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!,
//            end: Date()
//        )),
//        users: .children,
//        devices: .init([.iPhone, .iPad])
//    )
//    
//    @State private var reportId = UUID()
//    @State private var reportRefreshID = UUID()
//    @State private var navigateToFocus = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                NavigationBar(
//                    model: NavigationBarModel(
//                        mainTitle: "AI-сводка",
//                        hasNotification: true,
//                        hasNewNotification: true,
//                        onBackTap: {},
//                        onNotificationTap: {},
//                        onConfirmTap: {}
//                    )
//                )
//                
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 0) {
//                        ChildSelectorView(
//                            children: $viewModel.children,
//                            selectedChild: $viewModel.selectedChild,
//                            showBatteryLevel: false,
//                            canChildAdd: false,
//                            onAddChild: {
//                            }
//                        )
//                        .padding(.bottom, 10)
//                        
//                        if let selectedChild = viewModel.selectedChild {
//                            // Весь ваш контент для выбранного ребенка
//                            content(for: selectedChild)
//                                .transition(.opacity.animation(.easeInOut))
//                        } else {
//                            // Заглушка, если детей нет или никто не выбран
//                            NoChildSelectedView()
//                                .padding(.top, 50)
//                        }
//                    }
//                    .padding(.bottom, 20)
//                }
//                .scrollIndicators(.hidden)
//            }
//            .navigationBarHidden(true)
//            .background(Color.roleBackround.ignoresSafeArea())
//            .background(
//                NavigationLink(
//                    destination: AppsActivityReportView(),
//                    isActive: $navigateToFocus
//                ) { EmptyView() }.hidden()
//            )
//        }
//        .onChange(of: viewModel.selectedChild) { _, newChild in
//            // При смене ребенка обновляем и selection, и фильтр
//            updateActivitySelection(for: newChild)
//        }
//        .onAppear {
//            // При первом появлении экрана делаем то же самое
//            updateActivitySelection(for: viewModel.selectedChild)
//        }
//    }
//    
//    @ViewBuilder
//    private func content(for child: Child) -> some View {
//        HStack {
//            Spacer()
//            HStack(spacing: 10) {
//                Text("Сегодня")
//                    .font(.system(size: 16, weight: .semibold, design: .rounded))
//                    .foregroundColor(.accent)
//                Image(systemName: "chevron.down")
//                    .resizable()
//                    .frame(width: 16, height: 10)
//                    .foregroundStyle(.accent)
//            }
//        }
//        .padding(.bottom, 16)
//        .padding(.horizontal, 20)
//        
//        VStack(alignment: .leading, spacing: 16) {
//            VStack(alignment: .leading) {
//                Text("Общий анализ")
//                    .font(.system(size: 20, weight: .semibold, design: .rounded))
//                    .foregroundColor(.blackText)
//                
//                AiSummaryCard()
//            }
//            .padding(.horizontal, 20)
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 10) {
//                    ForEach(ActionCategory.allCases) { category in
//                        ActionTag(
//                            text: category.rawValue,
//                            startColor: category.startColor,
//                            endColor: category.endColor,
//                            icon: category.icon,
//                            isSelected: selectedCategory == category,
//                            onTap: {
//                                withAnimation(.spring()) {
//                                    selectedCategory = category
//                                }
//                            }
//                        )
//                        .padding(.vertical, 6)
//                    }
//                }
//                .padding(.horizontal, 20)
//            }
//            
//            ActionDetailsCard(category: selectedCategory)
//            
//                .id(selectedCategory)
//                .transition(.opacity.combined(with: .move(edge: .leading)))
//                .padding(.horizontal, 20)
//            
//            VStack(alignment: .leading, spacing: 10) {
//                Text("Экранное время")
//                    .font(.system(size: 20, weight: .semibold, design: .rounded))
//                    .foregroundColor(.blackText)
//                
//                ZStack {
//                    DeviceActivityReport(context, filter: filter)
//                        .frame(height: 230)
//                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
//                    
//                    Color.white.opacity(0.001)
//                        .contentShape(Rectangle())
//                }
//                .id(reportId)
//            }
//            .padding(.horizontal, 20)
//            
//            VStack(spacing: 0) {
//                NavigationLinkRow(title: "Используемые приложения")  {
//                    navigateToFocus = true
//                }
//                Divider().padding(.horizontal, 10)
//                NavigationLinkRow(title: "Посещаемые сайты")  {
//                    navigateToFocus = true
//                }
//            }
//            .background(
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color.white)
//            )
//            .padding(.horizontal, 20)
//            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
//        }
//    }
//    
//    // ✅ ШАГ 4: Главная функция обновления
//    private func updateActivitySelection(for child: Child?) {
//        Task {
//            if let child = child, let member = await findFamilyMember(for: child) {
//                // Если ребенок выбран, настраиваем selection на него
//                var newSelection = FamilyActivitySelection()
//                newSelection.include(member)
//                
//                // Создаем новый фильтр, который использует ТОЛЬКО токены этого ребенка
//                let newFilter = DeviceActivityFilter(
//                    segment: .daily(during: DateInterval(
//                        start: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
//                        end: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
//                    )),
//                    users: .individual(newSelection.applicationTokens.union(newSelection.webDomainTokens))
//                )
//                
//                // Обновляем состояние
//                self.activitySelection = newSelection
//                self.filter = newFilter
//                
//            } else {
//                // Если ребенок не выбран (nil), создаем пустой selection
//                self.activitySelection = FamilyActivitySelection()
//                // И фильтр, который ничего не покажет
//                self.filter = DeviceActivityFilter(users: .individual([]))
//            }
//        }
//    }
//    
//    // Вспомогательная функция для поиска FamilyActivityPicker
//    private func findFamilyMember(for child: Child) async -> FamilyActivityPicker.Selection.Member? {
//        do {
//            let picker = FamilyActivityPicker(selection: activitySelection)
//            // Ждем, пока система предоставит список членов семьи
//            let members = try await picker.members()
//            // Ищем члена семьи, чей recordID совпадает с ID нашего ребенка
//            return members.first { $0.id.recordID?.recordName == child.id }
//        } catch {
//            print("Ошибка получения членов семьи: \(error)")
//            return nil
//        }
//    }
//    
//    private func updateReport() {
//        print("🔄 AI Summary: Обновляем график для ребенка \(viewModel.selectedChild?.name ?? "nil")")
//        let newFilter = DeviceActivityFilter(
//            segment: .hourly(during: DateInterval(
//                start: Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!,
//                end: Date()
//            )),
//            users: .children,
//            devices: .init([.iPhone, .iPad])
//        )
//        
//        withAnimation {
//            self.filter = newFilter
//            self.reportId = UUID()
//        }
//    }
//}
//
//struct NoChildSelectedView: View {
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: "person.2.slash")
//                .font(.system(size: 60))
//                .foregroundColor(.gray.opacity(0.5))
//            Text("Ребенок не выбран")
//                .font(.title2.bold())
//            Text("Пожалуйста, выберите ребенка вверху, чтобы увидеть его активность.")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 40)
//        }
//        .frame(maxWidth: .infinity)
//    }
//}
