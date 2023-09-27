//
//  main.swift
//  TimetableFormatConverter
//
//  Created by Cormell, David - DPC on 25/09/2023.
//

import Foundation
import CoreXLSX

if let path = Bundle.main.path(forResource: "JMBFormatTrial", ofType: "xlsx") {
    guard let xlsx = XLSXFile(filepath: path) else {
        fatalError("XLSX file at \(path) is corrupted or does not exist")
    }
    
    for wbk in try xlsx.parseWorkbooks() {
      for (name, path) in try xlsx.parseWorksheetPathsAndNames(workbook: wbk) {
        if let worksheetName = name {
          print("This worksheet has a name: \(worksheetName)")
        }

        let worksheet = try xlsx.parseWorksheet(at: path)
        for row in worksheet.data?.rows ?? [] {
          for c in row.cells {
            print(c)
          }
        }
      }
    }
} else {
    print("Unable to find excel timetable file in main bundle")
}


