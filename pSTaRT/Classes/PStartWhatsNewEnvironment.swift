//
//  PStartWhatsNewEnvironment.swift
//  pSTaRT
//
//  Created by Kurt Frey on 11.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import WhatsNewKit

final class PStartWhatsNewEnvironment: WhatsNewEnvironment {
    init(collection: WhatsNewCollectionProvider) {
        super.init(
            versionStore: UserDefaultsWhatsNewVersionStore(),
            whatsNewCollection: collection.whatsNewCollection
        )
    }

    override func whatsNew() -> WhatsNew? {
        let actionLaunch = MainActor.assumeIsolated { AppRouter.shared.didReceiveAction }
        return actionLaunch ? nil : super.whatsNew()
    }
}
