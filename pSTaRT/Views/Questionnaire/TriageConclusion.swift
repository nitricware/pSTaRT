//
//  TriageConclusion.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 12.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct TriageConclusion: View {
    @EnvironmentObject public var currentTriage: CurrentTriage
    @Environment(NWLocationProvider.self) private var locationProvider
    @Binding public var isShowingTriage: Bool
    
    // Once target is iOS 27+, this lays the groundwork for .alert(error, actions)
    @State private var errorMessage: Error?
    @State private var showsErrorAlert: Bool = false
    
    var body: some View {
        VStack {
            TriageGroupIcon(
                triageGroup: currentTriage.currentGroup
            )
                .frame(width: 210, height: 210, alignment: .center)
                .environmentObject(currentTriage)
            Text(currentTriage.currentGroup.description)
                .font(
                    .system(size: 36.0, weight: .bold, design: .rounded)
                )
                .frame(maxWidth: .infinity, maxHeight: 100.0, alignment: .center)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Button(action: {
                do {
                    print(self.currentTriage.person)
                    try currentTriage.finish(at: locationProvider.location, isPrecise: locationProvider.isPrecise)
                    self.isShowingTriage.toggle()
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
        TriageConclusion(
            isShowingTriage: .constant(true)
        )
        .previewLayout(.sizeThatFits)
        .environmentObject(CurrentTriage(identification: "PREVIEW"))
        .environment(NWLocationProvider())
    }
}
