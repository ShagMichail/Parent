//
//  ParentalRestrictions.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import FamilyControls
import ManagedSettings

struct ParentalRestrictions {
    var appsToBlock: Set<ApplicationToken>?
    var categoriesToBlock: Set<ActivityCategoryToken>?
    var denyExplicitContent: Bool = false
}
