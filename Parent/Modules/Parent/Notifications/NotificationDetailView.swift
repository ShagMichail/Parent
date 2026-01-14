//
//  NotificationDetailView.swift
//  Parent
//
//  Created by Michail Shagovitov on 14.01.2026.
//

import SwiftUI
import DeviceActivity

struct NotificationDetailView: View {
    @EnvironmentObject var viewModel: NotificationViewModel
    @State private var showingDeleteAlert = false
    
    var filteredNotifications: [ChildNotification] {
        guard let selectedChild = viewModel.selectedChild else {
            return viewModel.notifications
        }
        return viewModel.notifications.filter { $0.childId == selectedChild.recordID }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Заголовок с кнопкой очистки
                HStack {
                    Text("All")
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.blackText)
                    
                    Spacer()
                    
                    if !filteredNotifications.isEmpty {
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack(spacing: 10) {
                                Image("filter")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(.accent)
                                Text("Filter")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(.accent)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .progressViewStyle(CircularProgressViewStyle())
                } else if filteredNotifications.isEmpty {
                    emptyStateView
                } else {
                    notificationsList
                }
            }
            .padding(.vertical, 16)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("There are no notifications")
                .font(.custom("Inter-Medium", size: 18))
                .foregroundColor(.plusForderground)
            
            Text("Notifications about actions will appear here.")
                .font(.custom("Inter-regular", size: 14))
                .foregroundColor(.plusForderground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
    
    private var notificationsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredNotifications) { notification in
                NotificationCard(notification: notification)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        Task {
                            await viewModel.markAsRead(notification)
                        }
                    }
            }
        }
    }
}
