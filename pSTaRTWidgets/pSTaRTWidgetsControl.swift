//
//  pSTaRTWidgetsControl.swift
//  pSTaRTWidgets
//
//  Created by Kurt Frey on 04.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import WidgetKit
import SwiftUI
import AppIntents

struct StartScanControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.nitricware.pstart.control.scan") {
            ControlWidgetButton(action: StartScanIntent()) {
                Label("control.scan.label", systemImage: "barcode.viewfinder")
            }
        }
        .displayName("intent.startscan.title")
        .description("intent.startscan.description")
    }
}

struct ShowMapControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.nitricware.pstart.control.map") {
            ControlWidgetButton(action: ShowMapIntent()) {
                Label("control.map.label", systemImage: "map")
            }
        }
        .displayName("intent.showmap.title")
        .description("intent.showmap.description")
    }
}
