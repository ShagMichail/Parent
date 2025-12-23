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
    
    @State private var state: ViewState = .generatingCode
    @State private var invitationCode: String?
    @State private var errorMessage: String?
    
    enum ViewState {
        case generatingCode, waitingForChild, success(Child)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            switch state {
            case .generatingCode:
                ProgressView("Генерация кода...")
            case .waitingForChild:
                if let code = invitationCode {
                    WaitingForChildView(invitationCode: code)
                }
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
    
    private func generateCodeAndSubscribe() {
        state = .generatingCode
        errorMessage = nil
        
        Task {
            do {
                let code = try await CloudKitManager.shared.createInvitationByParent()
                try await CloudKitManager.shared.subscribeToInvitationAcceptance(invitationCode: code)
                self.invitationCode = code
                self.state = .waitingForChild
            } catch {
                self.errorMessage = error.localizedDescription
                self.state = .generatingCode
            }
        }
    }
    
    private func handleInvitationAccepted(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let childID = userInfo["childUserRecordID"] as? String,
              let childName = userInfo["childName"] as? String,
              let gender = userInfo["childGender"] as? String else {
            return
        }
        
        let newChild = Child(id: UUID(uuidString: childID) ?? UUID(), name: childName, recordID: childID, gender: gender)
        self.state = .success(newChild)
    }
}
