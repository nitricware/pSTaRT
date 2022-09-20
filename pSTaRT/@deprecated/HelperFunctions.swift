//
//  HelperFunctions.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 01.05.20.
//  Copyright © 2020 Kurt Höblinger. All rights reserved.
//

import Foundation
import UIKit

func createErrorAlert(with msgIdentifier: String) -> UIAlertController {
    print("An error occured: " + msgIdentifier)
    
    let ac = UIAlertController(
        title: NSLocalizedString("ERROR_HEADLINE", comment: ""),
        message: NSLocalizedString(msgIdentifier, comment: ""),
        preferredStyle: .alert
    )
    
    ac.addAction(
        UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .default
        )
    )
    
    return ac
}


/// Creates a confirm alert  and performs the confirmAction completion handler.
/// - Parameter confirmAction: completion handler
func createConfirmAlert(headline: String = "CONFIRM_HEADLINE", body: String = "CONFIRM_BODY", confirm: String = "OK", cancel: String = "CANCEL", cancelAction: @escaping () -> Void, confirmAction: @escaping () -> Void) -> UIAlertController {
    let ac = UIAlertController(
        title: NSLocalizedString(headline, comment: "confirm headline"),
        message: NSLocalizedString(body, comment: "confirm body"),
        preferredStyle: .alert
    )
    
    ac.addAction(
        UIAlertAction(
            title: NSLocalizedString(confirm, comment: "ok"),
            style: .destructive,
            handler: {
                (response) in
                confirmAction()
            }
        )
    )
    
    ac.addAction(
        UIAlertAction(
            title: NSLocalizedString(cancel, comment: "cancel"),
            style: .cancel,
            handler: {
                (response) in
                cancelAction()
            }
        )
    )
    
    return ac
}
