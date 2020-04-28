//
//  ViewController.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 15.11.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    let feedbackLight = UIImpactFeedbackGenerator(style: .light)
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedbackLight.prepare()
        feedbackGenerator.prepare()
        plsNumberInput.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    @IBOutlet weak var plsNumberInput: UITextField!
    
    
    /// Launches the PLS barcode Scanner
    /// - Parameter sender
    @IBAction func launchScanner(_ sender: Any) {
        let scannerView = Bundle.main.loadNibNamed("ScannerView", owner: self, options: nil)?.first as! ScannerViewController
        scannerView.delegate = self
        self.present(scannerView, animated: true, completion: nil)
    }
    
    func foundCode(code: String) {
        UIView.transition(with: self.plsNumberInput,
        duration: 0.25,
        options: .transitionFlipFromTop,
        animations: {
          [weak self] in
          self?.plsNumberInput.text = code
          },
        completion: nil)
    }
    
    
    func shake(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        
        view.layer.add(animation, forKey: "position")
        // Send haptic feedback
        feedbackGenerator.notificationOccurred(.error)
    }
    
    func displayError(e: Error) {
        print(e)
        let ac = UIAlertController(title: NSLocalizedString("ERROR_HEADLINE", comment: ""), message: NSLocalizedString("ERROR_BODY", comment: ""), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(ac, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        feedbackLight.impactOccurred()
        if (segue.identifier == "startQuestionnaire") {
            let questionnaire = (segue.destination as! Questionnaire)
            questionnaire.plsNumber = plsNumberInput.text ?? "XXXXX"
            self.plsNumberInput.text = ""
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "startQuestionnaire") {
            if let text = plsNumberInput.text, text.isEmpty {
                self.shake(view: plsNumberInput)
                return false
            }
        }
        return true
    }
}

