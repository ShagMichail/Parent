////
////  ChildRestrictionsView.swift
////  Parent
////
////  Created by Михаил Шаговитов on 10.11.2025.
////
//
//import SwiftUI
//
//struct ChildRestrictionsView: View {
//    let child: Child
//    @EnvironmentObject var parentManager: ParentControlManager
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack {
//                Text("Активные ограничения")
//                    .font(.headline)
//                
//                Spacer()
//                
//                Text("\(totalRestrictionsCount)")
//                    .font(.caption)
//                    .fontWeight(.semibold)
//                    .padding(6)
//                    .background(Color.blue.opacity(0.1))
//                    .cornerRadius(8)
//            }
//            
//            if totalRestrictionsCount == 0 {
//                EmptyRestrictionsView()
//            } else {
//                // Заблокированные приложения
//                if !child.restrictions.applicationTokens.isEmpty {
//                    RestrictionsSectionView(
//                        title: "Заблокированные приложения",
//                        icon: "app.badge.xmark",
//                        color: .red,
//                        count: child.restrictions.applicationTokens.count
//                    )
//                }
//                
//                // Заблокированные категории
//                if !child.restrictions.categoryTokens.isEmpty {
//                    RestrictionsSectionView(
//                        title: "Заблокированные категории",
//                        icon: "square.grid.2x2",
//                        color: .orange,
//                        count: child.restrictions.categoryTokens.count
//                    )
//                }
//                
//                // Заблокированные сайты
//                if !child.restrictions.webDomainTokens.isEmpty {
//                    RestrictionsSectionView(
//                        title: "Заблокированные сайты",
//                        icon: "network",
//                        color: .blue,
//                        count: child.restrictions.webDomainTokens.count
//                    )
//                }
//                
//                // Временные ограничения
//                TimeRestrictionsSection(timeLimit: child.timeLimit)
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .gray.opacity(0.2), radius: 5)
//    }
//    
//    private var totalRestrictionsCount: Int {
//        return child.restrictions.applicationTokens.count +
//               child.restrictions.categoryTokens.count +
//               child.restrictions.webDomainTokens.count
//    }
//}
