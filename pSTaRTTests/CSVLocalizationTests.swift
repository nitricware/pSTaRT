//
//  CSVLocalizationTests.swift
//  pSTaRT
//
//  Created by Kurt Frey on 06.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import Foundation
import Testing
@testable import pSTaRT

@Suite("CSV-Export - Localization")
struct CSVLocalizationTests {

    static let languages = Bundle.main.localizations.filter { $0 != "Base" }

    private func localized(_ key: String, in lang: String) throws -> String {
        let path = try #require(Bundle.main.path(forResource: lang, ofType: "lproj"))
        let bundle = try #require(Bundle(path: path))
        let missing = "__MISSING__"
        let value = bundle.localizedString(forKey: key, value: missing, table: nil)
        try #require(value != missing, "\(key) fehlt in \(lang)")
        return value
    }

    @Test func appHasExpectedLanguages() {
        #expect(Set(Self.languages).isSuperset(of: ["en", "de"]))
    }

    @Test("Exported file contains header row with 7 columns.", arguments: languages)
    func exportHeaderHasSevenColumns(_ lang: String) throws {
        let header = try localized("EXPORT_COLS", in: lang)
        #expect(header.components(separatedBy: ";").count == 7)
    }

    @Test("sanitizeFilename does not change defaultSuffix (= defaultSuffix is compatible).", arguments: languages)
    func defaultSuffixSurvivesSanitizing(_ lang: String) throws {
        let suffix = try localized("CSV_DEFAULT_SUFFIX", in: lang)
        #expect(CSVManager.sanitizeFilename(suffix) == suffix)
    }
}
