//
//  TriageGroupOverviewViewController.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 21.06.20.
//  Copyright © 2020 Kurt Höblinger. All rights reserved.
//

import UIKit

class TriageGroupOverviewViewController: UIViewController {
    let db = pSTaRTDBHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateNumbers()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var t1: UILabel!
    
    @IBOutlet weak var t2: UILabel!
    @IBOutlet weak var t3: UILabel!
    @IBOutlet weak var t4: UILabel!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewWillAppear(_ animated: Bool) {
        populateNumbers()
    }
    
    func populateNumbers() {
        do {
            let numbers = try db.getPersonCount()
            self.t1.text = String(numbers[0]) + " " + NSLocalizedString("PERSONS", comment: "persons")
            self.t2.text = String(numbers[1]) + " " + NSLocalizedString("PERSONS", comment: "persons")
            self.t3.text = String(numbers[2]) + " " + NSLocalizedString("PERSONS", comment: "persons")
            self.t4.text = String(numbers[3]) + " " + NSLocalizedString("PERSONS", comment: "persons")
        } catch {
            let ac = createErrorAlert(with: "ERROR_FETCH")
            present(ac, animated: true)
        }
    }

}
