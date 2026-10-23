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
    var currentCSV: URL?
    
    /// Initializes the Helper Class and sets the context
    init() {
        //self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.context = PersistenceController.shared.container.viewContext
    }
    
    /// Saves a person to the database
    /// - Parameters:
    ///   - plsNo: the entered PLS number
    ///   - start: start time of assessment
    ///   - end: end time of assessment
    ///   - triageNo: triage result
    @available(*, deprecated, message: "This function is not required anymore with SwiftUI")
    func savePLS(plsNo: String, start: Date, end: Date, triageNo: Int16) throws -> Persons {
        let newPerson = Persons(context: self.context)
        
        newPerson.plsNumber = plsNo
        newPerson.startTime = start
        newPerson.endTime = end
        newPerson.triageGroup = triageNo
        
        do {
            try context.save()
            return newPerson
        } catch {
            throw pSTaRTErrors.dbDeleteError
        }
    }
    
    @available(*, deprecated, message: "This function is not required anymore with SwiftUI")
    func updateTriageGroup(pls: Persons, group: Int) throws {
        pls.triageGroup = Int16(group)
        
        do {
            try context.save()
        } catch {
            throw pSTaRTErrors.dbUpdateError
        }
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
        let fetchPersons = NSFetchRequest<NSFetchRequestResult>(entityName: "Persons")
        let deletePersons = NSBatchDeleteRequest(fetchRequest: fetchPersons)
        
        let fetchTriages = NSFetchRequest<NSFetchRequestResult>(entityName: "Triages")
        let deleteTriages = NSBatchDeleteRequest(fetchRequest: fetchTriages)
        
        do {
            try self.context.execute(deletePersons)
            try self.context.execute(deleteTriages)
            try self.context.save()
            self.context.reset()
            self.context.refreshAllObjects()
        } catch {
            throw pSTaRTErrors.dbDeleteError
        }
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
