//
//  FileManagerExtension.swift
//  pSTaRT
//
//  Created by Kurt Frey on 11.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import Foundation

extension FileManager {
    public static func excludeFromBackup(at url: URL?, exclude: Bool) {
        guard var url,
              FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        var values = URLResourceValues()
        values.isExcludedFromBackup = exclude
        try? url.setResourceValues(values)
    }
    
    static func applyBackupPolicyToExports(exclude: Bool) {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let files = try? FileManager.default.contentsOfDirectory(
                  at: dir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        else { return }

        for file in files where file.pathExtension.lowercased() == "csv" {
            let current = try? file.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup
            if current != exclude { excludeFromBackup(at: file, exclude: exclude) }
        }
    }
}
