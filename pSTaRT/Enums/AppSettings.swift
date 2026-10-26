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
        static let csvDatePrefix = "csvexport.dateprefix"
        static let shareImmediately = "csvexport.shareimmediately"
        static let iCloudSyncEnabled = "icloud.syncenabled"
        static let pendingCloudPurge = "icloud.pendingpurge"
        static let scannerCodeTypes = "scanner.codetypes"
    }
    
    enum Default {
        static let shareImmediately = true
        static let csvFileSuffix: String = NSLocalizedString("CSV_DEFAULT_SUFFIX", comment: "")
        static let csvDatePrefix: String = "yyyy-MM-dd_HH-mm-ss"
        static let iCloudSyncEnabled: Bool = false
        static let pendingCloudPurge: Bool = false
        static let scannerCodeTypes: String = "org.iso.Code39"
    }

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Key.csvFileSuffix: self.Default.csvFileSuffix,
            Key.csvDatePrefix: self.Default.csvDatePrefix,
            Key.shareImmediately: self.Default.shareImmediately,
            Key.iCloudSyncEnabled: self.Default.iCloudSyncEnabled,
            Key.pendingCloudPurge: self.Default.pendingCloudPurge,
            Key.scannerCodeTypes: self.Default.scannerCodeTypes,
        ])
    }
}
