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
        feedbackDone.notificationOccurred(.success)
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: custom functions
    
    func parseTriageNumber() {
        switch self.triageGroup {
        case 1:
            self.triageRoman = "I"
            self.triageColor = UIColor.red
            self.triageTextColor = UIColor.white
            self.triageText = NSLocalizedString("T1", comment: "")
            break
        case 2:
            self.triageRoman = "II"
            self.triageColor = UIColor.yellow
            self.triageTextColor = UIColor.black
            self.triageText = NSLocalizedString("T2", comment: "")
            break
        case 3:
            self.triageRoman = "III"
            self.triageColor = UIColor.green
            self.triageTextColor = UIColor.white
            self.triageText = NSLocalizedString("T3", comment: "")
            break
        case 4:
            self.triageRoman = "IV"
            self.triageColor = UIColor.blue
            self.triageTextColor = UIColor.white
            self.triageText = NSLocalizedString("T4", comment: "")
            break
        default:
            self.triageRoman = "X"
        }
    }
}
