//
//  AppRouter.swift
//  pSTaRT
//
//  Created by Kurt Frey on 03.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import Observation
import UIKit

@MainActor @Observable
final class AppRouter {
    static let shared = AppRouter()
    /// Set by the quick action or an intent, consumed (set to `nil`) by `Overview`.
    var pending: AppAction?
    
    private init() { }
    
    @discardableResult
    func handle(_ item: UIApplicationShortcutItem) -> Bool {
        guard let action = AppAction(rawValue: item.type) else { return false }
        pending = action
        return true
    }
}
