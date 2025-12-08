//
//  LocationSettingsView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 02.12.2025.
//

import SwiftUI

struct LocationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var locationManager = LocationManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Статус отслеживания")) {
                    HStack {
                        Text("Статус")
                        Spacer()
                        Text(locationManager.isTracking ? "Активно" : "Неактивно")
                            .foregroundColor(locationManager.isTracking ? .green : .red)
                    }
                    
                    HStack {
                        Text("Точность")
                        Spacer()
                        Text("Высокая")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Последнее обновление")
                        Spacer()
                        if let location = locationManager.currentLocation {
                            Text(location.timestamp, style: .time)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Нет данных")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Настройки отслеживания")) {
                    Toggle("Фоновое отслеживание", isOn: .constant(true))
                        .disabled(true)
                    
                    Toggle("Значимые изменения", isOn: .constant(true))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Интервал обновления")
                            .font(.headline)
                        
                        Picker("Интервал", selection: .constant(1)) {
                            Text("1 минута").tag(1)
                            Text("5 минут").tag(5)
                            Text("15 минут").tag(15)
                            Text("Только значимые").tag(0)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Разрешения")) {
                    Button("Проверить разрешения") {
                        locationManager.requestPermission()
                    }
                    
                    Button("Открыть настройки") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                Section {
                    Button(locationManager.isTracking ? "Остановить отслеживание" : "Запустить отслеживание") {
                        if locationManager.isTracking {
                            locationManager.stopTracking()
                        } else {
                            locationManager.startTracking()
                        }
                    }
                    .foregroundColor(locationManager.isTracking ? .red : .blue)
                }
            }
            .navigationTitle("Настройки геолокации")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

