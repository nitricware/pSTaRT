//
//  PersonListSection.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 12.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct PersonListSection: View {
    public var triageGroup: TriageGroup
    @FetchRequest var fetchRequest: FetchedResults<Persons>
    
    init(with group: TriageGroup) {
        self.triageGroup = group
        _fetchRequest = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \Persons.startTime,
                    ascending: true
                )
            ],
            predicate: NSPredicate(format: "triageGroup = %d", triageGroup.intVal),
            animation: .default
        )
    }
    
    var body: some View {
        Section("TRIAGEGROUP \(triageGroup.roman)") {
            if fetchRequest.count > 0 {
                ForEach(fetchRequest) { person in
                    NavigationLink(destination: PersonDetail(person: person)) {
                        Text(person.plsNumber ?? "AS 04 NONUM")
                    }
                }
            } else {
                Text("NO_PERSON")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

struct PersonListSection_Previews: PreviewProvider {
    static var previews: some View {
        PersonListSection(
            with: TriageGroup(.one)
        )
        .previewLayout(.sizeThatFits)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
