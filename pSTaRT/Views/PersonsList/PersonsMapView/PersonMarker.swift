//
//  PersonMarker.swift
//  pSTaRT
//
//  Created by Kurt Frey on 03.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import SwiftUI
import MapKit
import CoreData

struct PersonMarker: MapContent, Identifiable {
    let person: Persons

    /// The group is part of the identity: a retriage replaces the marker, so the map shows the new colour.
    struct ID: Hashable {
        let object: NSManagedObjectID
        let group: Int16
    }
    var id: ID { ID(object: person.objectID, group: person.triageGroup) }

    var body: some MapContent {
        if let coordinate = person.coordinate {
            Marker(person.plsNumber ?? String(localized: "common.unknown"),
                   systemImage: "cross.case",
                   coordinate: coordinate)
                .tint(TriageGroup(stored: person.triageGroup).color)
        }
    }
}
