//
//  Overview.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 10.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI
import CoreData

struct Overview: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var activeSession: TriageSession?
    
    // MARK: Sheet States
    @State private var isShowingSettings: Bool = false
    
    @State public var isShowingTipJar: Bool = false
    
    @State public var identification: String = ""
    
    var body: some View {
        VStack {
            IdentificationInput(identification: $identification) { id in
                activeSession = TriageSession(identification: id)
            }
            
            TriageGroupsOverview()
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .toolbar {
            MainToolbar(
                isShowingTipJar: $isShowingTipJar,
                isShowingSettings: $isShowingSettings,
                showsPersonsListLink: horizontalSizeClass == .compact
            )
        }
        .navigationTitle("pSTaRT")
        .padding()
        .frame(
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .top
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(item: $activeSession) { session in
            NavigationStack {
                TriageQuestionnaireView(session: session) {
                    activeSession = nil
                    identification = ""
                }
            }
            .presentationSizing(.page)
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $isShowingTipJar) {
            TipJar(isShowingTipJar: $isShowingTipJar)
        }
        .sheet(isPresented: $isShowingSettings, content: {
            SettingsView(isShowingSettings: $isShowingSettings)
        })
    }
}

struct Overview_Previews: PreviewProvider {
    static var previews: some View {
        Overview()
    }
}
