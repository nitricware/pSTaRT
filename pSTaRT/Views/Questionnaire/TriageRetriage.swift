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
    
    // Once target is iOS 27+, this lays the groundwork for .alert(error, actions)
    @State private var errorMessage: Error?
    @State private var showsErrorAlert: Bool = false
    
    var body: some View {
        VStack {
            Text("SELECT_TRIAGE_GROUP_NOW")
            
            HStack (spacing: 10.0) {
                ForEach(TriageGroup.assignable) { group in
                    Button(action: {
                        do {
                            try save(group)
                        } catch {
                            showsErrorAlert.toggle()
                            errorMessage = error
                        }
                    }) {
                        Text(group.roman)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(group.color)
                    .alert(errorMessage?.localizedDescription ?? String(localized: "common.unknownError"), isPresented: $showsErrorAlert) {
                        Button("common.ok", role: .cancel) { }
                    }
                }
            }
        }
    }
    
    func save(_ group: TriageGroup) throws {
        self.currentTriage.conclude(assign: group)
        if saveOnInteraction {
            try self.currentTriage.appendTriage()
        }
    }
}

struct TriageRetriage_Previews: PreviewProvider {
    static var previews: some View {
        TriageRetriage()
            .previewLayout(.sizeThatFits)
    }
}
