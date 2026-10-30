//
//  NSManagedObjectContextExtension.swift
//  pSTaRT
//
//  Created by Kurt Frey on 29.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import Foundation
import CoreData

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
    
    func fetchPersons(for triageGroup: Int? = nil) throws -> [Persons] {
        let request = NSFetchRequest<Persons>(entityName: "Persons")
        request.relationshipKeyPathsForPrefetching = ["triages"]
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]

        if let group = triageGroup {
            request.predicate = NSPredicate(format: "triageGroup == %@", NSNumber(value: group))
        }

        do {
            return try self.fetch(request)
        } catch {
            throw pSTaRTErrors.dbFetchError
        }
    }
}
