//
//  ViewController.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 15.11.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func scanPLS(_ sender: Any) {
        let scanner:ScannerView = ScannerView()
        scanner.delegate = self
        self.present(scanner, animated: true, completion: nil)
    }
    
    func scannerCanceled() {

    }
    
    func foundCode(code: String) {
        
    }
    
    func displayError(e: Error) {
        print(e)
        let ac = UIAlertController(title: NSLocalizedString("ERROR_HEADLINE", comment: ""), message: NSLocalizedString("ERROR_BODY", comment: ""), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(ac, animated: true)
    }

}

