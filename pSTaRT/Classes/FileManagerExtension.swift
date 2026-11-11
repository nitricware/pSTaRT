//
//  FileManagerExtension.swift
//  pSTaRT
//
//  Created by Kurt Frey on 11.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import Foundation

extension FileManager {
    public static func excludeFromBackup(at url: URL?, exclude: Bool) throws {
        guard var url,
              FileManager.default.fileExists(atPath: url.path) else {
            throw pSTaRTErrors.excludeFromBackupFailed
        }
        var values = URLResourceValues()
        values.isExcludedFromBackup = exclude
        try url.setResourceValues(values)
    }
}
