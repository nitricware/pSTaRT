//
//  WhatsNewCollectionProvider.swift
//  pSTaRT
//
//  Created by Kurt Frey on 11.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//



import SwiftUI
import WhatsNewKit

extension pSTaRTApp: WhatsNewCollectionProvider {
    var whatsNewCollection: WhatsNewCollection {
        WhatsNew(
            version: "4.0.0",
            title: .init(text: .init(String(localized: "whatsnew.title"))),
            features: [
                .pstart("map", "whatsnew.v4.map"),
                .pstart("icloud", "whatsnew.v4.sync"),
                .pstart("shortcuts", "whatsnew.v4.shortcuts")
            ],
            primaryAction: .init(
                title: .init(String(localized: "whatsnew.continue")),
                hapticFeedback: .notification(.success)
            ),
            secondaryAction: .init(
                title: .init(String(localized: "whatsnew.tipjar")),
                hapticFeedback: .selection,
                action: .present { TipJar() }
            )
        )
    }
}

private extension WhatsNew.Feature {
    static func pstart(_ symbol: String, _ key: String) -> Self {
        .init(image: .init(systemName: symbol),
              title: .init(String(localized: .init("\(key).title"))),
              subtitle: .init(String(localized: .init("\(key).subtitle"))))
    }
}
