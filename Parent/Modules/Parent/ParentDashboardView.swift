//
//  ParentDashboardView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI
import FamilyControls
import DeviceActivity

struct ParentDashboardView: View {
    @EnvironmentObject var stateManager: AuthenticationManager
    @EnvironmentObject var cloudKitManager: CloudKitManager
    
    var body: some View {
        NavigationView {
            VStack {
                if stateManager.children.isEmpty {
                    EmptyStateView()
                } else {
                    ChildrenListView()
                }
            }
            .navigationTitle("Мои дети")
            .toolbar {
                if !stateManager.children.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddChildView()) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }
}
