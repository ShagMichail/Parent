//
//  OTPField.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct OTPField: View {
    let numberOfFields: Int
    @Binding var code: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .stroke(.accent, lineWidth: 1)
                .frame(maxHeight: 75)
            TextField("", text: $code)
                .keyboardType(.numbersAndPunctuation)
                .textContentType(.oneTimeCode)
                .autocapitalization(.allCharacters)
                .frame(width: 0, height: 0)
                .focused($isFocused)
                .onChange(of: code) { _, newValue in
                    if newValue.count > numberOfFields {
                        code = String(newValue.prefix(numberOfFields))
                    }
                }

            HStack(spacing: 12) {
                ForEach(0..<numberOfFields, id: \.self) { index in
                    let character = getCharacter(at: index)
                    Text(character)
                        .font(.system(size: 30, weight: .medium, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
            }
        }
        .onTapGesture {
            isFocused = true
        }
        .onAppear {
            isFocused = true
        }
    }

    private func getCharacter(at index: Int) -> String {
        guard index < code.count else {
            return "-"
        }
        return String(code[code.index(code.startIndex, offsetBy: index)])
    }
}
