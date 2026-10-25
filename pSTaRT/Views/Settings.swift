//
//  Settings.swift
//  pSTaRT
//
//  Created by Kurt Frey on 25.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("csvexport.filesuffix") var filesuffix: String = NSLocalizedString("CSV_DEFAULT_SUFFIX", comment: "")
    @AppStorage("csvexport.shareimmediately") var shareimmediately: Bool = true
    @Binding var isShowingSettings: Bool
    var body: some View {
        Form {
            Section {
                VStack {
                    Text("CSV_FILE_SUFFIX")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Text("2026-01-01_13-56-01_")
                            .foregroundStyle(Color.secondary)
                        TextField("CSV_FILE_SUFFIX", text: $filesuffix)
                            .labelsVisibility(.visible)
                        Text(".csv")
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            
            Section (footer: Text("SHARE_IMMEDIATELY_DESC")) {
                Toggle("SHARE_IMMEDIATELY", isOn: $shareimmediately)
            }
        }
    }
}

#Preview {
    SettingsView(
        isShowingSettings: .constant(true)
    )
}
