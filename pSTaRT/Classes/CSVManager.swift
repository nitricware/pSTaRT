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
        
        df.dateStyle = .medium
        df.timeStyle = .medium
        
        let csv: String = try await context.perform {
            
            let persons = try pSTaRTDBHelper.fetchPersons(in: context)

            let sort = NSSortDescriptor(key: "date", ascending: true)

            var rows: [[String]] = []
            var paddedRows: [String] = []
            var overallMaxTriageNum = 0
            
            let headerComponents: [String] = NSLocalizedString("EXPORT_COLS", comment: "column headings").components(separatedBy: ";")

            for person in persons {
                var fields = [person.plsNumber ?? NSLocalizedString("common.unknown", comment: "unknown patient ID"),
                              person.startTime.map(df.string(from:)) ?? "",
                              person.endTime.map(df.string(from:)) ?? "",
                              String(person.triageGroup)]

                let triages = (person.triages?.sortedArray(using: [sort]) as? [Triages]) ?? []
                for triage in triages {
                    fields.append(String(triage.group))
                    fields.append(triage.date.map(df.string(from:)) ?? "")
                }

                overallMaxTriageNum = max(overallMaxTriageNum, triages.count)
                rows.append(fields)
                //rows.append(fields.map(escapeField).joined(separator: ";"))
            }
            
            // padding rows based on overallMaxTriageNum
            for row in rows {
                let i = ((overallMaxTriageNum * 2) + headerComponents.count) - row.count
                var newRow: [String] = row
                newRow.append(contentsOf: Array(repeating: "", count: i))
                paddedRows.append(newRow.map(escapeField).joined(separator: ";"))
            }
            
            var header = headerComponents.map(escapeField).joined(separator: ";")
            
            if overallMaxTriageNum > 0 {
                for i in 1...overallMaxTriageNum {
                    header += ";" + escapeField(NSLocalizedString("EXPORT_COL_TRIAGEDECISION", comment: "retriage")
                    + " \(i)") + ";" + escapeField(NSLocalizedString("EXPORT_COL_DATE", comment: "date"))
                }
            }

            return "\u{FEFF}" + ([header] + paddedRows).joined(separator: "\r\n") + "\r\n"
        }

        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CSVExportError.noDocumentDirectory
        }
        
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = UserDefaults.standard.string(forKey: AppSettings.Key.csvDatePrefix)
        
        let datePrefix = df.string(from: Date())
        let sanitizedFileName = self.sanitizeFilename(UserDefaults.standard.string(forKey: AppSettings.Key.csvFileSuffix)!)
        let separator: String = sanitizedFileName.isEmpty ? "" : "_"
        let file = "\(datePrefix)\(separator)\(sanitizedFileName).csv"
        
        let fileURL = dir.appendingPathComponent(file)
        
        try csv.write(to: fileURL, atomically: true, encoding: .utf8)
        #if DEBUG
            print("📄 wrote \(fileURL)")
        #endif
        return fileURL
    }
    
    static func sanitizeFilename(_ name: String) -> String {
        let newName = name.filter { char in
            char.isASCII && (char.isLetter || char.isNumber || char == "_" || char == "-")
        }
        
        return String(newName.prefix(30))
    }
    
    static func escapeField(_ field: String) -> String {
        var field = field
        field = field.replacingOccurrences(of: "\"", with: "\"\"")
        
        return "\"\(field)\""
    }
    
    static func deleteCSV(_ file: URL) throws {
        try FileManager.default.removeItem(at: file)
    }
}
