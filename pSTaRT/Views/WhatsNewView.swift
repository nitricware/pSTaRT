//
//  WhatsNewView.swift
//  pSTaRT
//
//  Created by Kurt Frey on 11.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppSettings.Key.onboardingLastVersion) private var onboardingLastVersion: String = AppSettings.Default.onboardingLastVersion
    
    var secondary: (() -> Void)? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("whatsnew.title")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 48)
                    .padding(.bottom, 24)
                
                VStack(alignment: .leading, spacing: 24) {
                    WhatsNewRowView(
                        symbolSystemName: "icloud",
                        symbolColor: .cyan,
                        title: String(localized: "whatsnew.v4.icloud.title", table: "WhatsNew"),
                        description: String(localized: "whatsnew.v4.icloud.description", table: "WhatsNew")
                    )
                    
                    WhatsNewRowView(
                        symbolSystemName: "map",
                        symbolColor: .pink,
                        title: String(localized: "whatsnew.v4.map.title", table: "WhatsNew"),
                        description: String(localized: "whatsnew.v4.map.description", table: "WhatsNew")
                    )
                    
                    WhatsNewRowView(
                        symbolSystemName: "siri",
                        symbolColor: .yellow,
                        title: String(localized: "whatsnew.v4.siri.title", table: "WhatsNew"),
                        description: String(localized: "whatsnew.v4.siri.description", table: "WhatsNew")
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 36)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 14) {
                if let secondary {
                    Button {
                        markSeen()
                        dismiss()
                        secondary()
                    } label: {
                        Text("whatsnew.tipjar")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)
                }
                
                Button {
                    markSeen()
                    dismiss()
                } label: {
                    Text("common.continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(.background)
        }
        .interactiveDismissDisabled()
    }
    
    private func markSeen() {
        let currentVersion = NWVersion(versionString: Bundle.main.appVersion)
        if currentVersion.compare(with: onboardingLastVersion) == .newer {
            onboardingLastVersion = currentVersion.version.string
        }
    }
}

struct WhatsNewRowView: View {
    let symbolSystemName: String
    let symbolColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbolSystemName)
                .font(.system(size: 28))
                .foregroundStyle(symbolColor)
                .frame(width: 35, alignment: .center)
                
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    WhatsNewView()
}
