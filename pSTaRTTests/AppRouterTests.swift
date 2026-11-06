//
//  AppRouterTests.swift
//  pSTaRT
//
//  Created by Kurt Frey on 06.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import Testing
import UIKit
@testable import pSTaRT

@MainActor
@Suite("AppRouter – quick actions", .serialized)
struct AppRouterTests {
    private let router = AppRouter.shared

    init() {
        router.pending = nil
    }

    @Test(arguments: [AppAction.scan, .map])
    func knownShortcutSetsPendingAction(_ action: AppAction) {
        let item = UIApplicationShortcutItem(type: action.rawValue, localizedTitle: "Test")

        #expect(router.handle(item))
        #expect(router.pending == action)
    }

    @Test func unknownShortcutIsIgnored() {
        let item = UIApplicationShortcutItem(type: "com.example.unknown", localizedTitle: "Test")

        #expect(!router.handle(item))
        #expect(router.pending == nil)
    }
}
