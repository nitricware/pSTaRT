//
//  OverviewSheet.swift
//  pSTaRT
//
//  Created by Kurt Frey on 03.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

enum OverviewSheet: Identifiable {
    case settings, tipJar, map, triage(TriageSession), whatsNew

    var id: String {
        switch self {
        case .settings: "settings"
        case .tipJar: "tipJar"
        case .map: "map"
        case .triage(let session): "triage-\(ObjectIdentifier(session))"
        case .whatsNew: "whatsNew"
        }
    }
}
