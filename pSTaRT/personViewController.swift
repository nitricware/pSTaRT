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
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let db = pSTaRTDBHelper()
        db.context = appDelegate.persistentContainer.viewContext
        print ("context is set...")
        
        do {
            try triagegroups[0] = db.fetchPersons(triageGroup: 1)
            try triagegroups[1] = db.fetchPersons(triageGroup: 2)
            try triagegroups[2] = db.fetchPersons(triageGroup: 3)
            try triagegroups[3] = db.fetchPersons(triageGroup: 4)
        } catch {
            print("Error")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

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
        dateFormatter.dateFormat = "EEEE, d MMM y - HH:mm:ss"
        
        cell.plsNumber.text = plsNumber
        cell.startDate.text = dateFormatter.string(from: startDate)
        cell.endDate.text = dateFormatter.string(from: endDate)

        return cell
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        db.context = appDelegate.persistentContainer.viewContext
        db.deleteAll()
        triagegroups = [[],[],[],[]]
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            db.context = appDelegate.persistentContainer.viewContext
            db.deletePerson(person: triagegroups[indexPath.section][indexPath.row]!)
            triagegroups[indexPath.section].remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
