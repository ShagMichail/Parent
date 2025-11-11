////
////  RestrictionsSectionView.swift
////  Parent
////
////  Created by Михаил Шаговитов on 10.11.2025.
////
//
//import SwiftUI
//
//struct RestrictionsSectionView: View {
//    let title: String
//    let icon: String
//    let color: Color
//    let count: Int
//    
//    var body: some View {
//        HStack {
//            Label(title, systemImage: icon)
//                .foregroundColor(color)
//                .font(.subheadline)
//                .fontWeight(.medium)
//            
//            Spacer()
//            
//            Text("\(count)")
//                .font(.caption)
//                .fontWeight(.semibold)
//                .padding(.horizontal, 8)
//                .padding(.vertical, 4)
//                .background(color.opacity(0.1))
//                .foregroundColor(color)
//                .cornerRadius(6)
//        }
//        .padding()
//        .background(color.opacity(0.05))
//        .cornerRadius(10)
//    }
//}
