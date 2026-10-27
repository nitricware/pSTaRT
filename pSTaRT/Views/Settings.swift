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
    @State private var fileNameRejection: Int = 0
    
    private var separator: String { filesuffix.isEmpty ? "" : "_" }
    
    var body: some View {
        NavigationStack {
            Form {
                Section (
                    header: Text("CSV_FILE_SUFFIX"),
                    footer: Text("CSV_FILE_SUFFIX_TOOLTIP")
                ) {
                    VStack {
                        HStack {
                            TextField("CSV_FILE_SUFFIX", text: $filesuffix)
                                .labelsVisibility(.visible)
                                .onChange(of: filesuffix) { _, newSuffix in
                                    let filtered = CSVManager.sanitizeFilename(newSuffix)
                                    
                                    if filtered != newSuffix {
                                        filesuffix = filtered
                                        fileNameRejection += 1
                                    }
                                }
                                .sensoryFeedback(.warning, trigger: fileNameRejection)
                        }
                        
                        Text("\(datePrefix)\(separator)**\(filesuffix)**.csv")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onAppear {
                                let df = DateFormatter()
                                df.locale = Locale(identifier: "en_US_POSIX")
                                df.dateFormat = UserDefaults.standard.string(forKey: AppSettings.Key.csvDatePrefix)
                                let date = Date()
                                datePrefix = df.string(from: date)
                            }
                    }
                }
                
                Section (
                    header: Text("SHARE_IMMEDIATELY_TITLE"),
                    footer: Text("SHARE_IMMEDIATELY_DESC")
                ) {
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
