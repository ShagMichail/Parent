////
////  ChildRestrictionsView.swift
////  Parent
////
////  Created by Михаил Шаговитов on 12.11.2025.
////
//
//import SwiftUI
//
//struct ChildRestrictionsView: View {
//    let child: FamilyMember
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack {
//                Text("Активные ограничения")
//                    .font(.headline)
//                
//                Spacer()
//                
//                if hasActiveRestrictions {
//                    Text("\(activeRestrictionsCount)")
//                        .font(.caption)
//                        .fontWeight(.semibold)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 4)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//            }
//            
//            if hasActiveRestrictions {
//                LazyVStack(spacing: 12) {
//                    if child.timeLimit > 0 {
//                        RestrictionRow(
//                            title: "Лимит времени",
//                            description: "\(child.timeLimit) минут в день",
//                            icon: "clock",
//                            type: .time
//                        )
//                    }
//                    
//                    // Блокировка приложений
//                    if !child.blockedApps.isEmpty {
//                        RestrictionRow(
//                            title: "Заблокированные приложения",
//                            description: "\(child.blockedApps.count) приложений",
//                            icon: "app.badge.xmark",
//                            type: .apps
//                        )
//                    }
//                    
//                    // Ночной режим
//                    if let bedtime = child.bedtimeRestriction {
//                        RestrictionRow(
//                            title: "Ночной режим",
//                            description: "\(bedtime.startTime) - \(bedtime.endTime)",
//                            icon: "moon.zzz",
//                            type: .bedtime
//                        )
//                    }
//                    
//                    // Ограничение контента
//                    if child.contentRestrictionLevel != .unrestricted {
//                        RestrictionRow(
//                            title: "Возрастные ограничения",
//                            description: child.contentRestrictionLevel.description,
//                            icon: "eye.slash",
//                            type: .content
//                        )
//                    }
//                }
//            } else {
//                VStack(spacing: 12) {
//                    Image(systemName: "checkmark.circle")
//                        .font(.largeTitle)
//                        .foregroundColor(.green)
//                    
//                    Text("Ограничения не установлены")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    
//                    Text("Ребенок может свободно использовать устройство")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.center)
//                }
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color(.systemBackground))
//                .cornerRadius(12)
//            }
//        }
//    }
//    
//    private var hasActiveRestrictions: Bool {
//        return child.timeLimit > 0 ||
//               !child.blockedApps.isEmpty ||
//               child.bedtimeRestriction != nil ||
//               child.contentRestrictionLevel != .unrestricted
//    }
//    
//    private var activeRestrictionsCount: Int {
//        var count = 0
//        if child.timeLimit > 0 { count += 1 }
//        if !child.blockedApps.isEmpty { count += 1 }
//        if child.bedtimeRestriction != nil { count += 1 }
//        if child.contentRestrictionLevel != .unrestricted { count += 1 }
//        return count
//    }
//}
//
//struct RestrictionRow: View {
//    let title: String
//    let description: String
//    let icon: String
//    let type: RestrictionType
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: icon)
//                .font(.title3)
//                .foregroundColor(type.color)
//                .frame(width: 32)
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text(title)
//                    .font(.subheadline)
//                    .fontWeight(.medium)
//                
//                Text(description)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//            
//            Image(systemName: "chevron.right")
//                .font(.caption)
//                .foregroundColor(.gray)
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
//    }
//}
//
//enum RestrictionType {
//    case time, apps, bedtime, content
//    
//    var color: Color {
//        switch self {
//        case .time: return .blue
//        case .apps: return .red
//        case .bedtime: return .purple
//        case .content: return .orange
//        }
//    }
//}
