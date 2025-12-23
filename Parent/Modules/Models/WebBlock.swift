//
//  WebBlock.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import Foundation

struct WebBlock: Identifiable, Codable, Hashable {
    var id: String { domain }
    let domain: String
}
