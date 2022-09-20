//
//  Overview.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 10.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct Overview: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject public var currentTriage: CurrentTriage = CurrentTriage()
    
    // MARK: Sheet States
    @State private var isShowingTriage: Bool = false
    @State private var isShowingPersonsList: Bool = false
    
    @State public var isShowingTipJar: Bool = false
    
    var body: some View {
        VStack {
            IdentificationInput(
                isShowingTriage: $isShowingTriage
            )
            .environmentObject(currentTriage)
            
            TriageGroupsOverview()
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea(.keyboard)
        .toolbar {
            MainToolbar(
                isShowingTipJar: $isShowingTipJar
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
            NavigationView {
                TriageQuestionnaire(
                    isShowingTriage: $isShowingTriage
                )
                .environmentObject(currentTriage)
                .interactiveDismissDisabled()
            }
        }
        .sheet(isPresented: $isShowingTipJar) {
            TipJar(isShowingTipJar: $isShowingTipJar)
        }
    }
}

struct Overview_Previews: PreviewProvider {
    static var previews: some View {
        Overview()
    }
}
