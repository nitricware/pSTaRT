//
//  ContextExtensionTests.swift
//  pSTaRT
//
//  Created by Kurt Frey on 06.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import CoreData
import CoreLocation
import Testing
@testable import pSTaRT

@MainActor
@Suite("CoreData - database tests")
struct ContextExtensionTests {
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }

    init() throws {
        container = try TestStore.makeContainer()
    }

    private func save(_ id: String, _ groups: TriageGroup...,
                      location: CLLocation? = nil, isPrecise: Bool = false) throws {
        try context.saveTriage(identification: id,
                               start: .now,
                               decisions: groups.map { TriageDecision(group: $0, date: .now) },
                               location: location,
                               isPrecise: isPrecise)
    }

    private func count(_ entity: String) throws -> Int {
        try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: entity))
    }

    private func onlyPerson() throws -> Persons {
        let persons = try context.fetchPersons()
        try #require(persons.count == 1)
        return persons[0]
    }

    @Test func saveTriageCreatesPersonWithAllDecisions() throws {
        let start = Date(timeIntervalSince1970: 1_000)
        try context.saveTriage(identification: "A1",
                               start: start,
                               decisions: [TriageDecision(group: .two, date: start),
                                           TriageDecision(group: .one, date: .now)],
                               location: nil,
                               isPrecise: false)

        let person = try onlyPerson()
        #expect(person.plsNumber == "A1")
        #expect(person.startTime == start)
        #expect(person.endTime != nil)
        #expect(person.triageGroup == TriageGroup.one.rawValue)   // latest decision wins
        #expect(person.triages?.count == 2)
    }

    @Test func saveTriageStoresLocation() throws {
        let location = CLLocation(latitude: 48.208333, longitude: 16.373056)
        try save("A1", .three, location: location, isPrecise: true)

        let person = try onlyPerson()
        let coordinate = try #require(person.coordinate)
        #expect(coordinate.latitude == 48.208333)
        #expect(coordinate.longitude == 16.373056)
        #expect(person.preciseLocation)
    }

    @Test func saveTriageWithoutLocationLeavesCoordinateEmpty() throws {
        try save("A1", .three, isPrecise: true)

        let person = try onlyPerson()
        #expect(person.coordinate == nil)
        #expect(!person.preciseLocation)   // isPrecise is ignored without a location
    }
    
    @Test func saveTriageWithoutDecisionsSavesNothing() throws {
        try save("A1")

        let persons = try count("Persons")
        #expect(persons == 0)
    }

    @Test func retriageAddsDecisionAndUpdatesGroup() throws {
        try save("A1", .two)
        let person = try onlyPerson()

        try context.retriage(person, to: .one)

        #expect(person.triageGroup == TriageGroup.one.rawValue)
        #expect(person.triages?.count == 2)
    }

    @Test func deletePersonAlsoDeletesTriages() throws {
        try save("A1", .two, .one)

        try context.deletePerson(person: try onlyPerson())

        let persons = try count("Persons")
        let triages = try count("Triages")
        #expect(persons == 0)
        #expect(triages == 0)   // cascade rule in the data model
    }

    @Test func deleteAllRemovesEverything() throws {
        for id in ["A1", "A2", "A3"] {
            try save(id, .two, .one)
        }

        try context.deleteAll()

        let persons = try count("Persons")
        let triages = try count("Triages")
        #expect(persons == 0)
        #expect(triages == 0)
        #expect(try context.fetchPersons().isEmpty)
    }

    @Test(arguments: [("A1", true), ("A2", false), ("a1", false), ("A1 ", false)])
    func isDuplicate(_ id: String, expected: Bool) throws {
        try save("A1", .three)

        #expect(try context.isDuplicate(id: id) == expected)
    }

    private var maxLength: Int {
        UserDefaults.standard.integer(forKey: AppSettings.Key.identificationMaxLength)
    }

    @Test func validateRejectsEmptyInput() {
        #expect(throws: pSTaRTErrors.emptyInput) {
            try context.validateNewIdentification("")
        }
    }

    @Test func validateRejectsTooLongInput() throws {
        try #require(maxLength > 0)
        let id = String(repeating: "X", count: maxLength + 1)

        #expect(throws: pSTaRTErrors.identificationTooLong) {
            try context.validateNewIdentification(id)
        }
    }

    @Test func validateAcceptsMaximumLength() throws {
        try #require(maxLength > 0)

        try context.validateNewIdentification(String(repeating: "X", count: maxLength))
    }

    @Test func validateRejectsDuplicate() throws {
        try save("A1", .three)

        #expect(throws: pSTaRTErrors.duplicateID) {
            try context.validateNewIdentification("A1")
        }
    }

    @Test func finishedSessionIsStored() throws {
        let session = TriageSession(identification: "B7")
        session.no()    // can't walk
        session.yes()   // deadly injuries → IV

        try session.finish(in: context, at: nil, isPrecise: false)

        let person = try onlyPerson()
        #expect(person.plsNumber == "B7")
        #expect(person.triageGroup == TriageGroup.four.rawValue)
        #expect(person.startTime == session.triageStart)
    }
}
