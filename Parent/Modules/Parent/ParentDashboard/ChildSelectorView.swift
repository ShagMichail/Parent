//
//  ChildSelectorView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct ChildSelectorView: View {
    @Binding var children: [Child]
    @Binding var selectedChild: Child?
    
    var onAddChild: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Кнопка "Добавить"
                Button(action: onAddChild) {
                    ZStack {
                        Circle()
                            .fill(.plusBackround)
                        Image(systemName: "plus")
                            .resizable()
                            .foregroundColor(.plusForderground)
                            .frame(width: 30, height: 30)
                    }
                    .frame(width: 50, height: 50)
                }
                
                // Карточки детей
                ForEach(children) { child in
                    ChildCardView(
                        model: ChildCardViewModel(
                            child: child,
                            isSelected: child.id == selectedChild?.id
                        )
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedChild = child
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .padding(.horizontal, 20)
        }
    }
}
