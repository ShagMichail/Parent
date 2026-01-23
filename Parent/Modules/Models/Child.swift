//
//  Child.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import Foundation
import FamilyControls

struct Child: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    let name: String
    let recordID: String
    let gender: String
    let childAppleID: String

    static func == (lhs: Child, rhs: Child) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
