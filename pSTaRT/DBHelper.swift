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
    
    func savePLS(plsNo: String, start: Date, end: Date, triageNo: Int) {
        let newPatient = NSEntityDescription.insertNewObject(forEntityName: "PLSStorage", into: context)
        
        newPatient.setValue(plsNo, forKey: "plsNumber")
        newPatient.setValue(start, forKey: "startTime")
        newPatient.setValue(end , forKey: "endTime")
        newPatient.setValue(triageNo , forKey: "triageGroup")
        
        do {
            try context.save()
        } catch {
            print("Error")
        }
    }
    
    func fetchPersons(triageGroup: Int) throws -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PLSStorage")
        request.returnsObjectsAsFaults = false
        let sort = NSSortDescriptor(key: "startTime", ascending: false)
        request.sortDescriptors = [sort]
        let predicate = NSPredicate(format: "triageGroup == %d", triageGroup)
        request.predicate = predicate
        do {
            // Get the results into an array of NSManagedObjects
            let persons = try context.fetch(request) as! [NSManagedObject]
            // Return this array
            return persons
        } catch {
            print("Error")
            throw(pSTaRTErrors.dbFetchError)
        }
    }
    
    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PLSStorage")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try self.context.execute(deleteRequest)
            try self.context.save()
        } catch {
            print ("Error")
        }
    }
    
    func deletePerson(person: NSManagedObject) {
        context.delete(person)
        do {
            try context.save()
        } catch {
            print ("Error")
        }
    }
}
