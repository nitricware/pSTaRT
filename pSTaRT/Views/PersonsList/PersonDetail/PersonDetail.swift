//
//  PersonDetail.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 12.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import MapKit

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
        ZStack(alignment: .bottom) {
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
                            TriageGroupIcon(triageGroup: TriageGroup(stored: person.triageGroup))
                                .frame(width: 28.0)
                            Text("TRIAGE_GROUP \(TriageGroup(stored: person.triageGroup).roman)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    if let lat = person.lat,
                       let lon = person.lon {
                        let mapCameraPostion = MapCameraPosition.region(
                            MKCoordinateRegion(
                                center: CLLocationCoordinate2D(
                                    latitude: lat.doubleValue,
                                    longitude: lon.doubleValue
                                ),
                                span: MKCoordinateSpan(latitudeDelta: 0.0006, longitudeDelta: 0.0006)
                            )
                        )
                        VStack() {
                            Text("INITIAL_LOCATION")
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                            Map(initialPosition: mapCameraPostion,interactionModes: []) {
                                Marker(
                                    person.plsNumber ?? "PERSON",
                                    systemImage: "cross.case",
                                    coordinate: CLLocationCoordinate2D(
                                        latitude: lat.doubleValue,
                                        longitude: lon.doubleValue
                                    )
                                )
                            }
                            .frame(height: 150)
                            if !person.preciseLocation {
                                Text("REDUCED_ACCURACY")
                            }
                        }
                    }
                }
                
                Section ("TRIAGE_HISTORY") {
                    ForEach(self.triages) { triage in
                        HStack {
                            TriageGroupIcon(triageGroup: TriageGroup(stored: triage.group))
                                .frame(width: 28.0)
                            Text(triage.date?.formatted() ?? "NO_DATE")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    }
                }
            }
            .safeAreaPadding(.bottom, 150)
            .navigationTitle("PERSON_DETAIL")
            
            GlassEffectContainer {
                TriageRetriage()
                    .padding(25)
                    .environmentObject(CurrentTriage(person: person))
            }
            .glassEffect()
            .padding()
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    delete()
                }) {
                    Image(systemName: "trash")
                }
            }
        }
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
    static var previews: some View {
        // 1. Get your preview context
        let context = PersistenceController.preview.container.viewContext
        
        // 2. Fetch the sample data you generated in your controller
        let fetchRequest: NSFetchRequest<Persons> = Persons.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        // 3. Try to get the first person, or fall back to creating a temporary one if the fetch fails
        let samplePerson = (try? context.fetch(fetchRequest))?.first ?? {
            let fallback = Persons(context: context)
            fallback.plsNumber = "Fallback Preview"
            fallback.startTime = Date()
            fallback.triageGroup = 1
            return fallback
        }()
        
        // 4. Pass the fetched sample person to your view
        return NavigationView {
            PersonDetail(person: samplePerson)
        }
        // 5. Inject the context into the environment so relationships can resolve correctly
        .environment(\.managedObjectContext, context)
    }
}
