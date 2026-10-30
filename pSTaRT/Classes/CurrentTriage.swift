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
    //public var identification: String { person.plsNumber ?? String(localized: "common.unidentified")}
    public var currentGroup: TriageGroup { TriageGroup(stored: triageList.last?.group ?? TriageGroup.unidentified.rawValue) }
    @Published public var identification: String = ""
    @Published public var triageStart: Date = Date()
    
    @Published public var triageList: [Triages] = []
    
    @Published public var currentQuestion: String = NSLocalizedString("WALKING", tableName: "Questionnaire", comment: "Can the person walk?")
    
    // Tint of the button that concludes the questionnaire and assigns a triage group
    @Published public var yesColor: Color = .green
    
    // Tint of the button that continues the questionnaire
    @Published public var noColor: Color = .orange
    
    @Published var location: CLLocation?
    
    private let locationManager: CLLocationManager = CLLocationManager()
    
    // How many questions have been asked?
    
    private var currentIteration: Int = 0
    
    @Published public var person: Persons
    
    private let context: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    
    init() {
        let newPerson = Persons(context: context)
        newPerson.startTime = .now
        self.person = newPerson
    }
    
    init (identification: String) {
        let newPerson: Persons = Persons(context: context)
        newPerson.startTime = .now
        newPerson.plsNumber = identification
        self.person = newPerson
    }
    
    init (person: Persons) {
        // All stored properties must be initialized before super.init()
        self.person = person
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
    
    /// Concludes a triage. Can either be triggered by finishing the questionnaire or by retriaging.
    func conclude(assign triageGroup: TriageGroup) {
        let newTriage = Triages(context: context)
        newTriage.person = person
        newTriage.group = triageGroup.rawValue
        newTriage.date = Date()
        
        person.triageGroup = triageGroup.rawValue
        
        triageList.append(newTriage)
    }
    func finish() throws {
        person.endTime = .now
        if person.plsNumber == nil {
            person.plsNumber = identification
        }
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw pSTaRTErrors.dbSaveError
        }
    }
    func finish(at location: CLLocation?, isPrecise: Bool) throws {
        if let l = location {
            person.preciseLocation = isPrecise
            person.lat = NSNumber(value: l.coordinate.latitude)
            person.lon = NSNumber(value: l.coordinate.longitude)
        }
        
        person.endTime = .now
        if person.plsNumber == nil {
            person.plsNumber = identification
        }
        
        do {
            try context.save()
        } catch {
            context.rollback()
            throw pSTaRTErrors.dbSaveError
        }
    }
}
