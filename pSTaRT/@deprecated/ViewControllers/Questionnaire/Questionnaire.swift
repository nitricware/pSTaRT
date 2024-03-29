//
//  Questionnaire.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 15.11.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import UIKit


/// Questionnaire ViewController displays the questions and handles the answers. Finally, it also saves the result to the database.
class Questionnaire: UIViewController {
    // MARK: fields
    var currentQuestion: Int  = 0
    var triageGroup: Int = 0
    
    var plsNumber: String = "XXXXX"
    
    var startDate: Date = Date()
    
    let feedbackLight = UIImpactFeedbackGenerator(style: .light)
    let feedbackDone = UINotificationFeedbackGenerator()
    
    var newPerson: Persons?
    
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
    
    // MARK: view controler overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedbackLight.prepare()
        feedbackDone.prepare()
        plsNumberLabel.text = plsNumber
    }
    
    /// Called right before the transition to the triage group display screen.
    /// - Parameters:
    ///   - segue
    ///   - sender
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        feedbackDone.notificationOccurred(.success)
        if(segue.identifier == "showTriageGroup") {
            let triageGroupDetail = (segue.destination as! TriageGroupDisplay)
            triageGroupDetail.triageGroup = self.triageGroup
            if let tP = newPerson {
                triageGroupDetail.triagedPerson = tP
            }
        }
    }
    
    // MARK: outlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var plsNumberLabel: UILabel!
    
    // MARK: actions
    
    @IBAction func closeQuestionnaire(_ sender: Any) {
        feedbackDone.notificationOccurred(.error)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesPressed(_ sender: Any) {
        feedbackLight.impactOccurred()
        
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
    
    @IBAction func noPressed(_ sender: Any) {
        feedbackLight.impactOccurred()
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
    
    // MARK: custom functions
    
    /// triageDone is called once the user gives a terminating answer.
    /// - Parameter group: The currently active triage group at the time of the terminating answer
    private func triageDone(group: Int) {
        /*
        Questionnaire finished,
        saving to database
        */
        let db = pSTaRTDBHelper()
        do {
           let newPerson = try db.savePLS(plsNo: plsNumber, start: startDate, end: Date(), triageNo: Int16(group))
            /*
             Displaying result
             */
            self.triageGroup = group
            self.newPerson = newPerson
            self.performSegue(withIdentifier: "showTriageGroup", sender: self)
        } catch {
            /*
             Core Data Error
             */
        }
    }
    
    
    /// continueQuestionnaire is called whenever the user gives a non-terminating answer.
    /// - Parameter current: The currently active triage group at the time of the terminating answer
    private func continueQuestionnaire(current: Int) {
        /*
         In order to alert the user that a new question popped up,
         because the last answer was non-terminating, the questionLabel
         is animated.
         */
        UIView.transition(with: questionLabel,
                          duration: 0.25,
                          options: .transitionFlipFromTop,
                          animations: {
                            [weak self] in
                            self?.questionLabel.text = NSLocalizedString(
                                self?.matches[current][1] as! String,
                                comment: ""
                            )
                            },
                          completion: nil)
        currentQuestion = current
        /*
         if matches[current][2] is 0, the current question's no-button will lead to triage
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
}
