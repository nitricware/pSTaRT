//
//  DemoData.swift
//  pSTaRT
//
//  Created by Kurt Frey on 15.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

#if DEBUG

import Foundation
import CoreData
import CoreLocation

enum DemoData {
    static let center = CLLocationCoordinate2D(latitude: 48.31595766153394, longitude: 14.320471953178302)

    struct DemoPerson {
        let id: String
        /// Offset from `center` in metres.
        let north: Double
        let east: Double
        /// Triage start, minutes before the data is inserted. ← adjust times here
        let minutesAgo: Double
        /// Triage history: group + seconds after triage start. Last entry = current group.
        let history: [(group: TriageGroup, after: TimeInterval)]
    }

    static let persons: [DemoPerson] = [
        .init(id: "EMERGENCY-002", north: -56.4, east: -20.5, minutesAgo: 24,
              history: [(.two, 50), (.one, 17 * 60)]),          // re-triaged II → I
        .init(id: "EMERGENCY-003", north:  61.3, east: -51.4, minutesAgo: 22, history: [(.two, 45)]),
        .init(id: "EMERGENCY-004", north: -30.8, east:  84.6, minutesAgo: 20, history: [(.three, 30)]),
        .init(id: "EMERGENCY-005", north:  -8.6, east: -23.5, minutesAgo: 18, history: [(.one, 40)]),
        .init(id: "EMERGENCY-006", north:  65.8, east:  23.9, minutesAgo: 15, history: [(.three, 35)]),
        .init(id: "EMERGENCY-007", north: -39.0, east:  22.5, minutesAgo: 13, history: [(.two, 50)]),
        .init(id: "EMERGENCY-008", north:  24.6, east: -91.8, minutesAgo: 10, history: [(.four, 25)]),
        .init(id: "EMERGENCY-009", north:  29.5, east:  -5.2, minutesAgo:  7,
              history: [(.three, 30), (.two, 4 * 60)]),          // re-triaged III → II
        .init(id: "EMERGENCY-010", north: -84.7, east:   7.4, minutesAgo:  4, history: [(.three, 30)]),
    ]

    /// Metres → coordinate (good enough for a few hundred metres).
    static func coordinate(north: Double, east: Double) -> CLLocationCoordinate2D {
        let metersPerDegreeLat = 111_132.0
        let metersPerDegreeLon = 111_320.0 * cos(center.latitude * .pi / 180)
        return CLLocationCoordinate2D(latitude: center.latitude + north / metersPerDegreeLat,
                                      longitude: center.longitude + east / metersPerDegreeLon)
    }

    /// Deletes ALL persons and inserts the demo persons. Times are relative to `now`.
    static func replaceAll(in context: NSManagedObjectContext, now: Date = .now) throws {
        try context.deleteAll()

        for demo in persons {
            let start = now.addingTimeInterval(-demo.minutesAgo * 60)
            let coordinate = coordinate(north: demo.north, east: demo.east)

            let person = Persons(context: context)
            person.plsNumber = demo.id
            person.startTime = start
            person.endTime = start.addingTimeInterval(demo.history.first?.after ?? 0)
            person.lat = NSNumber(value: coordinate.latitude)
            person.lon = NSNumber(value: coordinate.longitude)
            person.preciseLocation = true
            person.triageGroup = demo.history.last?.group.rawValue ?? TriageGroup.unidentified.rawValue

            for entry in demo.history {
                let triage = Triages(context: context)
                triage.person = person
                triage.group = entry.group.rawValue
                triage.date = start.addingTimeInterval(entry.after)
            }
        }

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

#endif
