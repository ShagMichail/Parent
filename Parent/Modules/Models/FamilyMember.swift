//
//  FamilyMember.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

struct FamilyMember: Identifiable, Equatable {
    let id: String
    let name: String
    let type: MemberType
    let appleId: String
    var deviceId: String?
    var children: [FamilyMember] = []
    
    // Реализация Equatable
    static func == (lhs: FamilyMember, rhs: FamilyMember) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.type == rhs.type &&
               lhs.appleId == rhs.appleId &&
               lhs.deviceId == rhs.deviceId
    }
}
