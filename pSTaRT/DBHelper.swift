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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
    }
    
    
    /// Saves a person to the database
    /// - Parameters:
    ///   - plsNo: the entered PLS number
    ///   - start: start time of assessment
    ///   - end: end time of assessment
    ///   - triageNo: triage result
    func savePLS(plsNo: String, start: Date, end: Date, triageNo: Int) throws {
        let newPatient = NSEntityDescription.insertNewObject(forEntityName: "PLSStorage", into: context)
        
        newPatient.setValue(plsNo, forKey: "plsNumber")
        newPatient.setValue(start, forKey: "startTime")
        newPatient.setValue(end , forKey: "endTime")
        newPatient.setValue(triageNo , forKey: "triageGroup")
        
        do {
            try context.save()
        } catch {
            throw pSTaRTErrors.dbDeleteError
        }
    }
    
    func fetchPersons(for triageGroup: Int? = nil) throws -> [NSManagedObject] {
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
            let persons = try context.fetch(request) as! [NSManagedObject]
            // Return this array
            return persons
        } catch {
            throw pSTaRTErrors.dbFetchError
        }
    }
    
    func deleteAll() throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PLSStorage")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try self.context.execute(deleteRequest)
            try self.context.save()
        } catch {
            throw pSTaRTErrors.dbDeleteError
        }
    }
    
    func deletePerson(person: NSManagedObject) throws {
        context.delete(person)
        do {
            try context.save()
        } catch {
            throw pSTaRTErrors.dbDeleteError
        }
    }
    
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
                let plsNumber = person.value(forKey: "plsNumber") as! String
                let startDate = person.value(forKey: "startTime") as! Date
                let endDate = person.value(forKey: "endTime") as! Date
                let triageGroup = person.value(forKey: "triageGroup") as! Int
                
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
            throw(pSTaRTErrors.dbFetchError)
        }
        
        // Something went wrong along the way but didn't throw an error - return nil
        return nil
    }
}
