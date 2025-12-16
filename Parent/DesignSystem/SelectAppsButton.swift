//
//  SelectAppsButton.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI
import FamilyControls

struct SelectAppsButton: View {
    @State private var isPickerPresented = false
    @State private var selection = FamilyActivitySelection()
    
    var body: some View {
        Button {
            isPickerPresented = true
        } label: {
            HStack {
                Image(systemName: "app.badge.xmark.fill")
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text("Блокировка приложений")
                        .font(.headline)
                    Text("Выберите приложения для ограничения")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
//        .onChange(of: selection) { oldSelection, newSelection in
//            familyManager.setBlockedItems(from: newSelection)
//        }
    }
}
