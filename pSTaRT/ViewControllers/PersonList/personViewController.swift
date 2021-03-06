//
//  personViewController.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 16.02.20.
//  Copyright © 2020 Kurt Höblinger. All rights reserved.
//

import UIKit
import CoreData

/*
 an extions improves readability.
 This extension houses the NSFetchedResultsController which handles the animations
 when data is deleted and so on.
 */
extension personViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .automatic)
        default:
            // TODO: proper default implementation
            print("uh oh...")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            default:
                // TODO: proper default implementation
                print("uh oh...")
        }
    }
}

class personViewController: UITableViewController {
    // MARK: fields

    var db: pSTaRTDBHelper = pSTaRTDBHelper()
    var tgo: TriageGroupOverviewViewController?
    private var selectedPLS: PLSStorage?
    
    var nsfetchedresultscontroller: NSFetchedResultsController<NSFetchRequestResult>!
    
    // MARK: view controller overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = true
        
        // TODO: move the creation of the fetch request into pSTaRTDBHelper
        //let db = pSTaRTDBHelper()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "pencil")
        
        /*
         we'll prepare the fetch request that conatins all the datasets from the database
         and hand it over to the nsfetchedresultscontroller which then handles animations
         */
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PLSStorage")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "triageGroup", ascending: true),
            NSSortDescriptor(key: "plsNumber", ascending: true)
        ]
        
        nsfetchedresultscontroller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext,
            sectionNameKeyPath: "triageGroup", cacheName: nil
        )
        
        nsfetchedresultscontroller.delegate = self
        
        do {
            /*
             this "links" the nsfetchedresultscontroller to the database
             actually, it links it to the context. see deleteAll() for more...
             */
            try nsfetchedresultscontroller.performFetch()
        } catch {
            print("Error while fetching with NSFetchedResultsController")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return nsfetchedresultscontroller.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (nsfetchedresultscontroller.sections?[section])?.numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = nsfetchedresultscontroller.sections?[section].name
        return NSLocalizedString("TRIAGEGROUP", comment: "triagegroup") + " " + title!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath) as! personCell
        
        let entry = nsfetchedresultscontroller.object(at: indexPath) as! PLSStorage
        //let entry = triagegroups[indexPath.section][indexPath.row]
        
        let plsNumber = entry.plsNumber
        let startDate = entry.startTime
        let endDate = entry.endTime
        
        let dateFormatter = DateFormatter()
        
        // TODO: localize
        dateFormatter.dateFormat = "EEEE, d MMM y - HH:mm:ss"
        
        cell.plsNumber.text = plsNumber
        cell.startDate.text = dateFormatter.string(from: startDate!)
        cell.endDate.text = dateFormatter.string(from: endDate!)
        cell.pls = entry

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable. Deleting is also editing.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                //let person = nsfetchedresultscontroller.object(at: indexPath)
                try db.deletePerson(person: nsfetchedresultscontroller.object(at: indexPath) as! PLSStorage)
                //triagegroups[indexPath.section].remove(at: indexPath.row)
                // Delete the row from the data source
                tgo!.populateNumbers()
                //tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                let ac: UIAlertController = createErrorAlert(with: "ERROR_DELETE")
                present(ac, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPLS = (nsfetchedresultscontroller.object(at: indexPath) as! PLSStorage)
        
        //performSegue(withIdentifier: "showPersonDetail", sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        print(self.selectedPLS)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("preparing...")
        if (segue.identifier == "showPersonDetail") {
            let personDetailTableViewController = (segue.destination as! PersonDetailTableViewController)
            let sendingCell = sender as! personCell
            personDetailTableViewController.person = sendingCell.pls
        } else {
            if let vc = segue.destination as? TriageGroupOverviewViewController {
                tgo = vc
            }
        }
    }
    
    // MARK: actions
    
    @IBAction func deleteAll(_ sender: Any) {
        let confirm: UIAlertController = createConfirmAlert(
            cancelAction: {
                print("User canceled delete all records.")
            }, confirmAction: {
                DispatchQueue.main.async {
                    do {
                        try self.db.deleteAll()
                        try self.nsfetchedresultscontroller.performFetch()
                        
                        /*
                         deleteAll performs a batchDeleteRequest which does not use the context.
                         Therefor the NSFetchedResultsController is not informed about the changes.
                         We have to manually reload the date and can't use the animations of the table view.
                         
                         This transition animates the batch delete nicely.
                         */

                        UIView.transition(with: self.tableView,
                                          duration: 0.35,
                                          options: .transitionCrossDissolve,
                                          animations: { self.tableView.reloadData() })
                    } catch {
                        let ac: UIAlertController = createErrorAlert(with: "ERROR_DELETE")
                        self.present(ac, animated: true)
                    }
                    self.tgo?.populateNumbers()
                }
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
