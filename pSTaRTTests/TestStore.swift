//
//  TestStore.swift
//  pSTaRT
//
//  Created by Kurt Frey on 06.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//
//  This file creates an extra CoreDate store for the test.


import CoreData
@testable import pSTaRT

enum TestStore {
    static func makeContainer() throws -> NSPersistentContainer {
        let model = PersistenceController.shared.container.managedObjectModel
        let container = NSPersistentContainer(name: "pSTaRT", managedObjectModel: model)
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
        ]

        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        if let loadError { throw loadError }
        return container
    }
}
