//
//  ParentalRestrictions.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import ManagedSettings
import Foundation

struct ParentalRestrictions {
    var appsToBlock: Set<ApplicationToken>?
    var webFiltering: Bool = true
//    var communicationLimits = CommunicationLimits.allowedContactsOnly
    var denyExplicitContent: Bool = true
    var dailyTimeLimit: TimeInterval? = 2 * 3600 // 2 часа
}
