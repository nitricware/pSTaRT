//
//  TriageGroupDisplay.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 16.11.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import UIKit

/// Displays the result of the questionnaire.
class TriageGroupDisplay: UIViewController {
    // MARK: fields
    var triageGroup: Int = 0
    var triageRoman: String = ""
    var triageColor: UIColor = UIColor.green
    var triageTextColor: UIColor = UIColor.white
    var triageText: String = NSLocalizedString("T0", comment: "")
    let feedbackDone = UINotificationFeedbackGenerator()
    
    var triagedPerson: Persons?
    
    // MARK: view controller overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        // Do any additional setup after loading the view.
        feedbackDone.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        parseTriageNumber()
        triageGroupNumber.text = triageRoman
        triageGroupNumber.backgroundColor = triageColor
        triageGroupNumber.textColor = triageTextColor
        triageTextLabel.text = triageText
    }
    
    // MARK: outlets
    
    @IBOutlet weak var triageGroupNumber: UILabel!
    
    @IBOutlet weak var triageTextLabel: UILabel!
    
    // MARK: actions
    
    
    @IBAction func newPatientPressed(_ sender: Any) {
        self.closeQuestionnaire()
    }
    
    @IBAction func changeGroupToOne(_ sender: Any) {
        changeTriageGroup(to: 1)
        self.closeQuestionnaire()
    }
    @IBAction func changeGroupToTwo(_ sender: Any) {
        changeTriageGroup(to: 2)
        self.closeQuestionnaire()
    }
    @IBAction func changeGroupToThree(_ sender: Any) {
        changeTriageGroup(to: 3)
        self.closeQuestionnaire()
    }
    @IBAction func changeGroupToFour(_ sender: Any) {
        changeTriageGroup(to: 4)
        self.closeQuestionnaire()
    }
    
    
    // MARK: custom functions
    
    func closeQuestionnaire() {
        feedbackDone.notificationOccurred(.success)
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func changeTriageGroup(to group: Int) {
        let db = pSTaRTDBHelper()
        if let tP = self.triagedPerson {
            do {
                try db.updateTriageGroup(pls: tP, group: group)
            } catch {
                /*
                 Core Data Error
                 */
            }
        }
        
    }
    
    func parseTriageNumber() {
        switch self.triageGroup {
        case 1:
            self.triageRoman = "I"
            self.triageColor = UIColor.systemRed
            self.triageTextColor = UIColor.white
            self.triageText = NSLocalizedString("T1", comment: "")
            break
        case 2:
            self.triageRoman = "II"
            self.triageColor = UIColor.systemYellow
            self.triageTextColor = UIColor.black
            self.triageText = NSLocalizedString("T2", comment: "")
            break
        case 3:
            self.triageRoman = "III"
            self.triageColor = UIColor.systemGreen
            self.triageTextColor = UIColor.white
            self.triageText = NSLocalizedString("T3", comment: "")
            break
        case 4:
            self.triageRoman = "IV"
            self.triageColor = UIColor.systemBlue
            self.triageTextColor = UIColor.white
            self.triageText = NSLocalizedString("T4", comment: "")
            break
        default:
            self.triageRoman = "X"
        }
    }
}
