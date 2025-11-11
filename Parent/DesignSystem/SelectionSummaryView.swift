////
////  SelectionSummaryView.swift
////  Parent
////
////  Created by Михаил Шаговитов on 10.11.2025.
////
//
//import SwiftUI
//import FamilyControls
//
//struct SelectionSummaryView: View {
//    let selection: FamilyActivitySelection
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Будет заблокировано:")
//                .font(.headline)
//            
//            if !selection.applicationTokens.isEmpty {
//                HStack {
//                    Image(systemName: "app")
//                        .foregroundColor(.blue)
//                    Text("Приложения: \(selection.applicationTokens.count)")
//                    Spacer()
//                }
//            }
//            
//            if !selection.categoryTokens.isEmpty {
//                HStack {
//                    Image(systemName: "square.grid.2x2")
//                        .foregroundColor(.orange)
//                    Text("Категории: \(selection.categoryTokens.count)")
//                    Spacer()
//                }
//            }
//            
//            if !selection.webDomainTokens.isEmpty {
//                HStack {
//                    Image(systemName: "network")
//                        .foregroundColor(.green)
//                    Text("Сайты: \(selection.webDomainTokens.count)")
//                    Spacer()
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(10)
//    }
//}
//
