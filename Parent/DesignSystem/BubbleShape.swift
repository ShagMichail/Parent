//
//  BubbleShape.swift
//  Parent
//
//  Created by Michail Shagovitov on 26.01.2026.
//

import SwiftUI

struct BubbleShape: Shape {
    enum Direction {
        case top, bottom
    }
    
    var direction: Direction
    var tipOffset: CGFloat = 30.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 12
        let tipSize: CGFloat = 10

        switch direction {
        case .top:
            let tipX = rect.maxX - tipOffset
            path.move(to: CGPoint(x: tipX - tipSize, y: tipSize))
            path.addLine(to: CGPoint(x: tipX, y: 0))
            path.addLine(to: CGPoint(x: tipX + tipSize, y: tipSize))
            path.addRoundedRect(
                in: CGRect(x: 0, y: tipSize, width: rect.width, height: rect.height - tipSize),
                cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
            )
            
        case .bottom:
            path.addRoundedRect(
                in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height - tipSize),
                cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
            )
            path.move(to: CGPoint(x: rect.midX - tipSize, y: rect.height - tipSize))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
            path.addLine(to: CGPoint(x: rect.midX + tipSize, y: rect.height - tipSize))
        }
        
        return path
    }
}
