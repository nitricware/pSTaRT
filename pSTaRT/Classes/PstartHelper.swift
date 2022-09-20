//
//  PstartHelper.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 15.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import Foundation

class PstartHelper {
    
    
    
    static func provideCSV(completion: @escaping (URL?) -> Swift.Void) {
        // This is the foundation of the CSV file that will be saved - it contains the header
        var headerString = NSLocalizedString("EXPORT_COLS", comment: "column headings")
        var exportString = ""
        
        var returnURL: URL?
        // This is a blank row of the CSV file
        let exportLine = "%@;%@;%@;%d"
        
        // This DateFormatter is used throughout this function
        let df = DateFormatter()
        // TODO: localize the date format
        df.dateFormat = "EEEE, d MMM y - HH:mm:ss"
        var maxTriageNum = 0
        do {
            // Get the results into an array of NSManagedObjects
            let persons = try self.fetchPersons()
            // Iterate over this array, and append the entries as a row to the CSV file
            for person in persons {
                let plsNumber = person.plsNumber!
                let startDate = person.startTime!
                let endDate = person.endTime!
                let triageGroup = person.triageGroup
                
                let dataLine = String(format: exportLine, plsNumber, df.string(from: startDate), df.string(from: endDate), triageGroup)
                var triageLine = ""
                if let triages = person.triages {
                    let sort = NSSortDescriptor(key: "date", ascending: true)
                    let triagesArray = triages.sortedArray(using: [sort])
                    for case let triage as Triages in triagesArray {
                        maxTriageNum += 1
                        triageLine = triageLine + ";" + String(triage.group) + ";" + df.string(from: triage.date!)
                    }
                }
                exportString = exportString + dataLine + triageLine + "\n"
            }
            
            for i in 1 ... maxTriageNum{
                headerString = headerString + ";" + NSLocalizedString("EXPORT_COL_TRIAGEDECISION", comment: "retriage")  + " \(i);" + NSLocalizedString("EXPORT_COL_DATE", comment: "date")
            }
            
            exportString = headerString + "\n" + exportString
            
            // The filename consists of a fixed string and the current date
            let file = String(format: NSLocalizedString("EXPORT_FILENAME", comment: "filename"), df.string(from: Date()))
            
            // TODO: Delete old Files
            // Save the file to the documentDirectory of the App
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(file)
                do {
                    try exportString.write(to: fileURL, atomically: false, encoding: .utf8)
                    // Everything succeeded, the file name is returned for further use.
                    self.currentCSV = fileURL
                    returnURL = self.currentCSV
                } catch {
                    print("Can't export.")
                }
            }
        } catch {
            print("Can't fetch.")
        }
        
        // Something went wrong along the way but didn't throw an error - return nil
        // TODO: add dummy file
        completion(returnURL)
    }
    
}
