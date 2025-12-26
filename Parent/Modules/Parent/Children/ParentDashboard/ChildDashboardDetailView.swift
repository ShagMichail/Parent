//
//  ChildDashboardDetailView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI
import DeviceActivity

struct ChildDashboardDetailView: View {
    @EnvironmentObject var viewModel: ParentDashboardViewModel
    
    @Binding var showBlockOverlay: Bool
    
    @State private var navigateToFocus = false
    @State private var navigateToLimits = false
    @State private var navigateToBlocks = false
    @State private var navigateToWebBlocks = false
    @State var showNavigationBar: Bool = true
    @State private var filter = DeviceActivityFilter(
        segment: .hourly(during: DateInterval(start: Calendar.current.startOfDay(for: Date()), end: Date())),
        users: .children,
        devices: .init([.iPhone])
    )
    @State private var context = DeviceActivityReport.Context(rawValue: "App Top Usage")
    
    private var actionColumns: [GridItem] {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 20
        let columnWidth = (screenWidth - spacing * 3) / 2
        return [GridItem(.fixed(columnWidth), spacing: spacing), GridItem(.fixed(columnWidth), spacing: spacing)]
    }
    
    var animation: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            let childStatus = viewModel.getOnlineStatus(for: viewModel.selectedChild?.recordID ?? "")
            let isPingingBinding = Binding<Bool>(
                get: { viewModel.isPinging[viewModel.selectedChild?.recordID ?? "", default: false] },
                set: { _ in }
            )
            InfoCard(
                model: InfoCardModel(
                    title: String(localized: "Location"),
                    icon: "current-location",
                    location: viewModel.getStreetName(for: viewModel.selectedChild?.recordID ?? ""),
                    status: childStatus.text,
                    statusColor: childStatus.color,
                    onRefresh: {
                        viewModel.requestLocationUpdateForSelectedChild()
                    }
                ),
                isPinging: isPingingBinding
            )
            
            ZStack {
                DeviceActivityReport(context, filter: filter)
                    .frame(height: 150)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                Color.white.opacity(0.01).contentShape(Rectangle()).onTapGesture { print("Tap") }
            }
            .onAppear { updateReport() }
            
            // Действия
            Text("Actions")
                .font(.custom("Inter-Medium", size: 16))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: actionColumns, spacing: 16) {
                
                // КНОПКА БЛОКИРОВАТЬ
                if showBlockOverlay {
                    // Оставляем прозрачную дырку, пока карточка "летает" в родителе
                    Rectangle().fill(Color.clear).frame(height: 100)
                } else {
                    ActionCard(model: ActionCardModel(
                        title: String(localized: "Block"),
                        icon: viewModel.isSelectedChildBlocked ? "lock-command" : "unlock-command",
                        status: viewModel.isSelectedChildBlocked ? String(localized: "On.") : String(localized: "Off."),
                        action: {
                            // Просто переключаем флаг родителя
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                showBlockOverlay = true
                            }
                        }
                    ))
                    // СВЯЗЫВАЕМ С РОДИТЕЛЕМ ЧЕРЕЗ NAMESPACE
                    .matchedGeometryEffect(id: "blockCard", in: animation)
                    .disabled(viewModel.isCommandInProgressForSelectedChild)
                    .opacity(viewModel.isCommandInProgressForSelectedChild ? 0.6 : 1.0)
                }
                
                // Кнопка Фокусировать
                ActionCard(model: ActionCardModel(
                    title: String(localized: "Focusing"),
                    icon: "focus-command",
                    status: viewModel.isFocusActiveForSelectedChild ? String(localized: "On.") : String(localized: "Off."),
                    action: {
                        navigateToFocus = true
                        showNavigationBar.toggle()
                    }
                ))
                
                ActionCard(model: ActionCardModel(
                    title: String(localized: "Limits"),
                    icon: "timer-command",
                    showsArrow: true,
                    action: {
                        navigateToLimits = true
                        showNavigationBar.toggle()
                    }
                ))
                
                ActionCard(model: ActionCardModel(
                    title: String(localized: "Applications"),
                    icon: "apps-command",
                    showsArrow: true,
                    action: {
                        navigateToBlocks = true
                        showNavigationBar.toggle()
                    }
                ))
                ActionCard(model: ActionCardModel(
                    title: String(localized: "Websites"),
                    icon: "web-command",
                    showsArrow: true,
                    action: {
                        navigateToWebBlocks = true
                        showNavigationBar.toggle()
                    }
                ))
            }
        }
        .padding(.horizontal, 20)
        .navigationDestination(
            isPresented: $navigateToFocus,
            destination: { FocusSettingsView(showNavigationBar: $showNavigationBar, childID: viewModel.selectedChild?.recordID ?? "") }
        )
        .navigationDestination(
            isPresented: $navigateToLimits,
            destination: { AppLimitsView(showNavigationBar: $showNavigationBar, child: viewModel.selectedChild) }
        )
        .navigationDestination(
            isPresented: $navigateToBlocks,
            destination: { AppBlockView(showNavigationBar: $showNavigationBar, child: viewModel.selectedChild) }
        )
        .navigationDestination(
            isPresented: $navigateToWebBlocks,
            destination: { WebBlockView(showNavigationBar: $showNavigationBar, child: viewModel.selectedChild) }
        )

        .toolbar(showNavigationBar ? .visible : .hidden, for: .tabBar)
    }
    
    private func updateReport() {
        let newFilter = DeviceActivityFilter(
            segment: .hourly(during: DateInterval(start: Calendar.current.startOfDay(for: Date()), end: Date())),
            users: .children,
            devices: .init([.iPhone])
        )
        withAnimation { self.filter = newFilter }
    }
}
