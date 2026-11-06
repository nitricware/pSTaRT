//
//  CSVManagerTests.swift
//  pSTaRT
//
//  Created by Kurt Frey on 06.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import Foundation
import Testing
@testable import pSTaRT

@Suite("CSVManager – helpers")
struct CSVManagerTests {

    private func quoted(_ s: String) -> String { "\"\(s)\"" }

    @Test("Plain values are only wrapped in quotes",
          arguments: ["abc", "", "4 AS 12345", "a;b", "12", "-5", "-12.5", "+5"])
    func plainValues(_ input: String) {
        #expect(CSVManager.escapeField(input) == quoted(input))
    }

    @Test("Formulas get a leading ' so spreadsheet apps treat them as text",
          arguments: ["=SUM(A1:A3)", "+43 664 123", "-x", "@SUM(A1)", "\tabc", "\rabc"])
    func formulasAreNeutralized(_ input: String) {
        #expect(CSVManager.escapeField(input) == quoted("'" + input))
    }

    @Test func quotesAreDoubled() {
        #expect(CSVManager.escapeField(#"a"b"#) == #""a""b""#)
    }

    @Test func formulaWithQuotes() {
        #expect(CSVManager.escapeField(#"=HYPERLINK("x")"#) == #""'=HYPERLINK(""x"")""#)
    }

    @Test(arguments: [
        ("Triage-File",      "Triage-File"),
        ("Triage Datei",     "TriageDatei"),
        ("Übung_1",          "bung_1"),
        ("../etc/passwd",    "etcpasswd"),
        (#"a/b\c:d*e?f"#,    "abcdef"),
        ("Einsatz 😀 2026",  "Einsatz2026"),
        ("",                 ""),
    ])
    func sanitize(_ input: String, expected: String) {
        #expect(CSVManager.sanitizeFilename(input) == expected)
    }

    @Test func sanitizeCutsAt30Characters() {
        let long = String(repeating: "a", count: 40)
        #expect(CSVManager.sanitizeFilename(long) == String(repeating: "a", count: 30))
    }

    @Test(arguments: ["Triage Datei", "Übung_1", String(repeating: "ä-b", count: 20), "../x"])
    func sanitizeIsIdempotent(_ input: String) {
        let once = CSVManager.sanitizeFilename(input)
        #expect(CSVManager.sanitizeFilename(once) == once)
    }

    @Test func defaultDatePrefixIsValidFilename() {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = AppSettings.Default.csvDatePrefix
        let prefix = df.string(from: Date(timeIntervalSince1970: 0))

        #expect(CSVManager.sanitizeFilename(prefix) == prefix)
    }
}
