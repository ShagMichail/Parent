//
//  OTPField.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct OTPField: View {
    var isError: Bool = false
    let numberOfFields: Int
    @Binding var code: String
    @FocusState private var focusedField: Int?

    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .stroke(.accent, lineWidth: 1)
                .stroke(isError ? Color.errorMessage : Color.accent, lineWidth: 1)
                .frame(maxHeight: 75)
            TextField("", text: $code)
                .keyboardType(.numbersAndPunctuation)
                .textContentType(.oneTimeCode)
                .autocapitalization(.allCharacters)
                .frame(width: 0, height: 0)
                .focused($focusedField, equals: 0)
                .onChange(of: code) { _, newValue in
                    if newValue.count > numberOfFields {
                        code = String(newValue.prefix(numberOfFields))
                    }
                }

            HStack(spacing: 12) {
                ForEach(0..<numberOfFields, id: \.self) { index in
                    let character = getCharacter(at: index)
                    Text(character)
                        .font(.custom("Inter-Medium", size: 30))
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
            }
        }
        .onTapGesture {
            focusedField = 0
        }
        .onChange(of: focusedField) { _, newFocusValue in
            if newFocusValue != nil {
                if !code.isEmpty {
                    code = ""
                }
            }
        }
    }

    private func getCharacter(at index: Int) -> String {
        guard index < code.count else {
            return "-"
        }
        return String(code[code.index(code.startIndex, offsetBy: index)])
    }
}
