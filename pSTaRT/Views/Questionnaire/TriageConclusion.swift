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
    @Binding public var isShowingTriage: Bool
    
    var body: some View {
        VStack {
            TriageGroupIcon(
                triageGroup: currentTriage.triageGroup.first!
            )
                .frame(width: 210, height: 210, alignment: .center)
                .environmentObject(currentTriage)
            Text(currentTriage.triageGroup.first!.description)
                .font(
                    .system(size: 36.0, weight: .bold, design: .rounded)
                )
                .frame(maxWidth: .infinity, maxHeight: 100.0, alignment: .center)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Button(action: {
                self.currentTriage.savePersonToDatabase()
                self.currentTriage.appendTriage()
                self.isShowingTriage.toggle()
            }) {
                Text("SELECT_GROUP \(currentTriage.triageGroup.first!.roman)")
                    .font(
                        .system(size: 36.0, weight: .bold, design: .default)
                    )
                    .frame(maxWidth: .infinity)
                
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .tint(currentTriage.triageGroup.first!.color)
        }
    }
}

struct TriageConclusion_Previews: PreviewProvider {
    static var previews: some View {
        TriageConclusion(
            isShowingTriage: .constant(true)
        )
        .previewLayout(.sizeThatFits)
        .environmentObject(CurrentTriage())
    }
}
