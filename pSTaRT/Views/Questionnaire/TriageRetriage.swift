//
//  TriageRetriage.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 13.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI
import UIKit

struct TriageRetriage: View {
    @EnvironmentObject public var currentTriage: CurrentTriage
    @Environment(\.dismiss) private var dismiss
    public var saveOnInteraction: Bool = true
    
    var body: some View {
        VStack {
            Text("SELECT_TRIAGE_GROUP_NOW")
            
            let buttonWidth = (UIScreen.main.bounds.width - 30) / 4
            HStack (spacing: 10.0) {
                Button(action: {
                    save(.one)
                }) {
                    Text("I")
                        .frame(maxWidth: buttonWidth)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                
                Button(action: {
                    save(.two)
                }) {
                    Text("II")
                        .frame(maxWidth: buttonWidth)
                }
                .buttonStyle(.borderedProminent)
                .tint(.yellow)
                
                Button(action: {
                    save(.three)
                }) {
                    Text("III")
                        .frame(maxWidth: buttonWidth)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button(action: {
                    save(.four)
                }) {
                    Text("IV")
                        .frame(maxWidth: buttonWidth)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
    }
    
    func save(_ group: TriageGroups) {
        self.currentTriage.conclude(assign: group)
        if saveOnInteraction {
            self.currentTriage.appendTriage()
        }
    }
}

struct TriageRetriage_Previews: PreviewProvider {
    static var previews: some View {
        TriageRetriage()
            .previewLayout(.sizeThatFits)
    }
}
