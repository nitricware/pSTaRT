//
//  NSManagedObjectContextExtension.swift
//  pSTaRT
//
//  Created by Kurt Frey on 29.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

extension NSManagedObjectContext {
    func deleteAll() throws {
        var deletedIDs: [NSManagedObjectID] = []

        for entity in ["Persons", "Triages"] {
            let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: entity))
            request.resultType = .resultTypeObjectIDs

            do {
                let result = try self.execute(request) as? NSBatchDeleteResult
                deletedIDs += result?.result as? [NSManagedObjectID] ?? []
            } catch {
                throw pSTaRTErrors.dbDeleteError
            }
        }

        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [NSDeletedObjectsKey: deletedIDs],
            into: [self]
        )
    }
    
    func deletePerson(person: Persons) throws {
        self.delete(person)
        do {
            try self.save()
        } catch {
            self.rollback()
            throw pSTaRTErrors.dbDeleteError
        }
    }
    
    func isDuplicate(id: String) throws -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Persons")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "plsNumber == %@", id)
        request.predicate = predicate
        
        do {
            return try self.count(for: request) > 0
        } catch {
            throw pSTaRTErrors.dbFetchError
        }
    }
    
    func fetchPersons(in group: TriageGroup? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Persons] {
        let request = Persons.fetchRequest(in: group)
        request.relationshipKeyPathsForPrefetching = ["triages"]
        
        if let sortDescriptors {
            request.sortDescriptors = sortDescriptors
        }
        
        do {
            return try fetch(request)
        } catch {
            throw pSTaRTErrors.dbFetchError
        }
    }
    
    func retriage(_ person: Persons, to group: TriageGroup) throws {
        let triage = Triages(context: self)
        triage.person = person
        triage.group = group.rawValue
        triage.date = .now
        person.triageGroup = group.rawValue

        do {
            try save()
        } catch {
            rollback()
            throw pSTaRTErrors.dbUpdateError
        }
    }
    
    func saveTriage(identification: String,
                    start: Date,
                    decisions: [TriageDecision],
                    location: CLLocation?,
                    isPrecise: Bool) throws {
        guard let latest = decisions.last else { return }

        let person = Persons(context: self)
        person.plsNumber = identification
        person.startTime = start
        person.endTime = .now
        person.triageGroup = latest.group.rawValue
        if let location {
            person.preciseLocation = isPrecise
            person.lat = NSNumber(value: location.coordinate.latitude)
            person.lon = NSNumber(value: location.coordinate.longitude)
        }
        for decision in decisions {
            let triage = Triages(context: self)
            triage.person = person
            triage.group = decision.group.rawValue
            triage.date = decision.date
        }

        do {
            try save()
        } catch {
            rollback()
            throw pSTaRTErrors.dbSaveError
        }
    }
    
    func validateNewIdentification(_ identification: String) throws {
        guard !identification.isEmpty else {
            throw pSTaRTErrors.emptyInput
        }
        if try isDuplicate(id: identification) {
            throw pSTaRTErrors.duplicateID
        }
    }
    
    
}
