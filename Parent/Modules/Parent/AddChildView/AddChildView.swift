//
//  AddChildView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI

struct AddChildView: View {
    @EnvironmentObject var stateManager: AppStateManager
    @Environment(\.dismiss) var dismiss
    
    @State private var state: ViewState = .waitingForChild
    @State private var invitationCode: String?
    @State private var errorMessage: String?
    
    enum ViewState {
        case waitingForChild
        case success(Child)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            switch state {
            case .waitingForChild:
                WaitingForChildView(
                    invitationCode: invitationCode,
                    onUpdateCode: {
                        print("🔄 Обновление кода...")
                        refreshCode()
                    }
                )
            case .success(let child):
                PairingSuccessView(newChild: child)
            }
        }
        .onAppear {
            if invitationCode == nil && errorMessage == nil {
                generateCodeAndSubscribe()
            }
        }

        .onReceive(NotificationCenter.default.publisher(for: .invitationAcceptedByChild)) { notification in
            handleInvitationAccepted(notification: notification)
        }
    }
    
    private func refreshCode() {
        Task {
            if let oldCode = invitationCode {
                self.invitationCode = nil
                await CloudKitManager.shared.deleteInvitation(withCode: oldCode)
            }
            
            generateCodeAndSubscribe()
        }
    }
    
    private func generateCodeAndSubscribe() {
        self.invitationCode = nil
        self.errorMessage = nil
        
        Task {
            do {
                let code = try await CloudKitManager.shared.createInvitationByParent()
                try await CloudKitManager.shared.subscribeToInvitationAcceptance(invitationCode: code)
                
                await MainActor.run {
                    self.invitationCode = code
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleInvitationAccepted(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let childID = userInfo["childUserRecordID"] as? String,
              let childName = userInfo["childName"] as? String,
              let gender = userInfo["childGender"] as? String,
              let childAppleID = userInfo["childAppleID"] as? String,
              let acceptedCode = self.invitationCode else {
            return
        }
        
        Task {
            print("🗑️ Приглашение принято. Удаляем подписку для кода \(acceptedCode)...")
            let subscriptionID = "invitation-accepted-\(acceptedCode)"
            do {
                try await CloudKitManager.shared.publicDatabase.deleteSubscription(withID: subscriptionID)
                print("✅ Подписка на приглашение успешно удалена.")
            } catch {
                print("⚠️ Не удалось удалить подписку на приглашение: \(error)")
            }
        }
        
        let newChild = Child(id: UUID(uuidString: childID) ?? UUID(), name: childName, recordID: childID, gender: gender, childAppleID: childAppleID)
        self.state = .success(newChild)
    }
}

#Preview("Загрузка кода") {
    // --- ПРЕВЬЮ 1: Состояние загрузки кода ---
    AddChildView_PreviewWrapper_no_code(initialState: .waitingForChild)
    .environmentObject(AppStateManager(authService: AuthenticationService(), cloudKitManager: CloudKitManager.shared))
}

#Preview("Код загружен") {
    // --- ПРЕВЬЮ 2: Состояние ожидания ребенка ---
    AddChildView_PreviewWrapper(initialState: .waitingForChild)
    .environmentObject(AppStateManager(authService: AuthenticationService(), cloudKitManager: CloudKitManager.shared))
}

#Preview("Ошибка загрузки кода") {
    // --- ПРЕВЬЮ 2: Состояние ожидания ребенка ---
    AddChildView_PreviewWrapper_error_code(initialState: .waitingForChild)
    .environmentObject(AppStateManager(authService: AuthenticationService(), cloudKitManager: CloudKitManager.shared))
}


#Preview("Соединили устройства") {
    // --- ПРЕВЬЮ 3: Состояние успеха ---
    AddChildView_PreviewWrapper(initialState: .success(
        // Создаем мокового ребенка для превью
        Child(id: UUID(), name: "Анна", recordID: "child_record_123", gender: "women", childAppleID: "qazxswedcvfr")
    ))
    .environmentObject(AppStateManager(authService: AuthenticationService(), cloudKitManager: CloudKitManager.shared))
}

// --- ВСПОМОГАТЕЛЬНАЯ VIEW-ОБЕРТКА ДЛЯ ПРЕВЬЮ ---
struct AddChildView_PreviewWrapper: View {
    @State private var state: AddChildView.ViewState
    @State private var invitationCode: String? = "123456"
    
    init(initialState: AddChildView.ViewState) {
        _state = State(initialValue: initialState)
    }
    
    var body: some View {
        VStack {
            switch state {
            case .waitingForChild:
                WaitingForChildView(
                    invitationCode: invitationCode,
                    onUpdateCode: {
                        print("🔄 Запрос на обновление кода...")
                    }
                )
            case .success(let child):
                PairingSuccessView(newChild: child)
            }
        }
    }
}

struct AddChildView_PreviewWrapper_no_code: View {
    @State private var state: AddChildView.ViewState
    @State private var invitationCode: String? = nil
    
    init(initialState: AddChildView.ViewState) {
        _state = State(initialValue: initialState)
    }
    
    var body: some View {
        VStack {
            switch state {
            case .waitingForChild:
                WaitingForChildView(
                    invitationCode: invitationCode,
                    onUpdateCode: {
                        print("🔄 Запрос на обновление кода...")
                    }
                )
            case .success(let child):
                PairingSuccessView(newChild: child)
            }
        }
    }
}

struct AddChildView_PreviewWrapper_error_code: View {
    @State private var state: AddChildView.ViewState
    @State private var invitationCode: String? = "ERROR"
    
    init(initialState: AddChildView.ViewState) {
        _state = State(initialValue: initialState)
    }
    
    var body: some View {
        VStack {
            switch state {
            case .waitingForChild:
                WaitingForChildView(
                    invitationCode: invitationCode,
                    onUpdateCode: {
                        print("🔄 Запрос на обновление кода...")
                    }
                )
            case .success(let child):
                PairingSuccessView(newChild: child)
            }
        }
    }
}
