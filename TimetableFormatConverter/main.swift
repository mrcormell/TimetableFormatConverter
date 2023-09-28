//
//  main.swift
//  TimetableFormatConverter
//
//  Created by Cormell, David - DPC on 25/09/2023.
//

import Foundation
import CoreXLSX

func transformSchoolCodeToSchoolName(code: String) -> String {
    switch code {
    case "a":
        return "Wednesday5th"
    case "b":
        return "Saturday2nd"
    case "c":
        return "Monday2nd"
    case "d":
        return "Monday3rd"
    case "e":
        return "Friday7th"
    case "f":
        return "Wednesday4th"
    case "g":
        return "Thursday1st"
    case "h":
        return "Thursday5th"
    case "i":
        return "Friday6th"
    case "j":
        return "Tuesday2nd"
    case "k":
        return "Tuesday3rd"
    case "l":
        return "Monday6th"
    case "m":
        return "Thursday4th"
    case "n":
        return "Wednesday1st"
    case "o":
        return "Friday5th"
    case "p":
        return "Saturday3rd"
    case "q":
        return "Wednesday2nd"
    case "r":
        return "Wednesday3rd"
    case "s":
        return "Monday7th"
    case "t":
        return "Friday4th"
    case "u":
        return "Tuesday1st"
    case "v":
        return "Wednesday7th"
    case "w":
        return "Monday5th"
    case "x":
        return "Thursday2nd"
    case "y":
        return "Thursday3rd"
    case "z":
        return "Saturday1st"
    case "a'":
        return "Monday1st"
    case "b'":
        return "Monday1st"
    case "c'":
        return "Monday1st"
    case "d'":
        return "Monday1st"
    case "e'":
        return "Monday1st"
    case "f'":
        return "Monday1st"
    case "g'":
        return "Monday1st"
    case "h'":
        return "Monday1st"
    case "i'":
        return "Monday1st"
    default:
        print("Erroneous code received: \(code)")
        return "UnknownSchool"
    }
}

func hoursToArrayOfHours(hours: String) -> [String] {
    var hoursArray = [String]()
    for i in 0..<hours.count {
        if hours[i] == "'" {
            hoursArray.append("\(hours[i-1])\(hours[i])")
        } else if i == hours.count - 1 || hours[i+1] != "'" {
            hoursArray.append("\(hours[i])")
        }
    }
    
    return hoursArray
}

func roomToEnumName(room: String) -> String {
    if room.hasPrefix("1") {
        return "\(room.suffix(room.count-2))1"
    } else if room.hasPrefix("2") {
        return "\(room.suffix(room.count-2))2"
    } else if room.hasPrefix("3") {
        return "\(room.suffix(room.count-2))3"
    } else if room.hasPrefix("4") {
        return "\(room.suffix(room.count-2))4"
    } else if room.hasPrefix("5") {
        return "\(room.suffix(room.count-2))5"
    } else if room.hasPrefix("6") {
        return "\(room.suffix(room.count-2))6"
    } else if room.hasPrefix("7") {
        return "\(room.suffix(room.count-2))7"
    } else if room.hasPrefix("8") {
        return "\(room.suffix(room.count-2))8"
    } else {
        let stringWithoutWhitespace = room.filter { !$0.isWhitespace }
        return stringWithoutWhitespace
    }
}

func transformRowToTimetabledSchools(row: Row, sharedStrings: SharedStrings, teachersToRooms: [String: String]) -> [TimetabledSchool] {
    var divCode = ""
    var hours = ""
    var initials = ""
    var room = ""
    
    for rowCell in row.cells {
        if rowCell.reference.column.value == "D" {
            divCode = rowCell.stringValue(sharedStrings) ?? ""
        } else if rowCell.reference.column.value == "E" {
            hours = rowCell.stringValue(sharedStrings) ?? ""
        } else if rowCell.reference.column.value == "F" {
            initials = rowCell.stringValue(sharedStrings) ?? ""
        } else if rowCell.reference.column.value == "G" {
            room = rowCell.stringValue(sharedStrings) ?? ""
        }
    }
    
    
    var timetabledSchools = [TimetabledSchool]()
    if room == "" && !initials.isEmpty {
        room = teachersToRooms[initials] ?? ""
    }
    room = roomToEnumName(room: room)
    let schools = hoursToArrayOfHours(hours: hours)
    
    for school in schools {
        let schoolDescription = transformSchoolCodeToSchoolName(code: school)
        timetabledSchools.append(TimetabledSchool(school: schoolDescription, divCode: divCode, masterInitials: initials, room: room))
    }
    
    return timetabledSchools
}

func transformRowToTeacherRoom(row: Row, sharedStrings: SharedStrings) -> (teacher: String, room: String) {
    var teacher: String = ""
    var room: String = ""
    
    for rowCell in row.cells {
        if rowCell.reference.column.value == "E" {
            teacher = rowCell.stringValue(sharedStrings) ?? ""
        } else if rowCell.reference.column.value == "F" {
            room = rowCell.stringValue(sharedStrings) ?? ""
        }
    }
    
    return (teacher, room)
}

func writeToFile(timetable: [TimetabledSchool]) {
    let path = URL(filePath: "/Users/d.cormell/Desktop/timetable.txt")
    var stringToWrite = ""
    do {
        for school in timetable {
            stringToWrite.append(school.display)
        }
        try stringToWrite.write(to: path, atomically: true, encoding: .utf8)
    } catch {
        print("Error writing to file!")
    }
}

let hoursToSchools = ["a":"Monday1st"]

guard let xlsx = XLSXFile(filepath: "/Users/d.cormell/Documents/TimetableFormatConverter/TimetableFormatConverter/JMBFormatTrial.xlsx") else {
    fatalError("XLSX file is corrupted or does not exist")
}

guard let sharedStrings = try xlsx.parseSharedStrings() else {
    fatalError("couldn't get shared strings from the xlsx file")
}

for wbk in try xlsx.parseWorkbooks() {
    var teachersToRooms = [String: String]()
  for (name, path) in try xlsx.parseWorksheetPathsAndNames(workbook: wbk) {
      
      if let worksheetName = name {
          print("This worksheet has a name: \(worksheetName)")
          let worksheet = try xlsx.parseWorksheet(at: path)
          if worksheetName == "MastersAndRooms" {
              
              for row in worksheet.data?.rows ?? [] {
                  let teacherRoom = transformRowToTeacherRoom(row: row, sharedStrings: sharedStrings)
                  teachersToRooms[teacherRoom.teacher] = teacherRoom.room
              }
          }
          else if worksheetName == "All Division Headings" {
              var timetabledSchools = [TimetabledSchool]()
              for row in worksheet.data?.rows ?? [] {
                  timetabledSchools.append(contentsOf: transformRowToTimetabledSchools(row: row, sharedStrings: sharedStrings, teachersToRooms: teachersToRooms))
                  
              }
              print(timetabledSchools)
              writeToFile(timetable: timetabledSchools)
          }
        
    }


  }
}



