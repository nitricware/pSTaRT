//
//  TriageConclusion.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 12.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI
import CoreData

struct TriageConclusion: View {
    @Environment(TriageSession.self) private var currentTriage
    @Environment(NWLocationProvider.self) private var locationProvider
    @Environment(\.managedObjectContext) private var viewContext
    let onClose: () -> Void
    
    // Once target is iOS 27+, this lays the groundwork for .alert(error, actions)
    @State private var errorMessage: Error?
    @State private var showsErrorAlert: Bool = false
    
    var body: some View {
        VStack {
            TriageGroupIcon(
                triageGroup: currentTriage.currentGroup
            )
                .frame(width: 210, height: 210, alignment: .center)
            Text(currentTriage.currentGroup.description)
                .font(
                    .system(size: 36.0, weight: .bold, design: .rounded)
                )
                .frame(maxWidth: .infinity, maxHeight: 100.0, alignment: .center)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Button(action: {
                do {
                    try currentTriage.finish(in: viewContext,
                                                 at: locationProvider.location,
                                                 isPrecise: locationProvider.isPrecise)
                    onClose()
                } catch {
                    showsErrorAlert.toggle()
                    errorMessage = error
                }
            }) {
                Text("SELECT_GROUP \(currentTriage.currentGroup.roman)")
                    .font(
                        .system(size: 36.0, weight: .bold, design: .default)
                    )
                    .frame(maxWidth: .infinity)
                
            }
            .buttonStyle(.glassProminent)
            .tint(currentTriage.currentGroup.color)
        }
        .alert(errorMessage?.localizedDescription ?? String(localized: "common.unknownError"), isPresented: $showsErrorAlert) {
            Button("common.ok", role: .cancel) { }
        }
    }
}

struct TriageConclusion_Previews: PreviewProvider {
    static var previews: some View {
        TriageConclusion() {  }
        .previewLayout(.sizeThatFits)
        .environment(TriageSession(identification: "PREVIEW"))
        .environment(NWLocationProvider())
    }
}
