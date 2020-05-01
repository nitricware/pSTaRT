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
func createConfirmAlert(with confirmAction: @escaping () -> Void) -> UIAlertController {
    let ac = UIAlertController(
        title: NSLocalizedString("CONFIRM_HEADLINE", comment: "confirm headline"),
        message: NSLocalizedString("CONFIRM_BODY", comment: "confirm body"),
        preferredStyle: .actionSheet
    )
    
    ac.addAction(
        UIAlertAction(
            title: NSLocalizedString("OK", comment: "ok"),
            style: .destructive,
            handler: {
                (response) in
                confirmAction()
            }
        )
    )
    
    ac.addAction(
        UIAlertAction(
            title: NSLocalizedString("CANCEL", comment: "cancel"),
            style: .cancel,
            handler: nil
        )
    )
    
    return ac
}
