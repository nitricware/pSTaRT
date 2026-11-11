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
        
        let yes = NSLocalizedString("YES", comment: "precise location")
        let no = NSLocalizedString("NO", comment: "approximate location")
        
        let csv: String = try await context.perform {
            
            let persons = try context.fetchPersons(sortDescriptors: [NSSortDescriptor(keyPath: \Persons.startTime, ascending: false)])

            let sort = NSSortDescriptor(key: "date", ascending: true)

            var rows: [[String]] = []
            var paddedRows: [String] = []
            var overallMaxTriageNum = 0
            
            let headerComponents: [String] = NSLocalizedString("EXPORT_COLS", comment: "column headings").components(separatedBy: ";")

            for person in persons {
                let coordinate = person.coordinate
                
                var fields = [person.plsNumber ?? NSLocalizedString("common.unknown", comment: "unknown patient ID"),
                              timestamp(for: person.startTime),
                              timestamp(for: person.endTime),
                              String(person.triageGroup),
                              coordinate.map { String(format: "%.6f", $0.latitude) } ?? "",
                              coordinate.map { String(format: "%.6f", $0.longitude) } ?? "",
                              coordinate == nil ? "" : (person.preciseLocation ? yes : no)]

                let triages = (person.triages?.sortedArray(using: [sort]) as? [Triages]) ?? []
                for triage in triages {
                    fields.append(String(triage.group))
                    fields.append(timestamp(for: triage.date))
                }

                overallMaxTriageNum = max(overallMaxTriageNum, triages.count)
                rows.append(fields)
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
        
        let fileDF = DateFormatter()
        fileDF.locale = Locale(identifier: "en_US_POSIX")
        fileDF.dateFormat = UserDefaults.standard.string(forKey: AppSettings.Key.csvDatePrefix)
        let datePrefix = fileDF.string(from: Date())
        
        let sanitizedFileName = self.sanitizeFilename(UserDefaults.standard.string(forKey: AppSettings.Key.csvFileSuffix)!)
        let separator: String = sanitizedFileName.isEmpty ? "" : "_"
        let file = "\(datePrefix)\(separator)\(sanitizedFileName).csv"
        
        let fileURL = dir.appendingPathComponent(file)
        
        try csv.write(to: fileURL, atomically: true, encoding: .utf8)
        try FileManager.excludeFromBackup(at: fileURL, exclude: !PersistenceController.shared.isCloudSyncActive)
        
        return fileURL
    }
    
    static func sanitizeFilename(_ name: String) -> String {
        let newName = name.filter { char in
            char.isASCII && (char.isLetter || char.isNumber || char == "_" || char == "-")
        }
        
        return String(newName.prefix(30))
    }
    
    /// Escape special characters and make formulas a string when imported
    /// in programs like Excel. Ignore numbers.
    static func escapeField(_ field: String) -> String {
        var field = field
        if let first = field.first, "=+-@\t\r".contains(first), Double(field) == nil {
            field = "'" + field
        }
        field = field.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(field)\""
    }
    
    static func deleteCSV(_ file: URL) throws {
        do {
            try FileManager.default.removeItem(at: file)
        } catch {
            throw pSTaRTErrors.csvExportError
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .medium
        return f
    }()

    private static func timestamp(for date: Date?) -> String {
        guard let date else { return "" }
        return "\(dateFormatter.string(from: date)) \(timeFormatter.string(from: date))"
    }
}
