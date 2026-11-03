import SwiftUI
import MapKit
import CoreData

struct PersonsMapView: View {
    @FetchRequest(fetchRequest: Persons.fetchRequest(in: nil), animation: .default)
    private var persons: FetchedResults<Persons>

    @State private var position: MapCameraPosition = .automatic
    @State private var selection: Persons?

    private var located: [Persons] { persons.filter { $0.coordinate != nil } }

    var body: some View {
            
        Map(position: $position, selection: $selection) {
            /*
             For the PersonMarker to reflect a re-triage in
             the PersonsDetailView from the map, we must loop
             over a list of Markers, not Persons. Hence the map.
             */
            ForEach(located.map(PersonMarker.init)) { marker in
                marker.tag(marker.person)
            }
        }
        .mapStyle(.hybrid)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .overlay {
            if located.isEmpty {
                ContentUnavailableView("personsMapView.noLocations.title", systemImage: "mappin.slash",
                                       description: Text("personsMapView.noLocations.description"))
                .background(.background)
            }
        }
        .navigationTitle("personsMapView.title")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selection) { person in
            PersonDetail(person: person)
        }
    }
}
