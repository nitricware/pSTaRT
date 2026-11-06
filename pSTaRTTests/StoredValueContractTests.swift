//
//  StoredValueContractTests.swift
//  pSTaRT
//
//  Created by Kurt Frey on 06.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import Foundation
import Testing
@testable import pSTaRT

@Suite("Stored values – don't change without a migration")
struct StoredValueContractTests {
    @Test func barcodeTypeRawValues() {
        #expect(Set(BarcodeType.allCases.map(\.rawValue)) == [
            "code39", "code39Mod43", "code93", "code128", "ean8", "ean13", "upce",
            "itf14", "interleaved2of5", "codabar",
            "gs1DataBar", "gs1DataBarExpanded", "gs1DataBarLimited",
            "qr", "microQR", "dataMatrix", "pdf417", "microPDF417", "aztec",
        ])
    }

    @Test func shortcutTypesMatchInfoPlist() throws {
        let items = try #require(Bundle.main.object(
            forInfoDictionaryKey: "UIApplicationShortcutItems") as? [[String: Any]])
        let types = Set(items.compactMap { $0["UIApplicationShortcutItemType"] as? String })

        #expect(types == [AppAction.scan.rawValue, AppAction.map.rawValue])
    }
}
