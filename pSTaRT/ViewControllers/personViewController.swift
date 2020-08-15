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
    // MARK: fields
    
    var triagegroups:[[NSManagedObject?]] = [[],[],[],[]]
    var db: pSTaRTDBHelper = pSTaRTDBHelper()
    var tgo: TriageGroupOverviewViewController?
    
    // MARK: view controller overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = pSTaRTDBHelper()
        
        do {
            try triagegroups[0] = db.fetchPersons(for: 1)
            try triagegroups[1] = db.fetchPersons(for: 2)
            try triagegroups[2] = db.fetchPersons(for: 3)
            try triagegroups[3] = db.fetchPersons(for: 4)
        } catch {
            let ac: UIAlertController = createErrorAlert(with: "ERROR_FETCH")
            present(ac, animated: true)
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable. Deleting is also editing.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try db.deletePerson(person: triagegroups[indexPath.section][indexPath.row]!)
                triagegroups[indexPath.section].remove(at: indexPath.row)
                // Delete the row from the data source
                tgo!.populateNumbers()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                let ac: UIAlertController = createErrorAlert(with: "ERROR_DELETE")
                present(ac, animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TriageGroupOverviewViewController {
            tgo = vc
        }
    }
    
    // MARK: actions
    
    @IBAction func deleteAll(_ sender: Any) {
        let confirm: UIAlertController = createConfirmAlert(
            cancelAction: {
                print("User canceled delete all records.")
            }, confirmAction: {
                do {
                    try self.db.deleteAll()
                } catch {
                    let ac: UIAlertController = createErrorAlert(with: "ERROR_DELETE")
                    self.present(ac, animated: true)
                }
                self.tgo?.populateNumbers()
                self.triagegroups = [[],[],[],[]]
                self.tableView.reloadData()
            }
        )
        present(confirm, animated: true)
    }
    
    @IBOutlet weak var exportBarButtonItem: UIBarButtonItem!
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
                    if let popOver = activityVC.popoverPresentationController {
                        popOver.sourceView = self.view
                        popOver.barButtonItem = self.exportBarButtonItem
                    }
                    
                }
            }
        } catch {
            let ac: UIAlertController = createErrorAlert(with: "ERROR_EXPORT")
            present(ac, animated: true)
        }
    }
}
