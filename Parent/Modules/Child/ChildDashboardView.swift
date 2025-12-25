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
                HStack(spacing: 4) {
                    Text("Hello,")
                    Text("\(childName)!")
                }
                .font(.custom("Inter-SemiBold", size: 26))
                .foregroundColor(.accent)
                
                Text("Your phone is connected to your family")
                    .font(.custom("Inter-Medium", size: 18))
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
