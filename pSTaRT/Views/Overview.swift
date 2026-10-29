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
    
    // MARK: Sheet States
    @State private var isShowingTriage: Bool = false
    @State private var isShowingSettings: Bool = false
    
    @State public var isShowingTipJar: Bool = false
    
    @State public var identification: String = ""
    
    var body: some View {
        VStack {
            IdentificationInput(
                isShowingTriage: $isShowingTriage,
                identification: $identification
            )
            
            TriageGroupsOverview()
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea(.keyboard)
        .toolbar {
            MainToolbar(
                isShowingTipJar: $isShowingTipJar,
                isShowingSettings: $isShowingSettings
            )
        }
        .navigationTitle("pSTaRT")
        .padding()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .sheet(isPresented: $isShowingTriage) {
            NavigationStack {
                TriageQuestionnaireView(
                    isShowingTriage: $isShowingTriage,
                    identification: $identification
                )
            }
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
