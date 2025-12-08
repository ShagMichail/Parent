//
//  WaitingForChildView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct WaitingForChildView: View {
    let invitationCode: String
    
    var body: some View {
        VStack {
            
            VStack(alignment: .leading, spacing: 25) {
                Text("Вход с помощью кода")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Чтобы начать мониторинг и помочь вашему ребёнку оставаться в безопасности, подключите его устройство:")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                InstructionRow(
                    model: InstructionRowModel(
                        number: "1",
                        text: "Скачайте приложение на телефон ребёнка.\n(Можно установить из App Store или Google Play.)"
                    )
                )
                InstructionRow(
                    model: InstructionRowModel(
                        number: "2",
                        text: "Откройте приложение и выберите роль «Ребёнок»"
                    )
                )
                InstructionRow(
                    model: InstructionRowModel(
                        number: "3",
                        text: "Введите уникальный код подключения, который отображается"
                    )
                )
                InstructionRow(
                    model: InstructionRowModel(
                        number: "4",
                        text: "После ввода кода устройство автоматически подключится"
                    )
                )
            }
            
            VStack {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accent)
                    
                    Text(invitationCode)
                        .font(.system(size: 36, weight: .medium, design: .rounded))
                        .kerning(4)
                        .foregroundColor(.white)
                }
                .frame(maxHeight: 75)
                .padding(.horizontal, 60)
                
                Spacer()
                
                ContinueButton(
                    model: ContinueButtonModel(
                        title: "или отсканировать код",
                        isEnabled: false,
                        action: {
                            print("Hey hey")
                        }
                    )
                )
                .frame(height: 50)
            }
            .padding(.top, 40)
            
        }
        .padding(.top, 80)
        .padding(.bottom, 92)
        .padding(.horizontal, 20)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
