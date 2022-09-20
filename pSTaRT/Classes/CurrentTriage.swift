//
//  CurrentTriage.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 11.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

class CurrentTriage: ObservableObject {
    @Published public var identification: String = ""
    
    @Published public var triageStart: Date = Date()
    
    //@Published public var triageGroup: TriageGroup = TriageGroup()
    @Published public var triageGroup: [TriageGroup] = [TriageGroup()]
    
    @Published public var currentQuestion: String = NSLocalizedString("WALKING", tableName: "Questionnaire", comment: "Can the person walk?")
    
    // Tint of the button that concludes the questionnaire and assigns a triage group
    @Published public var yesColor: Color = .green
    
    // Tint of the button that continues the questionnaire
    @Published public var noColor: Color = .orange
    
    // How many questions have been asked?
    
    private var currentIteration: Int = 0
    
    public var person: Persons?
    
    init (person: Persons? = nil) {
        self.person = person
    }
    
    init(identification: String) {
        self.identification = identification
    }
    
    func reset(with identification: String) {
        self.reset()
        self.identification = identification
    }
    
    func reset() {
        self.identification = ""
        self.triageStart = Date()
        //self.triageGroup = TriageGroup()
        self.triageGroup = [TriageGroup()]
        self.currentQuestion = NSLocalizedString("WALKING", tableName: "Questionnaire", comment: "Can the person walk?")
        self.yesColor = .green
        self.noColor = .orange
        self.currentIteration = 0
        self.person = nil
    }
    
    func yes() {
        switch currentIteration {
        case 0:
            self.conclude(assign: .three)
        case 1:
            self.conclude(assign: .four)
        case 2, 3, 5, 6:
            self.currentIteration += 1
            self.advance()
        case 4, 7:
            self.conclude(assign: .one)
        default:
            self.conclude(assign: .two)
        }
    }
    
    func no() {
        switch currentIteration {
        case 0, 1, 4:
            self.currentIteration += 1
            self.advance()
        case 2, 3, 5, 6:
            self.conclude(assign: .one)
        default:
            self.conclude(assign: .two)
        }
    }
    
    func advance() {
        switch currentIteration {
        case 1:
            self.currentQuestion = NSLocalizedString("DEAD", tableName: "Questionnaire", comment: "Deadly injuries?")
            self.yesColor = .blue
            self.noColor = .orange
        case 2:
            self.currentQuestion = NSLocalizedString("AIRWAY", tableName: "Questionnaire", comment: "Person does breath?")
            self.yesColor = .orange
            self.noColor = .red
        case 3:
            self.currentQuestion = NSLocalizedString("BREATHING", tableName: "Questionnaire", comment: "Breathing frequency > 10 and < 30/min?")
            self.yesColor = .orange
            self.noColor = .red
        case 4:
            self.currentQuestion = NSLocalizedString("BLEEDING", tableName: "Questionnaire", comment: "Uncontrolled bleeding?")
            self.yesColor = .red
            self.noColor = .orange
        case 5:
            self.currentQuestion = NSLocalizedString("PULSE", tableName: "Questionnaire", comment: "Person has radial pulse?")
            self.yesColor = .orange
            self.noColor = .red
        case 6:
            self.currentQuestion = NSLocalizedString("MOVEMENT", tableName: "Questionnaire", comment: "Does the person follow simple orders?")
            self.yesColor = .orange
            self.noColor = .red
        case 7:
            self.currentQuestion = NSLocalizedString("ASPIRATION", tableName: "Questionnaire", comment: "Inhalation trauma with stridor?")
            self.yesColor = .red
            self.noColor = .yellow
        default:
            self.currentQuestion = NSLocalizedString("INCONCLUSIVE", tableName: "Questionnaire", comment: "Person dead?")
            self.yesColor = .yellow
            self.noColor = .orange
        }
    }
    
    func conclude(assign triageGroup: TriageGroups) {
        //self.triageGroup = TriageGroup(triageGroup)
        
        if self.triageGroup.first?.identifier == .unidentified {
            self.triageGroup = [TriageGroup(triageGroup)]
        } else {
            self.triageGroup.insert(TriageGroup(triageGroup), at: 0)
        }
    }
    
    func savePersonToDatabase() {
        self.person = Persons(context: PersistenceController.shared.container.viewContext)
        
        person!.plsNumber = self.identification
        person!.startTime = self.triageStart
        person!.endTime = Date()
        
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            // TODO: Error handling
            print("Error")
        }
    }
    
    func appendTriage() {
        person!.triageGroup = Int16(self.triageGroup.first!.intVal)
        for triage in self.triageGroup {
            let triageObject: Triages = Triages(context: PersistenceController.shared.container.viewContext)

            triageObject.person = self.person!
            triageObject.group = Int16(triage.intVal)
            triageObject.date = self.triageStart
            
            do {
                try PersistenceController.shared.container.viewContext.save()
            } catch {
                // TODO: Error handling
                print("Error")
            }
        }
        
        
    }
}
