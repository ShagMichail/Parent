////
////  QuickActionButton.swift
////  Parent
////
////  Created by Михаил Шаговитов on 10.11.2025.
////
//
//import SwiftUI
//
//struct QuickActionButton: View {
//    let title: String
//    let icon: String
//    let color: Color
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: 8) {
//                Image(systemName: icon)
//                    .font(.title3)
//                    .foregroundColor(color)
//                
//                Text(title)
//                    .font(.caption2)
//                    .fontWeight(.medium)
//                    .foregroundColor(.primary)
//                    .multilineTextAlignment(.center)
//                    .lineLimit(2)
//            }
//            .frame(height: 80)
//            .frame(maxWidth: .infinity)
//            .background(color.opacity(0.1))
//            .cornerRadius(10)
//        }
//    }
//}
