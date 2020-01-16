//
//  TriageGroupDisplay.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 16.11.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import UIKit

class TriageGroupDisplay: UIViewController {
    var triageGroup: Int = 0
    var triageRoman: String = ""
    var triageColor: UIColor = UIColor.green
    var triageTextColor: UIColor = UIColor.white
    var triageText: String = NSLocalizedString("T0", comment: "")
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        parseTriageNumber()
        triageGroupNumber.text = triageRoman
        triageGroupNumber.backgroundColor = triageColor
        triageGroupNumber.textColor = triageTextColor
        triageTextLabel.text = triageText
    }
    
    @IBOutlet weak var triageGroupNumber: UILabel!
    
    @IBOutlet weak var triageTextLabel: UILabel!
    
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
    
    @IBAction func newPatientPressed(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}
