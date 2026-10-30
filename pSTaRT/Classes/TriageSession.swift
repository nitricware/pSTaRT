//
//  TriageSession.swift
//  pSTaRT
//
//  Created by Kurt Frey on 30.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import CoreLocation

@Observable
final class TriageSession: Identifiable {
    let identification: String
    let triageStart: Date = Date.now
    
    private(set) var decisions: [TriageDecision] = []
    private(set) var currentQuestion = String(localized: "WALKING", table: "Questionnaire")
    
    // Tint of the button that concludes the questionnaire and assigns a triage group
    private(set) var yesColor: Color = .green
    // Tint of the button that continues the questionnaire
    private(set) var noColor: Color = .orange

    // How many questions have been asked?
    @ObservationIgnored private var currentIteration = 0
    
    var currentGroup: TriageGroup { decisions.last?.group ?? .unidentified }

    init(identification: String) {
        self.identification = identification
    }
    
    func yes() {
        switch currentIteration {
        case 0: conclude(assign: .three)
        case 1: conclude(assign: .four)
        case 2, 3, 5, 6:
            currentIteration += 1
            advance()
        case 4, 7: conclude(assign: .one)
        default: conclude(assign: .two)
        }
    }
    
    func no() {
        switch currentIteration {
        case 0, 1, 4:
            currentIteration += 1
            advance()
        case 2, 3, 5, 6: conclude(assign: .one)
        default: conclude(assign: .two)
        }
    }
    
    private func advance() {
        switch currentIteration {
        case 1:
            self.currentQuestion = String(localized: "DEAD", table: "Questionnaire")
            self.yesColor = .blue
            self.noColor = .orange
        case 2:
            self.currentQuestion = String(localized: "AIRWAY", table: "Questionnaire")
            self.yesColor = .orange
            self.noColor = .red
        case 3:
            self.currentQuestion = String(localized: "BREATHING", table: "Questionnaire")
            self.yesColor = .orange
            self.noColor = .red
        case 4:
            self.currentQuestion = String(localized: "BLEEDING", table: "Questionnaire")
            self.yesColor = .red
            self.noColor = .orange
        case 5:
            self.currentQuestion = String(localized: "PULSE", table: "Questionnaire")
            self.yesColor = .orange
            self.noColor = .red
        case 6:
            self.currentQuestion = String(localized: "MOVEMENT", table: "Questionnaire")
            self.yesColor = .orange
            self.noColor = .red
        case 7:
            self.currentQuestion = String(localized: "ASPIRATION", table: "Questionnaire")
            self.yesColor = .red
            self.noColor = .yellow
        default:
            self.currentQuestion = String(localized: "INCONCLUSIVE", table: "Questionnaire")
            self.yesColor = .yellow
            self.noColor = .orange
        }
    }
    
    func conclude(assign group: TriageGroup) {
        decisions.append(TriageDecision(group: group, date: .now))
    }
    
    func finish(in context: NSManagedObjectContext, at location: CLLocation?, isPrecise: Bool) throws {
        try context.saveTriage(identification: identification,
                               start: triageStart,
                               decisions: decisions,
                               location: location,
                               isPrecise: isPrecise)
    }
}
