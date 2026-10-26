//
//  Settings.swift
//  pSTaRT
//
//  Created by Kurt Frey on 25.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppSettings.Key.csvFileSuffix) var filesuffix: String = AppSettings.Default.csvFileSuffix
    @AppStorage(AppSettings.Key.shareImmediately) var shareimmediately: Bool = AppSettings.Default.shareImmediately
    @Binding var isShowingSettings: Bool
    @State private var datePrefix = "1990-02-19_23-00-00"
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack {
                        /*Text("CSV_FILE_SUFFIX")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)*/
                        HStack {
                            TextField("CSV_FILE_SUFFIX", text: $filesuffix)
                                .labelsVisibility(.visible)
                        }
                        
                        Text("\(datePrefix)_**\(filesuffix)**.csv")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onAppear {
                                let df = DateFormatter()
                                df.dateFormat = UserDefaults.standard.string(forKey: AppSettings.Key.csvDatePrefix)
                                let date = Date()
                                datePrefix = df.string(from: date)
                            }
                    }
                }
                
                Section (footer: Text("SHARE_IMMEDIATELY_DESC")) {
                    Toggle("SHARE_IMMEDIATELY", isOn: $shareimmediately)
                }
            }
            .navigationTitle(Text("SETTINGS"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        isShowingSettings.toggle()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            isShowingSettings: .constant(true)
        )
    }
}
