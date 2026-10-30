//
//  PersonsExtension.swift
//  pSTaRT
//
//  Created by Kurt Frey on 30.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import CoreData

extension Persons {
    static func predicate(in group: TriageGroup?, matching search: String = "") -> NSPredicate? {
        var predicates: [NSPredicate] = []
        if let group {
            predicates.append(NSPredicate(format: "triageGroup == %d", group.rawValue))
        }
        let search = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !search.isEmpty {
            predicates.append(NSPredicate(format: "plsNumber CONTAINS[cd] %@", search))
        }
        return predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    /// Persons in a triage group, oldest first. `nil` = all persons.
    static func fetchRequest(in group: TriageGroup?, matching search: String = "") -> NSFetchRequest<Persons> {
        let request = Persons.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Persons.startTime, ascending: true)]
        request.predicate = predicate(in: group, matching: search)
        return request
    }
}
