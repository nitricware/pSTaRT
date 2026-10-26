//
//  TriageGroupCounter.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 19.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI
import CoreData

struct TriageGroupCounter: View {
    
    @FetchRequest var fetchRequest: FetchedResults<Persons>
    
    init(triageGroup: TriageGroup = .unidentified) {
        self.triageGroup = triageGroup
        self._fetchRequest = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \Persons.objectID,
                    ascending: true
                )
            ],
            predicate: NSPredicate(format: "triageGroup = %d", self.triageGroup.rawValue),
            animation: .default
        )
    }
    
    private let triageGroup: TriageGroup
    
    var body: some View {
        Text("NUM_PERSONS \(fetchRequest.count)")
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TriageGroupCounter_Previews: PreviewProvider {
    static var previews: some View {
        TriageGroupCounter(
            triageGroup: .one
        )
    }
}
