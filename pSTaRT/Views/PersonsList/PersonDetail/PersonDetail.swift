//
//  PersonDetail.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 12.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import Foundation
import SwiftUI

struct PersonDetail: View {
    public var person: Persons
    
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest public var triages: FetchedResults<Triages>
    
    
    init(person: Persons) {
        self.person = person

        _triages = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(
                    keyPath: \Triages.date,
                    ascending: false
                )
            ],
            predicate: NSPredicate(format: "person = %@", person),
            animation: .default
        )
    }
    
    var body: some View {
        List {
            Section {
                PersonDetailRow(caption: "IDENTIFICATION") {
                    Text(person.plsNumber ?? "4 AS NONUM")
                }
                PersonDetailRow(caption: "START_TRIAGE") {
                    Text((person.startTime ?? Date()).formatted())
                }
                PersonDetailRow(caption: "END_TRIAGE") {
                    Text((person.endTime ?? Date()).formatted())
                }
                PersonDetailRow(caption: "TRIAGEGROUP") {
                    HStack {
                        TriageGroupIcon(triageGroup: TriageGroup(Int(person.triageGroup)))
                            .frame(width: 28.0)
                        Text("TRIAGE_GROUP \(TriageGroup(Int(person.triageGroup)).roman)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            TriageRetriage()
            .environmentObject(CurrentTriage(person: person))
            .listRowBackground(Color.clear)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .padding(.bottom)
            
            Button("DELETE_PERSON", role: .destructive) {
                delete()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Section ("TRIAGE_HISTORY") {
                ForEach(self.triages) { triage in
                    HStack {
                        TriageGroupIcon(triageGroup: TriageGroup(Int(triage.group)))
                            .frame(width: 28.0)
                        Text(triage.date?.formatted() ?? "NO_DATE")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                }
            }
        }
        .navigationTitle("PERSON_DETAIL")
    }
    
    func delete() {
        let database = pSTaRTDBHelper()
        do {
            try database.deletePerson(person: self.person)
            self.dismiss()
        } catch {
            print ("delete error")
        }
    }
}

struct PersonDetail_Previews: PreviewProvider {
    static var person = Persons(context: PersistenceController.preview.container.viewContext)
    
    init() {
        PersonDetail_Previews.person.plsNumber = "4 AS PREVIEW101"
        PersonDetail_Previews.person.triageGroup = 1
        
    }
    static var previews: some View {
        NavigationView {
            PersonDetail(person: person)
        }
    }
}
