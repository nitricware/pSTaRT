//
//  PersonsExtension.swift
//  pSTaRT
//
//  Created by Kurt Frey on 30.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import CoreData

extension Persons {
    /// Persons in a triage group, oldest first. `nil` = all persons.
    static func fetchRequest(in group: TriageGroup?) -> NSFetchRequest<Persons> {
        let request = Persons.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Persons.startTime, ascending: true)]
        if let group {
            request.predicate = NSPredicate(format: "triageGroup == %d", group.rawValue)
        }
        return request
    }
}
