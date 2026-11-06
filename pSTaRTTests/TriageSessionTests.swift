//
//  TriageSessionTests.swift
//  pSTaRT
//
//  Created by Kurt Frey on 06.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import Foundation
import Testing
@testable import pSTaRT

@Suite("TriageSession - mSTaRT-Questionnaire")
struct TriageSessionTests {

    enum Answer { case yes, no }

    private func makeSession(answering answers: [Answer]) -> TriageSession {
        let session = TriageSession(identification: "TEST-1")
        for answer in answers {
            switch answer {
            case .yes: session.yes()
            case .no:  session.no()
            }
        }
        return session
    }

    // MARK: - Alle Pfade durch den Algorithmus

    static let paths: [([Answer], TriageGroup)] = [
        ([.yes],                                          .three), // gehfähig
        ([.no, .yes],                                     .four),  // tödliche Verletzungen
        ([.no, .no, .no],                                 .one),   // atmet nicht
        ([.no, .no, .yes, .no],                           .one),   // Atemfrequenz außerhalb
        ([.no, .no, .yes, .yes, .yes],                    .one),   // unstillbare Blutung
        ([.no, .no, .yes, .yes, .no, .no],                .one),   // kein Radialispuls
        ([.no, .no, .yes, .yes, .no, .yes, .no],          .one),   // befolgt keine Aufforderungen
        ([.no, .no, .yes, .yes, .no, .yes, .yes, .yes],   .one),   // Inhalationstrauma
        ([.no, .no, .yes, .yes, .no, .yes, .yes, .no],    .two),   // nichts davon
    ]

    @Test("Succession of answers always results in the same triage group suggestion.", arguments: paths)
    func path(_ answers: [Answer], expected: TriageGroup) {
        let session = makeSession(answering: answers)

        #expect(session.currentGroup == expected)
        #expect(session.decisions.count == 1)
    }

    // MARK: - Fragenreihenfolge

    @Test func startsUnidentifiedWithWalkingQuestion() {
        let session = TriageSession(identification: "TEST-1")

        #expect(session.currentGroup == .unidentified)
        #expect(session.decisions.isEmpty)
        #expect(session.currentQuestion == String(localized: "WALKING", table: "Questionnaire"))
    }

    static let questionOrder: [([Answer], String)] = [
        ([.no],                                     "DEAD"),
        ([.no, .no],                                "AIRWAY"),
        ([.no, .no, .yes],                          "BREATHING"),
        ([.no, .no, .yes, .yes],                    "BLEEDING"),
        ([.no, .no, .yes, .yes, .no],               "PULSE"),
        ([.no, .no, .yes, .yes, .no, .yes],         "MOVEMENT"),
        ([.no, .no, .yes, .yes, .no, .yes, .yes],   "ASPIRATION"),
    ]

    @Test("The questionnaire follows the correct order.", arguments: questionOrder)
    func nextQuestion(_ answers: [Answer], key: String) {
        let session = makeSession(answering: answers)

        #expect(session.currentQuestion ==
                String(localized: String.LocalizationValue(key), table: "Questionnaire"))
        #expect(session.decisions.isEmpty)   // noch keine Entscheidung
    }

    // MARK: - Retriage

    @Test func concludeAppendsHistoryNewestLast() {
        let session = TriageSession(identification: "TEST-1")

        session.conclude(assign: .two)
        session.conclude(assign: .one)

        #expect(session.decisions.map(\.group) == [.two, .one])
        #expect(session.currentGroup == .one)
    }
}
