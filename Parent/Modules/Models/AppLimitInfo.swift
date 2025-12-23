//
//  AppLimitInfo.swift
//  Parent
//
//  Created by Michail Shagovitov on 19.12.2025.
//

import Foundation
import ManagedSettings

struct AppLimit: Identifiable, Hashable {
    var id: ApplicationToken { token }
    let token: ApplicationToken
    var time: TimeInterval
}

struct AppBlock: Identifiable, Hashable {
    var id: ApplicationToken { token }
    let token: ApplicationToken
}
