//
//  TriageGroupCounter.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 19.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct TriageGroupCounter: View {
    
    @FetchRequest var fetchRequest: FetchedResults<Persons>
    
    init(triageGroup: TriageGroups = .unidentified) {
        self.triageGroup = TriageGroup(triageGroup)
        self._fetchRequest = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \Persons.objectID,
                    ascending: true
                )
            ],
            predicate: NSPredicate(format: "triageGroup = %d", self.triageGroup.intVal),
            animation: .default
        )
    }
    
    private var triageGroup: TriageGroup = TriageGroup(.unidentified)
    
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
