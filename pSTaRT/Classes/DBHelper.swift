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
    /// - Parameter triageGroup: the selected triage group. `nil` if any triage group
    func fetchPersons(for triageGroup: Int? = nil) throws -> [Persons] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Persons")
        request.returnsObjectsAsFaults = false
        
        let sort = NSSortDescriptor(key: "startTime", ascending: false)
        request.sortDescriptors = [sort]
        
        if let group = triageGroup {
            let predicate = NSPredicate(format: "triageGroup == %d", group)
            request.predicate = predicate
        }
        
        do {
            // Get the results into an array of NSManagedObjects
            let persons = try context.fetch(request) as! [Persons]
            // Return this array
            return persons
        } catch {
            throw pSTaRTErrors.dbFetchError
        }
    }
    
    @available(*, deprecated, message: "not needed anymore. SwiftUI")
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
    
    /// Exports all records to a CSV file and returns the file name.
    func exportData() throws -> String? {
        // This is the foundation of the CSV file that will be saved - it contains the header
        var exportString = NSLocalizedString("EXPORT_COLS", comment: "column headings")
        // This is a blank row of the CSV file
        // String; String; String; String; Int;
        let exportLine = "%@;%@;%@;%d"
        
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
                var triageLine = ""
                if let triages = person.triages {
                    for case let triage as Triages in triages.allObjects {
                        triageLine = ";" + triageLine + String(triage.group) + (triage.date?.formatted() ?? Date().formatted())
                    }
                }
                exportString = exportString + dataLine + triageLine + ";\n"
            }
            
            // The filename consists of a fixed string and the current date
            let file = String(format: NSLocalizedString("EXPORT_FILENAME", comment: "filename"), df.string(from: Date()))
            
            // Save the file to the documentDirectory of the App
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
    
    func provideCSV(completion: @escaping (URL?) -> Swift.Void) {
        // This is the foundation of the CSV file that will be saved - it contains the header
        var headerString = NSLocalizedString("EXPORT_COLS", comment: "column headings")
        var exportString = ""
        
        var returnURL: URL?
        // This is a blank row of the CSV file
        let exportLine = "%@;%@;%@;%d"
        
        // This DateFormatter is used throughout this function
        let df = DateFormatter()
        // TODO: localize the date format
        df.dateFormat = "EEEE, d MMM y - HH:mm:ss"
        
        var overallMaxTriageNum = 0
        
        do {
            // Get the results into an array of NSManagedObjects
            let persons = try self.fetchPersons()
            // Iterate over this array, and append the entries as a row to the CSV file
            for person in persons {
                var currentMaxTriageNum = 0
                let plsNumber = person.plsNumber!
                let startDate = person.startTime!
                let endDate = person.endTime!
                let triageGroup = person.triageGroup
                
                let dataLine = String(format: exportLine, plsNumber, df.string(from: startDate), df.string(from: endDate), triageGroup)
                var triageLine = ""
                
                if let triages = person.triages {
                    let sort = NSSortDescriptor(key: "date", ascending: true)
                    let triagesArray = triages.sortedArray(using: [sort])
                    for case let triage as Triages in triagesArray {
                        currentMaxTriageNum += 1
                        triageLine = triageLine + ";" + String(triage.group) + ";" + df.string(from: triage.date!)
                    }
                }
                
                if currentMaxTriageNum > overallMaxTriageNum {
                    overallMaxTriageNum = currentMaxTriageNum
                }
                
                exportString = exportString + dataLine + triageLine + "\n"
            }
            
            for i in 1 ... overallMaxTriageNum{
                headerString = headerString + ";" + NSLocalizedString("EXPORT_COL_TRIAGEDECISION", comment: "retriage")  + " \(i);" + NSLocalizedString("EXPORT_COL_DATE", comment: "date")
            }
            
            exportString = headerString + "\n" + exportString
            
            // The filename consists of a fixed string and the current date
            let file = String(format: NSLocalizedString("EXPORT_FILENAME", comment: "filename"), df.string(from: Date()))
            
            // TODO: Delete old Files
            // Save the file to the documentDirectory of the App
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(file)
                do {
                    try exportString.write(to: fileURL, atomically: false, encoding: .utf8)
                    // Everything succeeded, the file name is returned for further use.
                    self.currentCSV = fileURL
                    returnURL = self.currentCSV
                } catch {
                    print("Can't export.")
                }
            }
        } catch {
            print("Can't fetch.")
        }
        
        // Something went wrong along the way but didn't throw an error - return nil
        // TODO: add dummy file
        completion(returnURL)
    }
    
    public func removeCSV() {
        if let csvURL = currentCSV {
            do {
                try FileManager.default.removeItem(at: csvURL)
            } catch {
                print("couldn't delete")
            }
        }
    }
}
