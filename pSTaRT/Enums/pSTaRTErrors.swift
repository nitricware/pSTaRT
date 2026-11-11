//
//  pSTaRTErrors.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 16.02.20.
//  Copyright © 2020 Kurt Höblinger. All rights reserved.
//

import Foundation
import CodeScanner

enum pSTaRTErrors: LocalizedError {
    // MARK: Database errors
    case dbFetchError
    case dbDeleteError
    case dbUpdateError
    case dbSaveError
    
    // MARK: CSV Errors
    case csvExportError
    
    // MARK: Input Check Errors
    
    case emptyInput
    case duplicateID
    case identificationTooLong
    
    // MARK: IAP Errors
    
    case purchaseUnableToPurchase
    
    // MARK: Scanner Errors
    case cameraAccessDenied
    case scanUnsupportedCodes
    case scanFailed
    
    // MARK: Sync and Backup Errors
    case excludeFromBackupFailed
    
    init(scanError: ScanError) {
        switch scanError {
        case .permissionDenied:     self = .cameraAccessDenied
        case .badOutput:            self = .scanUnsupportedCodes
        case .badInput, .initError: self = .scanFailed
        }
    }
    
    var errorDescription: String? {
        switch self {
            case .dbFetchError: return String(localized: "error.dbFetch.description", table: "Errors")
            case .dbDeleteError: return String(localized: "error.dbDelete.description", table: "Errors")
            case .dbUpdateError: return String(localized: "error.dbUpdate.description", table: "Errors")
            case .dbSaveError: return String(localized: "error.dbSave.description", table: "Errors")
            
            case .csvExportError: return String(localized: "error.csvExport.description", table: "Errors")
            
            case .emptyInput: return String(localized: "error.emptyInput.description", table: "Errors")
            case .duplicateID: return String(localized: "error.duplicateID.description", table: "Errors")
            case .identificationTooLong: return String(localized: "error.identificationTooLong.description", table: "Errors")
            
            case .purchaseUnableToPurchase: return String(localized: "error.purchaseUnableToPurchase.description", table: "Errors")
            
            case .cameraAccessDenied: return String(localized: "error.cameraAccessDenied.description", table: "Errors")
            case .scanUnsupportedCodes: return String(localized: "error.scanUnsupportedCodes.description", table: "Errors")
            case .scanFailed: return String(localized: "error.scanFailed.description", table: "Errors")
            case .excludeFromBackupFailed: return String(localized: "error.excludeFromBackupFailed.description", table: "Errors")
        }
    }
}
