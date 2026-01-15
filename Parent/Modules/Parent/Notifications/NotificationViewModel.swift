//
//  NotificationViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 14.01.2026.
//

import SwiftUI
import Combine
import CloudKit

struct PendingNotification: Identifiable {
    let id = UUID()
    let childId: String
    let childName: String
    let title: String
    let message: String
    let date: Date
    let commandName: String?
}

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var selectedChild: Child? {
        didSet {
            if let child = selectedChild {
                Task {
                    await loadNotifications(for: child)
                }
            }
        }
    }
    @Published var notifications: [ChildNotification] = []
    @Published var isLoading = false
    @Published var unreadCount = 0
    
    // Новая переменная для отслеживания новых уведомлений выбранного ребенка
    @Published var hasNewNotificationForSelectedChild: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var stateManager: AppStateManager
    private var cloudKitManager: CloudKitManager
    
    @Published var pendingNotifications: [PendingNotification] = []
    
    init(stateManager: AppStateManager, cloudKitManager: CloudKitManager) {
        self.stateManager = stateManager
        self.cloudKitManager = cloudKitManager
        
        stateManager.$children
            .sink { [weak self] updatedChildren in
                self?.children = updatedChildren
                if self?.selectedChild == nil {
                    self?.selectedChild = updatedChildren.first
                }
            }
            .store(in: &cancellables)
        
        // Подписываемся на изменения уведомлений для обновления флага
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Обновляем уведомления при получении пуша
        NotificationCenter.default.publisher(for: NSNotification.Name("ParentNotificationReceived"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                // Вызываем новую функцию-обработчик с данными из пуша
                self?.handleIncomingNotification(from: notification.userInfo)
            }
            .store(in: &cancellables)
        
        // Отслеживаем изменения выбранного ребенка
        $selectedChild
            .sink { [weak self] child in
                guard let self = self else { return }
                Task {
                    self.updateHasNewNotificationFlag()
                }
            }
            .store(in: &cancellables)
        
        // Отслеживаем изменения списка уведомлений
        $notifications
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task {
                    
                    self.updateHasNewNotificationFlag()
                }
            }
            .store(in: &cancellables)
        
        // Инициализируем подписку CloudKit
        Task {
            try? await cloudKitManager.subscribeToParentNotifications()
        }
    }
    
    private func handleIncomingNotification(from userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo,
              let recordID = userInfo["recordID"] as? String,
              let childId = userInfo["childId"] as? String,
              let date = userInfo["date"] as? Date else {
            return
        }
        
        let commandName = userInfo["commandName"] as? String
        let commandStatus = userInfo["commandStatus"] as? String
        
        if notifications.contains(where: { $0.recordID == recordID }) { return }
        
        let childName = children.first(where: { $0.recordID == childId })?.name ?? "Ребенок"
        
        let (title, message, notificationType) = generateNotificationContent(commandName: commandName, childName: childName)
        
        let newNotification = ChildNotification(
            childId: childId,
            childName: childName,
            type: notificationType,
            title: title,
            message: message,
            date: date,
            isRead: false,
            commandName: commandName,
            commandStatus: commandStatus,
            recordID: recordID
        )
        
        notifications.insert(newNotification, at: 0)
        
        unreadCount = notifications.filter { !$0.isRead }.count
        updateHasNewNotificationFlag()
        
        print("✅ ViewModel обновлена данными из Push. Запрос в CloudKit не требуется.")
    }
    
    private func generateNotificationContent(commandName: String?, childName: String) -> (title: String, message: String, notificationType: ChildNotification.NotificationType) {
        let title: String
        let message: String
        let notificationType: ChildNotification.NotificationType
        
        switch commandName {
        case "block_all":
            notificationType = ChildNotification.NotificationType.blockAll
            title = "Устройство заблокировано"
            message = "Заблокировали устройство \(childName)"
        case "unblock_all":
            notificationType = ChildNotification.NotificationType.unblockAll
            title = "Устройство разблокировано"
            message = "Разблокировали устройство \(childName)"
        case "request_location_update":
            notificationType = ChildNotification.NotificationType.locationUpdated
            title = "Локация обновлена"
            message = "\(childName) отправил(а) текущее местоположение"
        case "update-schedule":
            notificationType = ChildNotification.NotificationType.scheduleUpdated
            title = "Обновили расписание"
            message = "Обновили/добавили расписание для \(childName)"
        case "delete-schedule":
            notificationType = ChildNotification.NotificationType.scheduleDelete
            title = "Удалили расписание"
            message = "Удалили расписание для \(childName)"
        case "web-block-update":
            notificationType = ChildNotification.NotificationType.webBlockUpdate
            title = "Обновили ограничения"
            message = "Обновили ограничения по WEB-доменам для \(childName)"
        case "app-block-update":
            notificationType = ChildNotification.NotificationType.appBlockUpdate
            title = "Обновили ограничения"
            message = "Обновили ограничения по использованию приложений для \(childName)"
        case "limits-app-update":
            notificationType = ChildNotification.NotificationType.limitsAppUpdate
            title = "Обновили ограничения"
            message = "Обновили лимиты по использованию приложений для \(childName)"
        default:
            notificationType = ChildNotification.NotificationType.commandExecuted
            title = "Команда выполнена"
            message = "\(childName) выполнил(а) команду: \(commandName)"
        }
        
        return (title, message, notificationType)
    }
    
    func loadAllNotifications() async {
        await MainActor.run { isLoading = true }
        
        do {
            let allNotifications = try await cloudKitManager.fetchParentNotifications()
            
            await MainActor.run {
                self.notifications = allNotifications
                self.unreadCount = allNotifications.filter { !$0.isRead }.count
                self.isLoading = false
                self.updateHasNewNotificationFlag()
            }
        } catch {
            print("❌ Ошибка загрузки уведомлений: \(error)")
            await MainActor.run {
                isLoading = false
                updateHasNewNotificationFlag()
            }
        }
    }
    
    func loadNotifications(for child: Child) async {
        await MainActor.run { isLoading = true }
        
        do {
            let allNotifications = try await cloudKitManager.fetchParentNotifications()
            let childNotifications = allNotifications.filter { $0.childId == child.recordID }
            
            await MainActor.run {
                self.notifications = childNotifications
                self.isLoading = false
                self.updateHasNewNotificationFlag()
            }
        } catch {
            print("❌ Ошибка загрузки уведомлений: \(error)")
            await MainActor.run {
                isLoading = false
                updateHasNewNotificationFlag()
            }
        }
    }
    
    func markAsRead(_ notification: ChildNotification) async {
        guard let recordIDString = notification.recordID else { return }
        let recordID = CKRecord.ID(recordName: recordIDString)
        
        do {
            // Обновляем локально
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                await MainActor.run {
                    var updated = notifications[index]
                    updated.isRead = true
                    notifications[index] = updated
                    unreadCount = notifications.filter { !$0.isRead }.count
                    updateHasNewNotificationFlag() // Обновляем флаг после отметки как прочитанное
                }
            }
            
            // Пробуем обновить в CloudKit
            try await cloudKitManager.markNotificationAsRead(recordID: recordID)
            
        } catch {
            print("❌ Ошибка отметки как прочитанное: \(error)")
            // Не обновляем флаг в случае ошибки, т.к. локально уже обновили
        }
    }
    
    func deleteNotification(_ notification: ChildNotification) async {
        guard let recordIDString = notification.recordID else { return }
        let recordID = CKRecord.ID(recordName: recordIDString)
        
        do {
            try await cloudKitManager.deleteNotification(recordID: recordID)
            
            // Удаляем локально
            await MainActor.run {
                notifications.removeAll { $0.id == notification.id }
                unreadCount = notifications.filter { !$0.isRead }.count
                updateHasNewNotificationFlag() // Обновляем флаг после удаления
            }
        } catch {
            print("❌ Ошибка удаления уведомления: \(error)")
        }
    }
    
    func deleteAllNotifications() async {
        let recordsToDelete = notifications.compactMap { $0.recordID }
        
        for recordIDString in recordsToDelete {
            let recordID = CKRecord.ID(recordName: recordIDString)
            try? await cloudKitManager.deleteNotification(recordID: recordID)
        }
        
        await MainActor.run {
            notifications.removeAll()
            unreadCount = 0
            updateHasNewNotificationFlag() // Обновляем флаг после полной очистки
        }
    }
    
    func refresh() {
        Task {
            if let child = selectedChild {
                await loadNotifications(for: child)
            } else {
                await loadAllNotifications()
            }
        }
    }
    
    // Вспомогательный метод для получения количества непрочитанных уведомлений для конкретного ребенка
    func unreadCountForChild(_ child: Child) -> Int {
        return notifications.filter {
            $0.childId == child.recordID && !$0.isRead
        }.count
    }
    
    // Вспомогательный метод для проверки наличия новых уведомлений для конкретного ребенка
    func hasNewNotificationsForChild(_ child: Child) -> Bool {
        return unreadCountForChild(child) > 0
    }
    
    func addPendingNotification(
        childId: String,
        childName: String,
        title: String,
        message: String,
        commandName: String? = nil
    ) {
        let pending = PendingNotification(
            childId: childId,
            childName: childName,
            title: title,
            message: message,
            date: Date(),
            commandName: commandName
        )
        
        pendingNotifications.append(pending)
        updateHasNewNotificationFlag()
        
        print("✅ Добавлено pending уведомление: \(title)")
    }
    
    func clearPendingNotifications() {
        pendingNotifications.removeAll()
        updateHasNewNotificationFlag()
    }

    private func updateHasNewNotificationFlag() {
        guard let selectedChild = selectedChild else {
            hasNewNotificationForSelectedChild = false
            return
        }
        
        // Проверяем как реальные, так и pending уведомления
        let hasRealUnread = notifications.contains {
            $0.childId == selectedChild.recordID && !$0.isRead
        }
        
        let hasPending = pendingNotifications.contains {
            $0.childId == selectedChild.recordID
        }
        
        hasNewNotificationForSelectedChild = hasRealUnread || hasPending
    }
}
