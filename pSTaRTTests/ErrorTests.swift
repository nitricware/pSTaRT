//
//  ErrorTests.swift
//  pSTaRT
//
//  Created by Kurt Frey on 06.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import CodeScanner
import Foundation
import Testing
@testable import pSTaRT

@Suite("pSTaRTErrors")
struct ErrorTests {

    static let allErrors: [pSTaRTErrors] = [
        .dbFetchError, .dbDeleteError, .dbUpdateError, .dbSaveError,
        .csvExportError,
        .emptyInput, .duplicateID, .identificationTooLong,
        .purchaseUnableToPurchase,
        .cameraAccessDenied, .scanUnsupportedCodes, .scanFailed,
    ]

    private static func reminder(_ error: pSTaRTErrors) {
        switch error {
        case .dbFetchError, .dbDeleteError, .dbUpdateError, .dbSaveError,
             .csvExportError,
             .emptyInput, .duplicateID, .identificationTooLong,
             .purchaseUnableToPurchase,
             .cameraAccessDenied, .scanUnsupportedCodes, .scanFailed:
            break
        }
    }

    @Test("Every error has a translated message", arguments: allErrors)
    func hasMessage(_ error: pSTaRTErrors) throws {
        let message = try #require(error.errorDescription)
        #expect(!message.isEmpty)
        #expect(!message.hasPrefix("error."), "Translation missing: \(message)")
    }

    @Test func scanErrorMapping() {
        #expect(pSTaRTErrors(scanError: .permissionDenied) == .cameraAccessDenied)
        #expect(pSTaRTErrors(scanError: .badOutput) == .scanUnsupportedCodes)
        #expect(pSTaRTErrors(scanError: .badInput) == .scanFailed)
        #expect(pSTaRTErrors(scanError: .initError(CocoaError(.featureUnsupported))) == .scanFailed)
    }
}
