//
//  DBHelper.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 16.02.20.
//  Copyright © 2020 Kurt Höblinger. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class pSTaRTDBHelper {
    var context: NSManagedObjectContext!
    
    /// Initializes the Helper Class and sets the context
    init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    /// Saves a person to the database
    /// - Parameters:
    ///   - plsNo: the entered PLS number
    ///   - start: start time of assessment
    ///   - end: end time of assessment
    ///   - triageNo: triage result
    func savePLS(plsNo: String, start: Date, end: Date, triageNo: Int16) throws -> PLSStorage {
        let newPerson = PLSStorage(context: self.context)
        
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
    
    func updateTriageGroup(pls: PLSStorage, group: Int) throws {
        pls.triageGroup = Int16(group)
        
        do {
            try context.save()
        } catch {
            throw pSTaRTErrors.dbUpdateError
        }
    }
    
    /// Fetches all persons or persons in the specified triage group.
    /// - Parameter triageGroup: the selected triage group. `nil` if any triage group
    func fetchPersons(for triageGroup: Int? = nil) throws -> [PLSStorage] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PLSStorage")
        request.returnsObjectsAsFaults = false
        
        let sort = NSSortDescriptor(key: "startTime", ascending: false)
        request.sortDescriptors = [sort]
        
        if let group = triageGroup {
            let predicate = NSPredicate(format: "triageGroup == %d", group)
            request.predicate = predicate
        }
        
        do {
            // Get the results into an array of NSManagedObjects
            let persons = try context.fetch(request) as! [PLSStorage]
            // Return this array
            return persons
        } catch {
            throw pSTaRTErrors.dbFetchError
        }
    }
    
    func getPersonCount() throws -> [Int] {
        var returnArray: [Int] = []
        do {
            let t1 = try fetchPersons(for: 1)
            returnArray.append(t1.count)
            let t2 = try fetchPersons(for: 2)
            returnArray.append(t2.count)
            let t3 = try fetchPersons(for: 3)
            returnArray.append(t3.count)
            let t4 = try fetchPersons(for: 4)
            returnArray.append(t4.count)
        } catch {
            throw pSTaRTErrors.dbFetchError
        }
        
        return returnArray
    }
    
    func isDuplicate(id: String) throws -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PLSStorage")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "plsNumber == %@", id)
        request.predicate = predicate
        
        do {
            // Get the results into an array of NSManagedObjects
            let persons = try context.fetch(request) as! [PLSStorage]
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PLSStorage")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        /*do {
            let result = try self.context.execute(deleteRequest) as? NSBatchDeleteResult

            let objectIDArray = result?.result as? [NSManagedObjectID]

            let changes = [NSDeletedObjectsKey : objectIDArray]

            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
            try self.context.save()
        } catch {
            throw pSTaRTErrors.dbDeleteError
        }*/
        
        do {
            try self.context.execute(deleteRequest)
            try self.context.save()
            self.context.reset()
            //(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            self.context.refreshAllObjects()
        } catch {
            throw pSTaRTErrors.dbDeleteError
        }
    }
    
    /// Deletes a single person
    /// - Parameter person: the person to delete
    func deletePerson(person: PLSStorage) throws {
        context.delete(person)
        do {
            try context.save()
        } catch {
            throw pSTaRTErrors.dbDeleteError
        }
    }
    
    /// Exports all records to a CSV file and returns the file name.
    func exportData() throws -> String? {
        // This is the foundation of the CSV file that will be saved - it contains the header
        var exportString = NSLocalizedString("EXPORT_COLS", comment: "column headings")
        // This is a blank row of the CSV file
        let exportLine = "%@;%@;%@;%d\n"
        
        // This DateFormatter is used throughout this function
        let df = DateFormatter()
        // TODO: localize the date format
        df.dateFormat = "EEEE, d MMM y - HH:mm:ss"
        
        do {
            // Get the results into an array of NSManagedObjects
            let persons = try self.fetchPersons()
            // Iterate over this array, and append the entries as a row to the CSV file
            for person in persons {
                let plsNumber = person.plsNumber!
                let startDate = person.startTime!
                let endDate = person.endTime!
                let triageGroup = person.triageGroup
                
                let dataLine = String(format: exportLine, plsNumber, df.string(from: startDate), df.string(from: endDate), triageGroup)
                
                exportString = exportString + dataLine
            }
            
            // The filename consists of a fixed string and the current date
            let file = String(format: NSLocalizedString("EXPORT_FILENAME", comment: "filename"), df.string(from: Date()))
            
            // Save the file to the documentDirectory of the App
            // TODO: either delete previous ones, move everything to iCloud or integrate a file viewer - I prefer 1
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(file)

                do {
                    try exportString.write(to: fileURL, atomically: false, encoding: .utf8)
                    // Everything succeeded, the file name is returned for further use.
                    return file
                } catch {
                    throw pSTaRTErrors.dbExportError
                }
            }
        } catch {
            throw pSTaRTErrors.dbFetchError
        }
        
        // Something went wrong along the way but didn't throw an error - return nil
        return nil
    }
}
