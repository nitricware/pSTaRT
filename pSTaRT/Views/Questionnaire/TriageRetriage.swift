//
//  TriageRetriage.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 13.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct TriageRetriage: View {
    /// This is an explanation for future me: This is a closure.
    /// So you can integrate this View in a parent View like so:
    ///
    /// ```
    /// TriageRetriage {
    ///     somefunc($0)
    /// }
    /// ```
    ///
    /// In this view you then call onSelect(value) and the parent
    /// View executes what it had stored in the closure. That's
    /// smart.
    ///
    /// Thrown errors are caught in this View.
    let onSelect: (TriageGroup) throws -> Void
    
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
                            try onSelect(group)
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
                }
            }
        }
        .alert(errorMessage?.localizedDescription ?? String(localized: "common.unknownError"), isPresented: $showsErrorAlert) {
            Button("common.ok", role: .cancel) { }
        }
    }
}

struct TriageRetriage_Previews: PreviewProvider {
    static var previews: some View {
        TriageRetriage { _ in }
            .previewLayout(.sizeThatFits)
    }
}
