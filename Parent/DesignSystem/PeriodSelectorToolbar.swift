//
//  PeriodSelectorToolbar.swift
//  Parent
//
//  Created by Михаил Шаговитов on 02.12.2025.
//

import SwiftUI

struct PeriodSelectorToolbar: View {
    @Binding var selectedPeriod: TimePeriod
    let childName: String
    let modelButtons: PeriodToolbarButtonModel
    
    var body: some View {
        VStack(spacing: 4) {
            
            HStack(spacing: 8) {
                ForEach(TimePeriod.allCases) { period in
                    PeriodToolbarButton(
                        period: period,
                        isSelected: selectedPeriod == period,
                        action: {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                selectedPeriod = period
                            }
                        },
                        model: modelButtons
                    )
                }
            }
            .padding(.horizontal, 4)
            .frame(height: 32)
        }
        .frame(maxWidth: .infinity)
    }
}
