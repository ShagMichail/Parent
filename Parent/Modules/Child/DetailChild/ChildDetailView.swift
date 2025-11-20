//
//  Untitled.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI
import DeviceActivity

struct ChildDetailView: View {
    @EnvironmentObject var stateManager: AuthenticationManager
    let child: Child
    
    @State private var showingActivityReport = false
    private let context = DeviceActivityReport.Context("Total Activity")

    var body: some View {
        VStack(spacing: 30) {
            Text("Управление устройством")
                .font(.title2)
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                Button("Заблокировать все") {
                    stateManager.sendBlockCommand(for: child.recordID)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)
                
                Button("Разблокировать все") {
                    stateManager.sendUnblockCommand(for: child.recordID)
                }
                .buttonStyle(.bordered)
                .tint(.green)
                .controlSize(.large)
            }
            .padding(.horizontal)
            
            Divider().padding()
            
            Button {
                showingActivityReport = true
            } label: {
                HStack {
                    Image(systemName: "chart.bar.fill")
                    Text("Посмотреть статистику")
                }
            }
        }
        .navigationTitle(child.name)
        .sheet(isPresented: $showingActivityReport) {
            DeviceActivityReport(context)
        }
    }
}
