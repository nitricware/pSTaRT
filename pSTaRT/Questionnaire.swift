//
//  Questionnaire.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 15.11.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import UIKit

class Questionnaire: UIViewController {
    var currentQuestion: Int  = 0
    var triageGroup: Int = 0
    
    let matches: [[Any]] = [
        [UIColor.systemGreen,"WALK"],
        [UIColor.systemBlue,"DEAD"],
        [UIColor.systemRed,"AIRWAY"],
        [UIColor.systemRed,"BREATHING"],
        [UIColor.systemRed,"BLEEDING"],
        [UIColor.systemRed,"PULSE"],
        [UIColor.systemRed,"MOVEMENT"],
        [UIColor.systemRed,"ASPIRATION"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeQuestionnaire(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    @IBAction func yesPressed(_ sender: Any) {
        switch currentQuestion {
        case 0:
            /*
             0 = can walk -> T3
             */
            triageDone(group: 3)
        case 1:
            /*
             1 = is dead -> T4
             */
            triageDone(group: 4)
        case 2, 3, 5, 6:
            /*
             2 = patient can breath -> continue
             3 = breathing frequency > 10 and < 30 -> continue
             5 = has pulse -> continue
             6 = can follow orders -> continue
             */
            continueQuestionnaire(current: currentQuestion + 1)
        case 4, 7:
            /*
             4 = squiring bleeding
             7 = has inhalation trauma -> T1
             */
            triageDone(group: 1)
        default:
            /*
             ERROR
             */
            triageDone(group: 2)
        }
    }
    
    private func triageDone(group: Int) {
        print("Triage done ... assigned group: " + String(group))
        self.triageGroup = group
        self.performSegue(withIdentifier: "showTriageGroup", sender: self)
    }
    
    private func continueQuestionnaire(current: Int) {
        questionLabel.text = NSLocalizedString(matches[current][1] as! String, comment: "")
        animateLabel(label: questionLabel)
        currentQuestion = current
        /*
         if matches[current][2] is 0, the current questio's no-button will lead to triage
         else the yes button will
         */
        switch currentQuestion {
        case 0, 1, 4:
            noButton.backgroundColor = UIColor.systemOrange
            yesButton.backgroundColor = matches[current][0] as? UIColor
        case 7:
            noButton.backgroundColor = UIColor.systemYellow
            yesButton.backgroundColor = matches[current][0] as? UIColor
        default:
            yesButton.backgroundColor = UIColor.systemOrange
            noButton.backgroundColor = matches[current][0] as? UIColor
        }
    }
    
    @IBAction func noPressed(_ sender: Any) {
        switch currentQuestion {
        case 0, 1, 4:
            continueQuestionnaire(current: currentQuestion + 1)
        case 2, 3, 5, 6:
            /*
             2 = does not breath -> T1
             4 = breathing frequency < 10 or > 30 -> T1
             5 = no pulse -> T1
             */
            triageDone(group: 1)
        case 7:
            /*
             7 = no match -> T2
             */
            triageDone(group: 2)
        default:
            /*
             ERROR
             */
            triageDone(group: 2)
        }
    }
    
    func animateLabel(label: UILabel) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == "showTriageGroup") {
            let triageGroupDetail = (segue.destination as! TriageGroupDisplay)
            triageGroupDetail.triageGroup = self.triageGroup
        }
    }
}
