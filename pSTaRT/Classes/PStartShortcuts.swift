//
//  PStartShortcuts.swift
//  pSTaRT
//
//  Created by Kurt Frey on 03.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import AppIntents

struct PStartShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartScanIntent(),
            phrases: [
                "Start triage scanner in \(.applicationName).",
                "Scan with \(.applicationName)."
            ],
            shortTitle: "shortcut.scan",
            systemImageName: "barcode.viewfinder"
        )
        AppShortcut(
            intent: ShowMapIntent(),
            phrases: [
                "Show map of triaged persons in \(.applicationName).",
                "Show the \(.applicationName) map."
            ],
            shortTitle: "shortcut.map",
            systemImageName: "map"
        )
    }
}
