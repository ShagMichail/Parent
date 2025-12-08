//
//  NavigationBarModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import Foundation

struct NavigationBarModel {
    let mainTitle: String?
    let chevronBackward: Bool?
    let subTitle: String?
    let hasNotification: Bool?
    let hasNewNotification: Bool?
    
    let onBackTap: () -> Void
    let onNotificationTap: () -> Void
    
    init(mainTitle: String? = nil, chevronBackward: Bool? = nil, subTitle: String? = nil, hasNotification: Bool? = nil, hasNewNotification: Bool? = nil, onBackTap: @escaping () -> Void, onNotificationTap: @escaping () -> Void) {
        self.mainTitle = mainTitle
        self.chevronBackward = chevronBackward
        self.subTitle = subTitle
        self.hasNotification = hasNotification
        self.hasNewNotification = hasNewNotification
        self.onBackTap = onBackTap
        self.onNotificationTap = onNotificationTap
    }
}
