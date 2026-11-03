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
    
    @State private var sheet: OverviewSheet?
    
    @State public var identification: String = ""
    
    var body: some View {
        VStack {
            IdentificationInput(identification: $identification) { id in
                sheet = .triage(TriageSession(identification: id))
            }
            
            TriageGroupsOverview()
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .toolbar {
            MainToolbar(sheet: $sheet, showsPersonsListLink: horizontalSizeClass == .compact
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
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .settings: SettingsView()
            case .tipJar:   TipJar()
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
    }
}



struct Overview_Previews: PreviewProvider {
    static var previews: some View {
        Overview()
    }
}
