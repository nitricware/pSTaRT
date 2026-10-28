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
import CoreLocation
import MapKit

class CurrentTriage: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published public var identification: String = ""
    
    @Published public var triageStart: Date = Date()
    
    @Published public var triageGroup: [TriageGroup] = [.unidentified]
    
    @Published public var currentQuestion: String = NSLocalizedString("WALKING", tableName: "Questionnaire", comment: "Can the person walk?")
    
    // Tint of the button that concludes the questionnaire and assigns a triage group
    @Published public var yesColor: Color = .green
    
    // Tint of the button that continues the questionnaire
    @Published public var noColor: Color = .orange
    
    // Current Location
    @Published public var mapCameraPostion: MapCameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        )
    )
    
    @Published var location: CLLocation?
    
    private let locationManager: CLLocationManager = CLLocationManager()
    
    // How many questions have been asked?
    
    private var currentIteration: Int = 0
    
    public var person: Persons?
    
    init (person: Persons? = nil) {
        super.init()
        self.locationManager.delegate = self
        self.person = person
        self.getLocation()
    }
    
    func reset(with identification: String) {
        self.reset()
        self.identification = identification
    }
    
    func reset() {
        self.identification = ""
        self.triageStart = Date()
        self.triageGroup = [.unidentified]
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
    
    /// Concludes a triage. Can either be triggered by finishing the questionnaire or by retriaging.
    func conclude(assign triageGroup: TriageGroup) {
        if self.triageGroup.first == .unidentified {
            self.triageGroup = [triageGroup]
        } else {
            self.triageGroup.insert(triageGroup, at: 0)
        }
    }
    
    func savePersonToDatabase() {
        self.person = Persons(context: PersistenceController.shared.container.viewContext)
        
        guard let person = self.person else {
            return
        }
        
        person.plsNumber = self.identification
        person.startTime = self.triageStart
        person.endTime = Date()
        
        if let l = locationManager.location {
            person.preciseLocation = locationManager.accuracyAuthorization == .fullAccuracy
            person.lat = NSNumber(value: l.coordinate.latitude)
            person.lon = NSNumber(value: l.coordinate.longitude)
        }
        
        locationManager.stopUpdatingLocation()
        
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            // TODO: Error handling
            print("Error")
        }
    }
    
    func appendTriage() {
        person!.triageGroup = self.triageGroup.first!.rawValue
        for triage in self.triageGroup {
            let triageObject: Triages = Triages(context: PersistenceController.shared.container.viewContext)

            triageObject.person = self.person!
            triageObject.group = triage.rawValue
            triageObject.date = self.triageStart
            
            do {
                try PersistenceController.shared.container.viewContext.save()
            } catch {
                // TODO: Error handling
                print("Error")
            }
        }
    }
    
    func generateCameraPosition(lat: Double, lon: Double) -> MapCameraPosition {
        return MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            )
        )
    }
    
    func getLocation() -> Void{
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Runs when the authorization status changes:
    /// 1. on initialization of `CLLocationManager`
    /// 2. when the user manually changes the autorization
    /// 3. when the authorization was first approved
    /// That's why we can place `.startUpdatingLocation()` right here and do not have to put it in `getLocation()`.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager.authorizationStatus != .authorizedWhenInUse {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        withAnimation {
            self.location = location
            self.mapCameraPostion = generateCameraPosition(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        // TODO: Error Handling
        print(error)
    }
}
