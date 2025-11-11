////
////  ChildRestrictionsPickerView.swift
////  Parent
////
////  Created by Михаил Шаговитов on 10.11.2025.
////
//
//import SwiftUI
//import FamilyControls
//
//struct ChildRestrictionsPickerView: View {
//    let child: Child
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var parentManager: ParentControlManager
//    @State private var selection: FamilyActivitySelection
//    
//    init(child: Child) {
//        self.child = child
//        self._selection = State(initialValue: child.restrictions)
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                FamilyActivityPicker(selection: $selection)
//                    .padding(.horizontal)
//                
//                // Информация о выборе
//                if !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty {
//                    SelectionSummaryView(selection: selection)
//                        .padding()
//                }
//            }
//            .navigationTitle("Ограничения для \(child.name)")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Отмена") {
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Сохранить") {
//                        saveRestrictions()
//                    }
//                    .fontWeight(.semibold)
//                }
//            }
//        }
//    }
//    
//    private func saveRestrictions() {
//        parentManager.updateRestrictions(for: child, selection: selection)
//        dismiss()
//    }
//}
