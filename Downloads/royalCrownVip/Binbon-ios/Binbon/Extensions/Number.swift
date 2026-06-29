//
//  Number.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import Foundation

extension BinaryInteger {
    var enFormatted: String {
        Int(self).formatted(.number.locale(Locale(identifier: "en")))
    }
}
