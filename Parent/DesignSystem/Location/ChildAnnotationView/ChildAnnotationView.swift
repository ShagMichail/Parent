//
//  ChildAnnotationView.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import SwiftUI

struct ChildAnnotationView: View {
    let model: ChildAnnotationViewModel
    
    private var primaryColor: Color {
        model.gender == "men" ? .backgroundMen : .backgroundGirl
    }
    
    var body: some View {
        if model.isSelected {
            ZStack {
                ZStack {
                    Circle()
                        .stroke(primaryColor.opacity(0.5), lineWidth: 20)
                    Circle()
                        .fill(primaryColor)
                        .frame(width: 20, height: 20)
                }
                .frame(width: 64, height: 64)
                
                Text(model.name)
                    .font(.custom("Inter-Medium", size: 12))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .opacity(1.0)
                    .padding(.bottom, 70)
            }
        } else {
            ZStack {
                ZStack {
                    Circle()
                        .stroke(primaryColor.opacity(0.5), lineWidth: 10)
                    Circle()
                        .fill(primaryColor)
                        .frame(width: 10, height: 10)
                }
                .frame(width: 10, height: 10)
                
                Text(model.name)
                    .font(.custom("Inter-Medium", size: 12))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .opacity(1.0)
                    .padding(.bottom, 50)
            }
        }
    }
}
