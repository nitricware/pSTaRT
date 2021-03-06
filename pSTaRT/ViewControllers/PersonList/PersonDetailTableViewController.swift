//
//  PersonDetailTableViewController.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 07.02.21.
//  Copyright © 2021 Kurt Höblinger. All rights reserved.
//

import UIKit

class PersonDetailTableViewController: UITableViewController {
    
    public var person: PLSStorage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.plsNumber.text = person?.plsNumber ?? "???"
        
        let dateFormatter = DateFormatter()
        
        // TODO: localize
        dateFormatter.dateFormat = "EEEE, d MMM y - HH:mm:ss"
        if let personSure = person {
            self.fromDate.text = dateFormatter.string(from: personSure.startTime!)
            self.toDate.text = dateFormatter.string(from: personSure.endTime!)
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    @IBOutlet weak var plsNumber: UILabel!
    @IBOutlet weak var fromDate: UILabel!
    @IBOutlet weak var toDate: UILabel!
    @IBAction func reTriageOne(_ sender: Any) {
        changeTriageGroup(to: 1)
    }
    @IBAction func reTriageTwo(_ sender: Any) {
        changeTriageGroup(to: 2)
    }
    @IBAction func reTriageThree(_ sender: Any) {
        changeTriageGroup(to: 3)
    }
    @IBAction func reTriageFour(_ sender: Any) {
        changeTriageGroup(to: 4)
    }
    
    private func changeTriageGroup(to group: Int) {
        let db = pSTaRTDBHelper()
        if let tP = self.person {
            do {
                try db.updateTriageGroup(pls: tP, group: group)
            } catch {
                /*
                 Core Data Error
                 */
            }
        }
        print("done, closing")
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
}
