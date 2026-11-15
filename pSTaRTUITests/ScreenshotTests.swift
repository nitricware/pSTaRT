//
//  ScreenshotTests.swift
//  pSTaRT
//
//  Created by Kurt Frey on 13.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


//
//  ScreenshotTests.swift
//  pSTaRTUITests
//

import XCTest
import CoreLocation

final class ScreenshotTests: XCTestCase {

    // MARK: - Scene

    private static let center = CLLocationCoordinate2D(latitude: 48.31595766153394,
                                                       longitude: 14.320471953178302)

    private static let liveID = "EMERGENCY-001"
    private static let liveOffset = (north: 17.5, east: 30.3)

    private static let detailPersonID = "EMERGENCY-002"

    private static func coordinate(north: Double, east: Double) -> CLLocationCoordinate2D {
        let metersPerDegreeLat = 111_132.0
        let metersPerDegreeLon = 111_320.0 * cos(center.latitude * .pi / 180)
        return CLLocationCoordinate2D(latitude: center.latitude + north / metersPerDegreeLat,
                                      longitude: center.longitude + east / metersPerDegreeLon)
    }

    // MARK: - Accessibility identifiers (set in the app with .accessibilityIdentifier)

    private enum ID {
        static let identificationField = "identificationField"   // IdentificationInput.swift
        static let startTriage = "startTriageButton"             // IdentificationInput.swift
        static let answerYes = "answerYes"                       // TriageQuestion.swift
        static let assignGroup = "assignGroupButton"             // TriageConclusion.swift
        static let settings = "settingsButton"                   // MainToolbar.swift
        static let personsList = "personsListButton"             // MainToolbar.swift
        static let personsMap = "personsMapButton"               // PersonsList.swift
        static let close = "closeButton"                         // CloseToolbarItem.swift
        static let demoData = "demoDataButton"                   // Settings.swift (Debug only)
        static let back = "BackButton"                           // set by the system
    }

    // MARK: - Test

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testScreenshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        // We set the UserDefaults right here to avoid a
        // WhatsNew screen.
        app.launchArguments += [
            "-onboarding.lastversion", "999.0.0",
            "-icloud.syncenabled", "NO"
        ]

        if UIDevice.current.userInterfaceIdiom == .pad {
            XCUIDevice.shared.orientation = .landscapeLeft
        }

        let live = Self.coordinate(north: Self.liveOffset.north, east: Self.liveOffset.east)
        XCUIDevice.shared.location = XCUILocation(location: CLLocation(
            coordinate: live, altitude: 260, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date()))
        app.launch()

        // Demo data: Settings → debug button → close.
        // The button replaces all persons, so repeated runs start from the same state.
        tap(barItem(ID.settings, in: app), "settings button")
        let demoData = app.buttons[ID.demoData]
        for _ in 0..<5 where !demoData.exists { app.swipeUp() }
        tap(demoData, "demo data button (Debug builds only)")
        tap(barItem(ID.close, in: app), "close button")
        XCTAssertTrue(demoData.waitForNonExistence(timeout: 10), "Settings did not close")

        let field = app.textFields[ID.identificationField]
        tap(field, "identification field")
        field.typeText(Self.liveID + "\n")
        XCTAssertEqual(field.value as? String, Self.liveID)
        snapshot("01_TriageInput")

        tap(app.buttons[ID.startTriage], "start triage button")
        allowLocationIfAsked()
        require(app.buttons[ID.answerYes], "YES button")
        require(app.maps.firstMatch, "mini map (location must be available)")
        sleep(3)
        snapshot("02_Questionnaire")

        app.buttons[ID.answerYes].tap()
        let assign = app.buttons[ID.assignGroup]
        require(assign, "assign group button")
        snapshot("03_TriageGroupIII")
        assign.tap()
        XCTAssertTrue(assign.waitForNonExistence(timeout: 10), "Triage sheet did not close")

        // iPhone: the persons list is behind a toolbar link. iPad: already visible.
        let listButton = barItem(ID.personsList, in: app, timeout: 2)
        if listButton.waitForExistence(timeout: 1) {
            listButton.tap()
        }
        tap(app.buttons[Self.detailPersonID], "row \(Self.detailPersonID)")
        require(app.maps.firstMatch, "person detail map")
        sleep(3)
        snapshot("04_PersonDetail")

        tap(barItem(ID.back, in: app), "back button")
        tap(barItem(ID.personsMap, in: app), "map button")
        require(app.maps.firstMatch, "persons map")
        sleep(5)
        snapshot("05_Map")
    }

    // MARK: - Helpers

    @MainActor
    private func allowLocationIfAsked() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowWhileUsing = springboard.alerts.buttons.element(boundBy: 1)
        if allowWhileUsing.waitForExistence(timeout: 5) {
            allowWhileUsing.tap()
        }
    }

    @MainActor
    private func require(_ element: XCUIElement, _ name: String, timeout: TimeInterval = 10,
                         file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Not found: \(name)", file: file, line: line)
    }

    @MainActor
    private func tap(_ element: XCUIElement, _ name: String,
                     file: StaticString = #filePath, line: UInt = #line) {
        require(element, name, file: file, line: line)
        element.tap()
    }

    /// Navigation-bar items are not always reported as buttons (iPhone Duo simulator:
    /// "Automation type mismatch: computed Other … vs Button").
    /// Looks for a button first, then for any element with that identifier.
    @MainActor
    private func barItem(_ identifier: String, in app: XCUIApplication, timeout: TimeInterval = 3) -> XCUIElement {
        let button = app.buttons[identifier].firstMatch
        if button.waitForExistence(timeout: timeout) { return button }
        return app.descendants(matching: .any)[identifier].firstMatch
    }
}
