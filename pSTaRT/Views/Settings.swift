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

    @Binding var isShowingSettings: Bool
    @State private var datePrefix = "1990-02-19_23-00-00"
    @State private var fileNameRejection: Int = 0
    
    /// The value the user wants to switch to; `nil` = no alert.
    @State private var requestedSync: Bool?
    private let syncActiveAtLaunch = PersistenceController.shared.isCloudSyncActive

    /// The toggle only asks – nothing is written until the user confirms.
    private var syncBinding: Binding<Bool> {
        Binding(
            get: { iCloudSyncEnabled },
            set: { requestedSync = $0 }
        )
    }

    private var isShowingSyncAlert: Binding<Bool> {
        Binding(
            get: { requestedSync != nil },
            set: { if !$0 { requestedSync = nil } }
        )
    }

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
                    Toggle("settings.iCloudSync.label", isOn: syncBinding)
                        .alert(
                            requestedSync == true
                                ? Text("settings.iCloudSync.confirmOn.title")
                                : Text("settings.iCloudSync.confirmOff.title"),
                            isPresented: isShowingSyncAlert,
                            presenting: requestedSync
                        ) { enable in
                            if enable {
                                Button("settings.iCloudSync.confirmOn.button") { applySync(true) }
                            } else {
                                Button("settings.iCloudSync.confirmOff.button", role: .destructive) { applySync(false) }
                            }
                            Button("CANCEL", role: .cancel) { }
                        } message: { enable in
                            Text(enable ? "settings.iCloudSync.confirmOn.message" : "settings.iCloudSync.confirmOff.message")
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
