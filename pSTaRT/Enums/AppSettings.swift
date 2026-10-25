//
//  AppSettings.swift
//  pSTaRT
//
//  Created by Kurt Frey on 25.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import Foundation

enum AppSettings {
    enum Key {
        static let csvFileSuffix = "csvexport.filesuffix"
        static let shareImmediately = "csvexport.shareimmediately"
        static let iCloudSyncEnabled = "icloud.syncenabled"
        static let pendingCloudPurge = "icloud.pendingpurge"
        static let scannerCodeTypes = "scanner.codetypes"
    }

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Key.csvFileSuffix: NSLocalizedString("CSV_DEFAULT_SUFFIX", comment: ""),
            Key.shareImmediately: true,
            Key.iCloudSyncEnabled: false,
            Key.pendingCloudPurge: false,
            Key.scannerCodeTypes: "org.iso.Code39",
        ])
    }
}
