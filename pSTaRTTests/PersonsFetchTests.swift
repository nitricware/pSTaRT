//
//  PersonsFetchTests.swift
//  pSTaRT
//
//  Created by Kurt Frey on 06.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import CoreData
import Testing
@testable import pSTaRT

@MainActor
@Suite("Persons – filter and search")
struct PersonsFetchTests {
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }

    init() throws {
        container = try TestStore.makeContainer()
        let t0 = Date(timeIntervalSince1970: 1_000)   // fixed times → deterministic order
        for (id, group, offset) in [("4 AS 100", TriageGroup.one, 20.0),
                                    ("4 AS 200", .two, 0),
                                    ("Überschlag-7", .one, 10)] {
            let start = t0.addingTimeInterval(offset)
            try container.viewContext.saveTriage(identification: id,
                                                 start: start,
                                                 decisions: [TriageDecision(group: group, date: start)],
                                                 location: nil,
                                                 isPrecise: false)
        }
    }

    private func ids(_ group: TriageGroup? = nil, search: String = "") throws -> [String] {
        try context.fetch(Persons.fetchRequest(in: group, matching: search)).compactMap(\.plsNumber)
    }

    @Test func noFilterReturnsAllOldestFirst() throws {
        #expect(try ids() == ["4 AS 200", "Überschlag-7", "4 AS 100"])
    }

    @Test func filterByGroup() throws {
        #expect(try ids(.one) == ["Überschlag-7", "4 AS 100"])
        #expect(try ids(.two) == ["4 AS 200"])
        #expect(try ids(.four).isEmpty)
    }

    @Test(arguments: [
        ("as 1",          ["4 AS 100"]),                            // case-insensitive
        ("uberschlag",    ["Überschlag-7"]),                            // diacritic-insensitive
        ("  AS 2  ",      ["4 AS 200"]),                            // surrounding whitespace ignored
        ("   ",           ["4 AS 200", "Überschlag-7", "4 AS 100"]),    // blank = no search
        ("xyz",           []),
    ])
    func search(_ text: String, expected: [String]) throws {
        #expect(try ids(search: text) == expected)
    }

    @Test func groupAndSearchCombine() throws {
        #expect(try ids(.one, search: "AS") == ["4 AS 100"])
    }

    @Test func fetchPersonsUsesSameDefaults() throws {
        let persons = try context.fetchPersons(in: .one)
        #expect(persons.compactMap(\.plsNumber) == ["Überschlag-7", "4 AS 100"])
    }
}
