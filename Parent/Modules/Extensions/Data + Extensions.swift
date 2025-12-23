//
//  Data + Extensions.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import CryptoKit
import Foundation

extension Data {
    /// Вычисляет хеш SHA256 и возвращает его в виде строки.
    var sha256: String {
        let hash = SHA256.hash(data: self)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
