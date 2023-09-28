//
//  TimetabledSchool.swift
//  TimetableFormatConverter
//
//  Created by Cormell, David - DPC on 27/09/2023.
//

import Foundation

struct TimetabledSchool {
    let school: String
    let divCode: String
    let masterInitials: String
    let room: String
    
    var display: String {
        "\(school),\(divCode),\(masterInitials),\(room)\n"
    }
}
