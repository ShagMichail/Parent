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
                Text("Start")
                    .font(.custom("Inter-SemiBold", size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)

                CustomTimePicker(
                            time: $time,
                            selectedColor: .accent,
                            unselectedColor: .strokeTextField
                        )
                        .frame(height: 200)
                
                Spacer()

                ContinueButton(
                    model: ContinueButtonModel(
                        title: String(localized: "Done"),
                        isEnabled: true,
                        fullWidth: true,
                        action: {
                            showingTimePicker = false
                        }
                    )
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .presentationDetents([.height(350)])
            .presentationDragIndicator(.hidden)
            .presentationBackground(.clear)
            .background(Color.white)
            .cornerRadius(30)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
