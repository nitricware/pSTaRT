//
//  TriageGroupTests.swift
//  pSTaRT
//
//  Created by Kurt Frey on 06.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import Testing
@testable import pSTaRT

@Suite("TriageGroup")
struct TriageGroupTests {

    @Test("Stored values map to their group",
          arguments: zip([Int16(0), 1, 2, 3, 4],
                         [TriageGroup.unidentified, .one, .two, .three, .four]))
    func storedValueMapping(_ stored: Int16, expected: TriageGroup) {
        #expect(TriageGroup(stored: stored) == expected)
        #expect(expected.rawValue == stored)
    }

    @Test("Unknown stored values fall back to .unidentified",
          arguments: [Int16(-1), 5, 99, .max])
    func unknownStoredValue(_ stored: Int16) {
        #expect(TriageGroup(stored: stored) == .unidentified)
    }

    @Test func romanNumerals() {
        #expect(TriageGroup.allCases.map(\.roman) == ["?", "I", "II", "III", "IV"])
    }

    @Test func assignableExcludesUnidentified() {
        #expect(TriageGroup.assignable == [.one, .two, .three, .four])
    }
}
