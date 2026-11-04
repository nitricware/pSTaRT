//
//  MapCameraPositionExtension.swift
//  pSTaRT
//
//  Created by Kurt Frey on 04.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

import SwiftUI
import MapKit

extension MapCameraPosition {
    static func focused(on coordinate: CLLocationCoordinate2D, span: CLLocationDegrees = 0.001) -> Self {
        .region(MKCoordinateRegion(center: coordinate,
                                   span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)))
    }
}
