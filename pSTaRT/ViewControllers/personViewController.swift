//
//  personViewController.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 16.02.20.
//  Copyright © 2020 Kurt Höblinger. All rights reserved.
//

import UIKit
import CoreData

class personViewController: UITableViewController {
    var triagegroups:[[NSManagedObject?]] = [[],[],[],[]]
    var db: pSTaRTDBHelper = pSTaRTDBHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = pSTaRTDBHelper()
        
        do {
            try triagegroups[0] = db.fetchPersons(triageGroup: 1)
            try triagegroups[1] = db.fetchPersons(triageGroup: 2)
            try triagegroups[2] = db.fetchPersons(triageGroup: 3)
            try triagegroups[3] = db.fetchPersons(triageGroup: 4)
        } catch {
            // TODO: display alert
            print("Error")
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "pencil")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return triagegroups[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("TRIAGEGROUP", comment: "triagegroup") + " " + String(section + 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath) as! personCell
        
        let entry = triagegroups[indexPath.section][indexPath.row]
        
        let plsNumber = entry?.value(forKey: "plsNumber") as! String
        let startDate = entry?.value(forKey: "startTime") as! Date
        let endDate = entry?.value(forKey: "endTime") as! Date
        
        let dateFormatter = DateFormatter()
        
        // TODO: localize
        dateFormatter.dateFormat = "EEEE, d MMM y - HH:mm:ss"
        
        cell.plsNumber.text = plsNumber
        cell.startDate.text = dateFormatter.string(from: startDate)
        cell.endDate.text = dateFormatter.string(from: endDate)

        return cell
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        db.deleteAll()
        triagegroups = [[],[],[],[]]
        self.tableView.reloadData()
    }
    
    @IBAction func exportData(_ sender: Any) {
        do {
            if let filename = try db.exportData() {
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = dir.appendingPathComponent(filename)
                    /*
                     Prepare and show the share sheet
                     */
                    let objectsToShare = [fileURL]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
        } catch {
            // TODO: display alert
            print("Error")
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable. Deleting is also editing.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            db.deletePerson(person: triagegroups[indexPath.section][indexPath.row]!)
            triagegroups[indexPath.section].remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
