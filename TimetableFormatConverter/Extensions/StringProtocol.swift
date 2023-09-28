//
//  StringProtocol.swift
//  TimetableFormatConverter
//
//  Created by Cormell, David - DPC on 28/09/2023.
//

import Foundation

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
