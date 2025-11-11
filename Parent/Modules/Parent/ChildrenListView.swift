//
//  ChildrenListView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI
import CloudKit

import SwiftUI
import CloudKit

struct ChildrenListView: View {
    let children: [FamilyMember]  // Изменили на [FamilyMember]
    @EnvironmentObject var parentManager: FamilyManager
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        List {
            ForEach(children) { child in
                NavigationLink {
                    ChildDetailView(child: child)  // Нужно будет обновить и ChildDetailView
                } label: {
                    ChildRowView(child: child)  // И ChildRowView тоже нужно обновить
                }
            }
//            .onDelete { indexSet in
//                Task {
//                    await deleteChildren(at: indexSet)
//                }
//            }
        }
        .alert("Ошибка", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
//    private func deleteChildren(at offsets: IndexSet) async {
//        for index in offsets {
//            let childToDelete = children[index]
//
//            do {
//                // Удаляем ребенка из CloudKit
//                try await deleteChildFromCloudKit(childToDelete)
//
//                // Удаляем локально
//                await MainActor.run {
//                    // Удаляем из currentUser.children (FamilyMember)
//                    if let userIndex = parentManager.currentUser?.children.firstIndex(where: { $0.id == childToDelete.id }) {
//                        parentManager.currentUser?.children.remove(at: userIndex)
//                    }
//
//                    // Удаляем из cloudChildren (String) - теперь id уже String
//                    if let cloudIndex = parentManager.cloudChildren.firstIndex(where: { $0.id == childToDelete.id }) {
//                        parentManager.cloudChildren.remove(at: cloudIndex)
//                    }
//                }
//
//            } catch {
//                await MainActor.run {
//                    errorMessage = "Не удалось удалить ребенка: \(error.localizedDescription)"
//                    showingError = true
//                }
//            }
//        }
//    }
    
//    private func deleteChildFromCloudKit(_ child: FamilyMember) async throws {
//        let cloudKitManager = CloudKitManager.shared
//
//        // Теперь id уже String, не нужно конвертировать
//        let childRecordID = CKRecord.ID(recordName: child.id)
//
//        do {
//            try await cloudKitManager.privateDB.deleteRecord(withID: childRecordID)
//            print("✅ Ребенок удален из CloudKit: \(child.name)")
//        } catch {
//            print("❌ Ошибка удаления из CloudKit: \(error)")
//            throw error
//        }
//    }
}
