//
//  NWUtils.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 22.01.21.
//  Copyright © 2021 Kurt Höblinger. All rights reserved.
//

import Foundation
import UIKit

class NWUtils {
    
    /// Creates a simple alert box with 1 button
    /// - Parameters:
    ///   - title: Title of the alert
    ///   - message: Message of the alert
    ///   - dismiss: Text of the dismiss button
    ///   - dismissStyle: Style of the dismiss button. Default is default.
    /// - Returns: An UIAlertController that can be shown.
    static func createSimpleAlert(
        title: String,
        message: String,
        dismiss: String,
        dismissStyle: UIAlertAction.Style = .default
    ) -> UIAlertController {
        let alertController = self.createHeadAndBody(title: title, message: message)
        
        let dismissButton = UIAlertAction(title: dismiss, style: dismissStyle)
        alertController.addAction(dismissButton)
        
        return alertController
    }
    
    /// Creates an alert box with a confirm and a dismiss button.
    /// - Parameters:
    ///   - title: Title of the alert
    ///   - message: Message of the alert
    ///   - accept: Text of the accept button
    ///   - acceptStyle: Style of the accept button. Default is default.
    ///   - acceptAction: Event handler once the accept button was pressed.
    ///   - dismiss: Text of the dismiss button
    ///   - dismissStyle: Style of the dismiss button. Destructive is default.
    /// - Returns: An UIAlertController that can be shown.
    static func createConfirmAlert(
        title: String,
        message: String,
        accept: String,
        acceptStyle: UIAlertAction.Style = .default,
        acceptAction: @escaping ((UIAlertAction))->Void,
        dismiss: String,
        dismissStyle: UIAlertAction.Style = .destructive
    ) -> UIAlertController {
        let alertController = self.createHeadAndBody(title: title, message: message)
        
        let acceptButton = UIAlertAction(title: accept, style: acceptStyle, handler: acceptAction)
        alertController.addAction(acceptButton)
        
        let dismissButton = UIAlertAction(title: dismiss, style: dismissStyle)
        alertController.addAction(dismissButton)
        
        return alertController
    }
    
    /// Creates the message and title portion of the UIAlertController.
    /// - Parameters:
    ///   - title: Title of the alert
    ///   - message: Message of the alert
    /// - Returns: An UIAlertController for further modification.
    static private func createHeadAndBody(
        title: String,
        message: String
    ) -> UIAlertController {
        let device = UIScreen.main.traitCollection.userInterfaceIdiom
        var preferredStyle: UIAlertController.Style = .actionSheet
        
        if device == .pad {
            preferredStyle = .alert
        }
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: preferredStyle
        )
        
        return alertController
    }
}
