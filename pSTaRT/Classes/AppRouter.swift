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
    
    private init() { }
    
    @discardableResult
    func handle(_ item: UIApplicationShortcutItem) -> Bool {
        guard let action = AppAction(rawValue: item.type) else { return false }
        pending = action
        return true
    }
    
    private(set) var didReceiveAction = false
    var pending: AppAction? {
        didSet { if pending != nil { didReceiveAction = true } }
    }
}
