////
////  TimeRestrictionsSection.swift
////  Parent
////
////  Created by Михаил Шаговитов on 10.11.2025.
////
//
//import SwiftUI
//
//struct TimeRestrictionsSection: View {
//    let timeLimit: TimeInterval
//    
//    var body: some View {
//        HStack {
//            Label("Лимит времени", systemImage: "timer")
//                .foregroundColor(.blue)
//                .font(.subheadline)
//                .fontWeight(.medium)
//            
//            Spacer()
//            
//            Text(formatTime(timeLimit))
//                .font(.caption)
//                .fontWeight(.semibold)
//                .padding(.horizontal, 8)
//                .padding(.vertical, 4)
//                .background(Color.blue.opacity(0.1))
//                .foregroundColor(.blue)
//                .cornerRadius(6)
//        }
//        .padding()
//        .background(Color.blue.opacity(0.05))
//        .cornerRadius(10)
//    }
//    
//    private func formatTime(_ timeInterval: TimeInterval) -> String {
//        let hours = Int(timeInterval) / 3600
//        let minutes = (Int(timeInterval) % 3600) / 60
//        return "\(hours)ч \(minutes)м"
//    }
//}
//
