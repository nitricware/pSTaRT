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
    @AppStorage(AppSettings.Key.scannerCodeTypes) private var storedTypes = AppSettings.Default.scannerCodeTypes
    @AppStorage(AppSettings.Key.identificationMaxLength) var identificationMaxLength: Int = AppSettings.Default.identificationMaxLength
    @AppStorage(AppSettings.Key.iCloudSyncEnabled) var iCloudSyncEnabled: Bool = AppSettings.Default.iCloudSyncEnabled
    @AppStorage(AppSettings.Key.pendingCloudPurge) var pendingCloudPurge: Bool = AppSettings.Default.pendingCloudPurge
    
    @State private var datePrefix = "1990-02-19_23-00-00"
    @State private var fileNameRejection: Int = 0
    
    private let syncActiveAtLaunch = PersistenceController.shared.isCloudSyncActive

    @State private var isShowingSyncAlert = false

    private func applySync(_ enable: Bool) {
        iCloudSyncEnabled = enable
        pendingCloudPurge = !enable
    }
    
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
                
                Section(
                    header:Text("SCANNER"),
                    footer: Text("SCANNER_CODE_TYPES_TOOLTIP")
                ) {
                    NavigationLink {
                        BarcodeTypesView()
                    } label: {
                        LabeledContent("SCANNER_CODE_TYPES") {
                            Text(BarcodeType.allCases
                                .filter(BarcodeType.decode(storedTypes).contains)
                                .map(\.displayName)
                                .formatted(.list(type: .and)))
                                .lineLimit(1)
                        }
                    }
                    
                }
                
                Section(
                    header: Text("settings.identificationMaxLength.Title"),
                    footer: Text("settings.identificationMaxLength.Desc")
                ) {
                    LabeledContent {
                        Stepper(value: $identificationMaxLength, in: 1...50) {
                            Text(identificationMaxLength.formatted(.number))
                        }
                    } label: {
                        Text("settings.identificationMaxLength.Label")
                    }
                }
                
                Section(
                    header: Text("settings.iCloudSync.title"),
                    footer: Text("settings.iCloudSync.description")
                ) {
                    Toggle("settings.iCloudSync.label", isOn: Binding(
                        get: { iCloudSyncEnabled },
                        set: { _ in isShowingSyncAlert = true }
                    ))
                    .alert(
                        iCloudSyncEnabled ? Text("settings.iCloudSync.confirmOff.title")
                                          : Text("settings.iCloudSync.confirmOn.title"),
                        isPresented: $isShowingSyncAlert
                    ) {
                        if iCloudSyncEnabled {
                            Button("settings.iCloudSync.confirmOff.button", role: .destructive) { applySync(false) }
                        } else {
                            Button("settings.iCloudSync.confirmOn.button", role: .confirm) { applySync(true) }
                        }
                        Button(role: .cancel) { }
                    } message: {
                        Text(iCloudSyncEnabled ? "settings.iCloudSync.confirmOff.message"
                                               : "settings.iCloudSync.confirmOn.message")
                    }

                    if iCloudSyncEnabled != syncActiveAtLaunch {
                        Label("settings.iCloudSync.restartRequired", systemImage: "arrow.clockwise")
                            .foregroundStyle(.orange)
                    }

                    if pendingCloudPurge && !iCloudSyncEnabled {
                        Label("settings.iCloudSync.pendingPurge", systemImage: "icloud.slash")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(Text("SETTINGS"))
            .toolbar { CloseToolbarItem() }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
