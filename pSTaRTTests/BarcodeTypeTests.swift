//
//  BarcodeTypeTests.swift
//  pSTaRT
//
//  Created by Kurt Frey on 06.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import Testing
@testable import pSTaRT

@Suite("BarcodeType – scanner setting")
struct BarcodeTypeTests {

    @Test func decodeKnownTypes() {
        #expect(BarcodeType.decode("qr,code128") == [.qr, .code128])
    }

    @Test("Nothing usable falls back to Code 39", arguments: ["", "foo", ",,", "QR"])
    func decodeFallsBackToCode39(_ raw: String) {
        #expect(BarcodeType.decode(raw) == [.code39])
    }

    @Test func decodeIgnoresUnknownEntries() {
        #expect(BarcodeType.decode("qr,foo,ean13") == [.qr, .ean13])
    }

    @Test func roundTripAllTypes() {
        let all = Set(BarcodeType.allCases)
        #expect(BarcodeType.decode(BarcodeType.encode(all)) == all)
    }

    @Test(arguments: BarcodeType.allCases)
    func roundTripSingleType(_ type: BarcodeType) {
        #expect(BarcodeType.decode(BarcodeType.encode([type])) == [type])
    }

    @Test func encodeUsesStableOrder() {
        #expect(BarcodeType.encode([.qr, .code39]) == "code39,qr")
    }

    @Test func emptySelectionReadsBackAsCode39() {
        #expect(BarcodeType.encode([]) == "")
        #expect(BarcodeType.decode("") == [.code39])
    }

    @Test func defaultSettingDecodesToCode39() {
        #expect(BarcodeType.decode(AppSettings.Default.scannerCodeTypes) == [.code39])
    }

    @Test func twoDimensionalTypes() {
        #expect(Set(BarcodeType.allCases.filter(\.isTwoDimensional)) ==
                [.qr, .microQR, .dataMatrix, .pdf417, .microPDF417, .aztec])
    }
}
