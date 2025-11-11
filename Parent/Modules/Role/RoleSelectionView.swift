//
//  RoleSelectionView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI

struct RoleSelectionView: View {
    @EnvironmentObject var familyManager: FamilyManager
    @State private var selectedRole: MemberType? = nil
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Родительский контроль")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                Button("Войти как родитель") {
                    selectedRole = .parent
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Войти как ребенок") {
                    selectedRole = .child
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, 40)
            
            Text("Для работы требуется Apple ID и подключение к iCloud")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .sheet(item: $selectedRole) { role in
            NameInputView(selectedRole: role)
        }
    }
}
