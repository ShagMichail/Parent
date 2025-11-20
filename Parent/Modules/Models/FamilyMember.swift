//
//  FamilyMember.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

struct FamilyMember: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let type: MemberType
    let appleId: String
    var deviceId: String?
    var isPlaceholder: Bool = false
    var isRealFamilyMember: Bool = false
    var children: [FamilyMember] = []
    
    static func == (lhs: FamilyMember, rhs: FamilyMember) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.type == rhs.type &&
               lhs.appleId == rhs.appleId &&
                lhs.deviceId == rhs.deviceId &&
                lhs.isPlaceholder == rhs.isPlaceholder &&
                lhs.isRealFamilyMember == rhs.isRealFamilyMember
    }
}

extension FamilyMember {
    var todayUsageTime: Int { 120 }
    var remainingTime: Int { 60 }
    var topUsedApps: [AppUsage] { [] }
    var weeklyStats: [DailyUsage]? { nil }
    
    // Для ограничений
    var timeLimit: Int { 0 }
    var blockedApps: [String] { [] }
    var bedtimeRestriction: BedtimeRestriction? { nil }
    var contentRestrictionLevel: ContentRestrictionLevel { .unrestricted }
    
    // Состояния
    var isDeviceBlocked: Bool { false }
    var isPaused: Bool { false }
}


struct BedtimeRestriction {
    let startTime: String
    let endTime: String
}

enum ContentRestrictionLevel: String, CaseIterable, Hashable {
    case unrestricted = "unrestricted"
    case child = "child"
    case teen = "teen"
    case adult = "adult"
    
    var description: String {
        switch self {
        case .unrestricted: return "Все"
        case .child: return "6+"
        case .teen: return "12+"
        case .adult: return "18+"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .unrestricted:
            return "Все приложения и контент доступны"
        case .child:
            return "Только контент для детей до 6 лет"
        case .teen:
            return "Контент для подростков до 12 лет"
        case .adult:
            return "Все, кроме контента для взрослых 18+"
        }
    }
}
