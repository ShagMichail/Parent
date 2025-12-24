//
//  TimeRow.swift
//  Parent
//
//  Created by Michail Shagovitov on 10.12.2025.
//

import SwiftUI

struct TimeRow: View {
    let title: String
    @Binding var time: Date
    @State private var showingTimePicker = false
    
    var body: some View {
        Button(action: {
            showingTimePicker = true
        }) {
            HStack {
                Text(title)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.blackText)
                Spacer()
                Text(time, style: .time)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.strokeTextField)
            }
        }
        .sheet(isPresented: $showingTimePicker) {
            VStack {
                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding()
                
                Button("Готово") {
                    showingTimePicker = false
                }
                .padding()
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
    }
}
