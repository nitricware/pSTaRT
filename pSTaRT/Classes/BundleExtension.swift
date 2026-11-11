//
//  BundleExtension.swift
//  pSTaRT
//
//  Created by Kurt Frey on 11.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import Foundation

extension Bundle {
    var appVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}
