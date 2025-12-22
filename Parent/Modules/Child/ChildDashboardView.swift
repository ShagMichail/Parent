//
//  ChildDashboardView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

struct ChildDashboardView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var stateManager: AppStateManager
    
    @State private var childName: String = "пользователь"
    
    private let childNameStorageKey = "com.laborato.child.name"
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            VStack(spacing: 15) {
                Text("Привет, \(childName)!")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundColor(.accent)
                
                Text("Твой телефон подключен к семье")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.accent)
                
            }
            Spacer()
            Image("child_home")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Spacer()
        }
        
        .onAppear {
            loadChildName()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestPermission()
                }
                locationManager.startTracking()
            }
            // убрать в дальнейшем
            stateManager.didCompletePairing()
        }
    }
    
    private func loadChildName() {
        if let savedName = UserDefaults.standard.string(forKey: childNameStorageKey) {
            self.childName = savedName
            print("👤 Имя ребенка '\(savedName)' успешно загружено.")
        } else {
            print("⚠️ Имя ребенка не найдено в UserDefaults.")
        }
    }
}
