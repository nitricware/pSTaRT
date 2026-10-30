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
        guard let latest = locations.last else { return }
        withAnimation {
            location = latest
            mapCameraPosition = .person(at: latest.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        return
    }
}

extension MapCameraPosition {
    static func person(at coordinate: CLLocationCoordinate2D, span: CLLocationDegrees = 0.001) -> Self {
        .region(MKCoordinateRegion(center: coordinate,
                                   span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)))
    }
}
