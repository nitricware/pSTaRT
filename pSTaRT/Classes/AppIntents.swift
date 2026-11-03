//
//  AppIntents.swift
//  pSTaRT
//
//  Created by Kurt Frey on 03.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import AppIntents

struct StartScanIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.startscan.title"
    static let description = IntentDescription("intent.startscan.description")
    static let supportedModes: IntentModes = .foreground   // opens the app (replaces openAppWhenRun)

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.pending = .scan
        return .result()
    }
}

struct ShowMapIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.showmap.title"
    static let description = IntentDescription("intent.showmap.description")
    static let supportedModes: IntentModes = .foreground

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.pending = .map
        return .result()
    }
}
