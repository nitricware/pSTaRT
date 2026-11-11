//
//  CloudSync.swift
//  pSTaRT
//
//  Created by Kurt Frey on 02.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import CloudKit

enum CloudSync {
    /// Must match the iCloud container in the entitlement.
    static let containerIdentifier = "iCloud.com.nitricware.pSTaRT"

    /// Zone that NSPersistentCloudKitContainer uses in the private database.
    private static let zoneID = CKRecordZone.ID(
        zoneName: "com.apple.coredata.cloudkit.zone",
        ownerName: CKCurrentUserDefaultName
    )

    /// Deletes this app's iCloud data after sync was switched off.
    /// Keeps the flag on failure, so the next app start tries again.
    static func purgeIfNeeded() async {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: AppSettings.Key.pendingCloudPurge),
              !defaults.bool(forKey: AppSettings.Key.iCloudSyncEnabled) else { return }
        
        
        let container = CKContainer(identifier: containerIdentifier)
        do {
            guard try await container.accountStatus() == .available else { return }
            try await container.privateCloudDatabase.deleteRecordZone(withID: zoneID)
            defaults.set(false, forKey: AppSettings.Key.pendingCloudPurge)
        } catch let error as CKError where error.code == .zoneNotFound {
            // nothing in iCloud – done
            defaults.set(false, forKey: AppSettings.Key.pendingCloudPurge)
        } catch {
            // offline, iCloud unavailable, … → retry at next start
            return
        }
    }
}
