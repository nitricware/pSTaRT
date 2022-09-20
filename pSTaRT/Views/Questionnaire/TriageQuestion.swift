//
//  TriageQuestion.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 12.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct TriageQuestion: View {
    @EnvironmentObject public var currentTriage: CurrentTriage
    
    var body: some View {
        VStack {
            Text(currentTriage.currentQuestion)
                .font(
                    .system(size: 36.0, weight: .bold, design: .rounded)
                )
                .frame(maxWidth: .infinity, maxHeight: 100.0, alignment: .center)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Button(action: {
                self.currentTriage.yes()
            }) {
                Text("YES")
                    .font(
                        .system(size: 36.0, weight: .bold, design: .default)
                    )
                    .frame(maxWidth: .infinity)
                
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .tint(currentTriage.yesColor)
            
            Button(action: {
                self.currentTriage.no()
            }) {
                Text("NO")
                    .font(
                        .system(size: 36.0, weight: .bold, design: .default)
                    )
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .tint(currentTriage.noColor)
        }
    }
}

struct TriageQuestion_Previews: PreviewProvider {
    static var previews: some View {
        TriageQuestion()
            .previewLayout(.sizeThatFits)
            .environmentObject(CurrentTriage())
    }
}
