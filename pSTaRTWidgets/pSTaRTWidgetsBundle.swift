//
//  pSTaRTWidgetsBundle.swift
//  pSTaRTWidgets
//
//  Created by Kurt Frey on 04.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct PStartWidgetsBundle: WidgetBundle {
    var body: some Widget {
        StartScanControl()
        ShowMapControl()
    }
}
