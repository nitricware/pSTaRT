//
//  BarcodeType.swift
//  pSTaRT
//
//  Created by Kurt Frey on 02.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import AVFoundation

enum BarcodeType: String, CaseIterable, Identifiable {
    // 1D
    case code39, code39Mod43, code93, code128, ean8, ean13, upce, itf14, interleaved2of5, codabar
    case gs1DataBar, gs1DataBarExpanded, gs1DataBarLimited
    // 2D
    case qr, microQR, dataMatrix, pdf417, microPDF417, aztec

    var id: Self { self }

    var objectType: AVMetadataObject.ObjectType {
        switch self {
        case .code39: .code39
        case .code39Mod43: .code39Mod43
        case .code93: .code93
        case .code128: .code128
        case .ean8: .ean8
        case .ean13: .ean13
        case .upce: .upce
        case .itf14: .itf14
        case .interleaved2of5: .interleaved2of5
        case .codabar: .codabar
        case .gs1DataBar: .gs1DataBar
        case .gs1DataBarExpanded: .gs1DataBarExpanded
        case .gs1DataBarLimited: .gs1DataBarLimited
        case .qr: .qr
        case .microQR: .microQR
        case .dataMatrix: .dataMatrix
        case .pdf417: .pdf417
        case .microPDF417: .microPDF417
        case .aztec: .aztec
        }
    }

    var isTwoDimensional: Bool {
        switch self {
        case .qr, .microQR, .dataMatrix, .pdf417, .microPDF417, .aztec: true
        default: false
        }
    }

    /// Product names – not localized.
    var displayName: String {
        switch self {
        case .code39: "Code 39"
        case .code39Mod43: "Code 39 Mod 43"
        case .code93: "Code 93"
        case .code128: "Code 128"
        case .ean8: "EAN-8"
        case .ean13: "EAN-13"
        case .upce: "UPC-E"
        case .itf14: "ITF-14"
        case .interleaved2of5: "Interleaved 2 of 5"
        case .codabar: "Codabar"
        case .gs1DataBar: "GS1 DataBar"
        case .gs1DataBarExpanded: "GS1 DataBar Expanded"
        case .gs1DataBarLimited: "GS1 DataBar Limited"
        case .qr: "QR Code"
        case .microQR: "Micro QR"
        case .dataMatrix: "Data Matrix"
        case .pdf417: "PDF417"
        case .microPDF417: "MicroPDF417"
        case .aztec: "Aztec"
        }
    }
    
    static func decode(_ raw: String) -> Set<BarcodeType> {
        let types = Set(raw.split(separator: ",").compactMap { BarcodeType(rawValue: String($0)) })
        return types.isEmpty ? [.code39] : types
    }

    static func encode(_ types: Set<BarcodeType>) -> String {
        allCases.filter(types.contains).map(\.rawValue).joined(separator: ",")
    }
}
