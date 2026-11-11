//
//  Overview.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 10.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI
import CoreData
import WhatsNewKit

struct Overview: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let router = AppRouter.shared
    @State private var isShowingScanner = false
    @State private var deferredAction: AppAction?
    
    @State private var sheet: OverviewSheet?
    
    @State public var identification: String = ""
    
    var body: some View {
        VStack {
            IdentificationInput(identification: $identification,
                                isShowingScanner: $isShowingScanner,
                                onScannerDismiss: runDeferred) { id in
                sheet = .triage(TriageSession(identification: id))
            }
            
            TriageGroupsOverview()
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .toolbar {
            MainToolbar(sheet: $sheet, showsPersonsListLink: horizontalSizeClass == .compact)
        }
        .navigationTitle("pSTaRT")
        .padding()
        .frame(
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .top
        )
        .sheet(item: $sheet, onDismiss: runDeferred) { sheet in
            switch sheet {
            case .settings: SettingsView()
            case .tipJar:   TipJar()
            case .map:
                NavigationStack {
                    PersonsMapView()
                        .toolbar { CloseToolbarItem() }   // only here – when pushed from PersonsList it has a back button
                }
            case .triage(let session):
                NavigationStack {
                    TriageQuestionnaireView(session: session) {
                        self.sheet = nil
                        identification = ""
                    }
                }
                .presentationSizing(.page)
                .interactiveDismissDisabled()
            }
        }
        .onChange(of: router.pending, initial: true) { _, action in
            guard let action else { return }
            router.pending = nil
            if case .triage = sheet { return }
            if action == .scan && isShowingScanner { return }
            if sheet != nil || isShowingScanner {
                deferredAction = action
                sheet = nil
                isShowingScanner = false
            } else {
                perform(action)
            }
        }
        .whatsNewSheet()
    }
    
    private func perform(_ action: AppAction) {
        switch action {
        case .scan: isShowingScanner = true
        case .map:  sheet = .map
        }
    }

    private func runDeferred() {
        guard let action = deferredAction else { return }
        deferredAction = nil
        perform(action)
    }
}

struct Overview_Previews: PreviewProvider {
    static var previews: some View {
        Overview()
    }
}
