//
//  pSTaRTErrors.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 16.02.20.
//  Copyright © 2020 Kurt Höblinger. All rights reserved.
//

import Foundation

enum pSTaRTErrors: LocalizedError {
    case dbFetchError
    case dbDeleteError
    case dbUpdateError
    
    var errorDescription: String? {
        switch self {
        case .dbFetchError: return String(localized: "error.dbFetch.description", table: "Errors")
        case .dbDeleteError: return String(localized: "error.dbDelete.description", table: "Errors")
        case .dbUpdateError: return String(localized: "error.dbUpdate.description", table: "Errors")
        }
    }
}
