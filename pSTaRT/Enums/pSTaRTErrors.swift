//
//  pSTaRTErrors.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 16.02.20.
//  Copyright © 2020 Kurt Höblinger. All rights reserved.
//

import Foundation

enum pSTaRTErrors: LocalizedError {
    // MARK: Database errors
    case dbFetchError
    case dbDeleteError
    case dbUpdateError
    
    // MARK: CSV Errors
    case csvExportError
    
    // MARK: Input Check Errors
    
    case emptyInput
    case duplicateID
    
    // MARK: IAP Errors
    
    case purchaseUnableToPurchase
    
    var errorDescription: String? {
        switch self {
            case .dbFetchError: return String(localized: "error.dbFetch.description", table: "Errors")
            case .dbDeleteError: return String(localized: "error.dbDelete.description", table: "Errors")
            case .dbUpdateError: return String(localized: "error.dbUpdate.description", table: "Errors")
            
            case .csvExportError: return String(localized: "error.csvExport.description", table: "Errors")
            
            case .emptyInput: return String(localized: "error.emptyInput.description", table: "Errors")
            case .duplicateID: return String(localized: "error.duplicateID.description", table: "Errors")
            
            case .purchaseUnableToPurchase: return String(localized: "error.purchaseUnableToPurchase.description", table: "Errors")
        }
    }
}
