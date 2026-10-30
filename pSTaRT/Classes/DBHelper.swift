//
//  DBHelper.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 16.02.20.
//  Copyright © 2020 Kurt Höblinger. All rights reserved.
//

import Foundation
import CoreData

class pSTaRTDBHelper {
    var context: NSManagedObjectContext!
    
    /// Initializes the Helper Class and sets the context
    init() {
        self.context = PersistenceController.shared.container.viewContext
    }
    
    /// Fetches all persons or persons in the specified triage group.
    /// - Parameters:
    ///   - triageGroup: the selected triage group. `nil` if any triage group
    ///   - context: the context to fetch in. Must be called on that context's queue
    ///     (e.g. inside `context.perform`), and the returned objects must stay there.
    static func fetchPersons(for triageGroup: Int? = nil, in context: NSManagedObjectContext) throws -> [Persons] {
        let request = NSFetchRequest<Persons>(entityName: "Persons")
        request.returnsObjectsAsFaults = false
        // Load all triages in one extra query instead of one fault per person.
        request.relationshipKeyPathsForPrefetching = ["triages"]
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]

        if let group = triageGroup {
            request.predicate = NSPredicate(format: "triageGroup == %@", NSNumber(value: group))
        }

        do {
            return try context.fetch(request)
        } catch {
            throw pSTaRTErrors.dbFetchError
        }
    }
    
    func isDuplicate(id: String) throws -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Persons")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "plsNumber == %@", id)
        request.predicate = predicate
        
        do {
            // Get the results into an array of NSManagedObjects
            let persons = try context.fetch(request) as! [Persons]
            // Return this array
            if persons.count > 0 {
                return true
            }
        } catch {
            throw pSTaRTErrors.dbFetchError
        }
            
        return false
    }
    
    /// Deletes all persons
    func deleteAll() throws {
        var deletedIDs: [NSManagedObjectID] = []

        for entity in ["Persons", "Triages"] {
            let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: entity))
            request.resultType = .resultTypeObjectIDs

            do {
                let result = try context.execute(request) as? NSBatchDeleteResult
                deletedIDs += result?.result as? [NSManagedObjectID] ?? []
            } catch {
                throw pSTaRTErrors.dbDeleteError
            }
        }

        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [NSDeletedObjectsKey: deletedIDs],
            into: [context]
        )
    }
    
    /// Deletes a single person
    /// - Parameter person: the person to delete
    func deletePerson(person: Persons) throws {
        context.delete(person)
        do {
            try context.save()
        } catch {
            throw pSTaRTErrors.dbDeleteError
        }
    }
}
