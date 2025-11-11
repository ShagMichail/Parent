////
////  ChildTimeLimitView.swift
////  Parent
////
////  Created by Михаил Шаговитов on 10.11.2025.
////
//
//import SwiftUI
//
//struct ChildTimeLimitView: View {
//    let child: Child
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var parentManager: ParentControlManager
//    @State private var timeLimit: TimeInterval
//    @State private var customTime = CustomTime(hours: 0, minutes: 0)
//    
//    struct CustomTime {
//        var hours: Int
//        var minutes: Int
//        
//        var totalSeconds: TimeInterval {
//            return TimeInterval(hours * 3600 + minutes * 60)
//        }
//    }
//    
//    let timeOptions: [TimeInterval] = [
//        1800,      // 30 минут
//        3600,      // 1 час
//        7200,      // 2 часа
//        10800,     // 3 часа
//        14400,     // 4 часа
//        18000,     // 5 часов
//        21600,     // 6 часов
//        86400      // 24 часа
//    ]
//    
//    let timeOptionNames = [
//        "30 минут", "1 час", "2 часа", "3 часа",
//        "4 часа", "5 часов", "6 часов", "24 часа"
//    ]
//    
//    init(child: Child) {
//        self.child = child
//        self._timeLimit = State(initialValue: child.timeLimit)
//        let hours = Int(child.timeLimit) / 3600
//        let minutes = (Int(child.timeLimit) % 3600) / 60
//        self._customTime = State(initialValue: CustomTime(hours: hours, minutes: minutes))
//    }
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//                    Text("Лимит времени для \(child.name)")
//                        .font(.headline)
//                    
//                    // Быстрый выбор
//                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
//                        ForEach(Array(timeOptions.enumerated()), id: \.offset) { index, time in
//                            TimeOptionButton(
//                                title: timeOptionNames[index],
//                                isSelected: timeLimit == time
//                            ) {
//                                timeLimit = time
//                                updateCustomTime(from: time)
//                            }
//                        }
//                    }
//                    
//                    Divider()
//                        .padding(.vertical)
//                    
//                    // Кастомное время
//                    Text("Или укажите своё время:")
//                        .font(.headline)
//                    
//                    HStack(spacing: 20) {
//                        VStack {
//                            Text("Часы")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                            Picker("Часы", selection: Binding(
//                                get: { customTime.hours },
//                                set: { newValue in
//                                    customTime.hours = newValue
//                                    timeLimit = customTime.totalSeconds
//                                }
//                            )) {
//                                ForEach(0..<24, id: \.self) { hour in
//                                    Text("\(hour)").tag(hour)
//                                }
//                            }
//                            .pickerStyle(WheelPickerStyle())
//                            .frame(height: 100)
//                        }
//                        
//                        VStack {
//                            Text("Минуты")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                            Picker("Минуты", selection: Binding(
//                                get: { customTime.minutes },
//                                set: { newValue in
//                                    customTime.minutes = newValue
//                                    timeLimit = customTime.totalSeconds
//                                }
//                            )) {
//                                ForEach(0..<60, id: \.self) { minute in
//                                    Text("\(minute)").tag(minute)
//                                }
//                            }
//                            .pickerStyle(WheelPickerStyle())
//                            .frame(height: 100)
//                        }
//                    }
//                    
//                    // Предпросмотр
//                    VStack(spacing: 12) {
//                        Text("Будет установлен лимит:")
//                            .font(.headline)
//                        
//                        Text(formatTime(timeLimit))
//                            .font(.system(size: 28, weight: .bold))
//                            .foregroundColor(.blue)
//                        
//                        Text("Ежедневно")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue.opacity(0.1))
//                    .cornerRadius(12)
//                    .padding(.top)
//                }
//                .padding()
//            }
//            .navigationTitle("Лимит времени")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Отмена") {
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Сохранить") {
//                        saveTimeLimit()
//                    }
//                    .fontWeight(.semibold)
//                }
//            }
//        }
//    }
//    
//    private func updateCustomTime(from timeInterval: TimeInterval) {
//        let hours = Int(timeInterval) / 3600
//        let minutes = (Int(timeInterval) % 3600) / 60
//        customTime = CustomTime(hours: hours, minutes: minutes)
//    }
//    
//    private func saveTimeLimit() {
//        // Обновляем ребенка с новым лимитом
//        if let index = parentManager.children.firstIndex(where: { $0.id == child.id }) {
//            parentManager.children[index].timeLimit = timeLimit
//            parentManager.saveChildren()
//        }
//        dismiss()
//    }
//    
//    private func formatTime(_ timeInterval: TimeInterval) -> String {
//        let hours = Int(timeInterval) / 3600
//        let minutes = (Int(timeInterval) % 3600) / 60
//        
//        if hours > 0 {
//            return "\(hours) ч \(minutes) мин"
//        } else {
//            return "\(minutes) мин"
//        }
//    }
//}
