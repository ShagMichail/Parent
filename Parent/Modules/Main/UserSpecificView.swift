//
//  UserSpecificView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

struct UserSpecificView: View {
    @EnvironmentObject var familyManager: FamilyManager
    
    var body: some View {
        Group {
            if let currentUser = familyManager.currentUser {
                switch currentUser.type {
                case .parent:
                    ParentDashboardView()
                case .child:
                    Text("hello")
//                    ChildDashboardView(user: currentUser)
                case .unknown:
                    RoleSelectionView() // Если роль неизвестна - возвращаем к выбору
                }
            } else {
                // На всякий случай - если пользователь почему-то nil
                RoleSelectionView()
            }
        }
    }
}
