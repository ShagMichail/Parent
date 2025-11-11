////
////  UsageProgressRow.swift
////  Parent
////
////  Created by Михаил Шаговитов on 10.11.2025.
////
//
//import SwiftUI
//
//struct UsageProgressRow: View {
//    let category: String
//    let time: Double
//    let totalTime: Double
//    
//    private var percentage: Double {
//        totalTime > 0 ? (time / totalTime) * 100 : 0
//    }
//    
//    private var icon: String {
//        switch category {
//        case "Игры": return "gamecontroller"
//        case "Соцсети": return "message"
//        case "Видео": return "play.rectangle"
//        case "Образование": return "book"
//        default: return "app"
//        }
//    }
//    
//    private var color: Color {
//        switch category {
//        case "Игры": return .purple
//        case "Соцсети": return .blue
//        case "Видео": return .red
//        case "Образование": return .green
//        default: return .gray
//        }
//    }
//    
//    var body: some View {
//        HStack {
//            Image(systemName: icon)
//                .foregroundColor(.white)
//                .frame(width: 24, height: 24)
//                .background(color)
//                .cornerRadius(4)
//            
//            Text(category)
//                .font(.caption)
//                .frame(width: 80, alignment: .leading)
//            
//            GeometryReader { geometry in
//                ZStack(alignment: .leading) {
//                    Rectangle()
//                        .fill(Color(.systemGray5))
//                        .frame(height: 8)
//                    
//                    Rectangle()
//                        .fill(color)
//                        .frame(width: CGFloat(percentage / 100) * geometry.size.width, height: 8)
//                }
//                .cornerRadius(4)
//            }
//            .frame(height: 8)
//            
//            Text("\(Int(time * 60))м")
//                .font(.caption2)
//                .foregroundColor(.secondary)
//                .frame(width: 40, alignment: .trailing)
//        }
//    }
//}
//
