//
//  PersonListSection.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 12.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI
import CoreData

struct PersonListSection: View {
    let triageGroup: TriageGroup
    let searchText: String
    @FetchRequest var persons: FetchedResults<Persons>
    
    init(with group: TriageGroup, searchText: String = "") {
        self.triageGroup = group
        self.searchText = searchText
        _persons = FetchRequest(fetchRequest: Persons.fetchRequest(in: group, matching: searchText), animation: .default)
    }
    
    var body: some View {
        Section("TRIAGEGROUP \(triageGroup.roman)") {
            if searchText.isEmpty || !persons.isEmpty {
                if !persons.isEmpty {
                    ForEach(persons) { person in
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
        .onChange(of: searchText) { _, newValue in
            persons.nsPredicate = Persons.predicate(in: triageGroup, matching: newValue)
        }
    }
}

struct PersonListSection_Previews: PreviewProvider {
    static var previews: some View {
        PersonListSection(
            with: .one
        )
        .previewLayout(.sizeThatFits)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
