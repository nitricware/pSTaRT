//
//  NWLocationProvider.swift
//  pSTaRT
//
//  Created by Kurt Frey on 30.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit

@Observable
final class NWLocationProvider: NSObject, CLLocationManagerDelegate {
    private(set) var location: CLLocation?
    var mapCameraPosition: MapCameraPosition = .automatic
    var isPrecise: Bool { locationManager.accuracyAuthorization == .fullAccuracy }

    private let locationManager = CLLocationManager()
    @ObservationIgnored private var isActive = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .otherNavigation
    }
    
    func start() {
        isActive = true
        update()
    }
    
    func stop() {
        isActive = false
        locationManager.stopUpdatingLocation()
    }
    
    private func update() {
        switch locationManager.authorizationStatus {
            case .notDetermined: locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways: locationManager.startUpdatingLocation()
            default: break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if isActive { update() }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for candidate in locations {
            guard candidate.horizontalAccuracy >= 0,
                  abs(candidate.timestamp.timeIntervalSinceNow) < 120
            else { continue }

            if let current = location {
                let isMoreAccurate = candidate.horizontalAccuracy <= current.horizontalAccuracy
                let currentIsStale = candidate.timestamp.timeIntervalSince(current.timestamp) > 30
                guard isMoreAccurate || currentIsStale else { continue }
            }

            withAnimation {
                location = candidate
                mapCameraPosition = .focused(on: candidate.coordinate)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        return
    }
}
