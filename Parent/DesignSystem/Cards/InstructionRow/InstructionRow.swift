//
//  InstructionRow.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct InstructionRow: View {
    let model: InstructionRowModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.accent)
                    .frame(width: 28, height: 39)
                
                Text(model.number)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(model.text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color.blackText)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}
