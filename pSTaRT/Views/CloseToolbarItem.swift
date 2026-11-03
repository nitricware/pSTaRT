//
//  CloseToolbarItem.swift
//  pSTaRT
//
//  Created by Kurt Frey on 03.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import SwiftUI

struct CloseToolbarItem: ToolbarContent {
    @Environment(\.dismiss) private var dismiss

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .close) { dismiss() }
        }
    }
}
