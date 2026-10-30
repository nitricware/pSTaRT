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
    private let triageGroup: TriageGroup
    @FetchRequest var fetchRequest: FetchedResults<Persons>

    init(triageGroup: TriageGroup = .unidentified) {
        self.triageGroup = triageGroup
        _fetchRequest = FetchRequest(fetchRequest: Persons.fetchRequest(in: triageGroup), animation: .default)
    }
    
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
