//
//  CSVManager.swift
//  pSTaRT
//
//  Created by Kurt Frey on 23.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import Foundation
import CoreData

enum CSVManager {
    @concurrent
    @discardableResult
    static func provideCSV() async throws -> URL {
        // The context must outlive every access to the fetched objects, so it is
        // held here and all managed object work happens inside its perform block.
        // Only the finished String leaves the block.
        let context = PersistenceController.shared.container.newBackgroundContext()
        let df = DateFormatter()
        // TODO: localize the date format
        df.dateFormat = UserDefaults.standard.string(forKey: AppSettings.Key.csvDatePrefix)
        
        let csv: String = try await context.perform {
            
            let persons = try pSTaRTDBHelper.fetchPersons(in: context)

            let sort = NSSortDescriptor(key: "date", ascending: true)

            var rows: [String] = []
            var overallMaxTriageNum = 0

            for person in persons {
                guard let plsNumber = person.plsNumber,
                      let startDate = person.startTime,
                      let endDate = person.endTime else {
                    throw CSVExportError.missingData
                }

                var fields = [plsNumber,
                              df.string(from: startDate),
                              df.string(from: endDate),
                              String(person.triageGroup)]

                let triages = (person.triages?.sortedArray(using: [sort]) as? [Triages]) ?? []
                for triage in triages {
                    fields.append(String(triage.group))
                    fields.append(triage.date.map(df.string(from:)) ?? "")
                }

                overallMaxTriageNum = max(overallMaxTriageNum, triages.count)
                rows.append(fields.joined(separator: ";"))
            }

            var header = NSLocalizedString("EXPORT_COLS", comment: "column headings")
            if overallMaxTriageNum > 0 {
                for i in 1...overallMaxTriageNum {
                    header += ";" + NSLocalizedString("EXPORT_COL_TRIAGEDECISION", comment: "retriage")
                    + " \(i);" + NSLocalizedString("EXPORT_COL_DATE", comment: "date")
                }
            }

            return ([header] + rows).joined(separator: "\n") + "\n"
        }

        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CSVExportError.noDocumentDirectory
        }
        
        let datePrefix = df.string(from: Date())
        let sanitizedFileName = self.sanitizeFilename(UserDefaults.standard.string(forKey: AppSettings.Key.csvFileSuffix)!)
        let separator:String = sanitizedFileName.isEmpty ? "" : "_"
        let file = "\(datePrefix)\(separator)\(sanitizedFileName).csv"
        
        let fileURL = dir.appendingPathComponent(file)
        
        try csv.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    static func sanitizeFilename(_ name: String) -> String {
        let newName = name.filter { char in
            char.isASCII && (char.isLetter || char.isNumber || char == "_" || char == "-")
        }
        
        return newName
    }
    
    static func deleteCSV(_ file: URL) throws {
        try FileManager.default.removeItem(at: file)
    }
}
