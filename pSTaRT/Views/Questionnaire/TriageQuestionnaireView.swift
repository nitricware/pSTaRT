//
//  TriageQuestionnaier.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 11.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI
import MapKit

struct TriageQuestionnaireView: View {
    // MARK: Bindings from parent
    let session: TriageSession
    let onClose: () -> Void
    @State private var locationProvider = NWLocationProvider()
    
    var body: some View {
        VStack {
            Text("CURRENT_PERSON")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(session.identification)
                .font(
                    .system(size: 36.0, weight: .regular, design: .monospaced)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("TRIAGE_START")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(
                session.triageStart,
                format: Date.FormatStyle().year().month(.twoDigits).day().hour().minute().second()
            )
            .font(
                .system(size: 36.0, weight: .regular, design: .monospaced)
            )
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .frame(maxWidth: .infinity, alignment: .leading)
            if let location = locationProvider.location {
                HStack {
                    Spacer()

                    Map(
                        position: $locationProvider.mapCameraPosition,
                        interactionModes: []
                    ) {
                        Marker(session.identification, systemImage: "cross.case", coordinate: location.coordinate)
                    }
                    .mapStyle(.hybrid)
                    .frame(
                        width: 100.0,
                        height: 100.0
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15.0))
                }
            }
            Spacer()
            
            VStack {
                if session.currentGroup == .unidentified {
                    TriageQuestion()
                } else {
                    TriageConclusion(
                        onClose: onClose
                    )
                    .environment(locationProvider)
                }
            }
            
            TriageRetriage {
                session.conclude(assign: $0)
            }
        }
        .onAppear() {
            locationProvider.start()
        }
        .onDisappear {
            locationProvider.stop()
        }
        .environment(session)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .navigationTitle(Text("TRIAGE_QUESTIONNAIRE"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    onClose()
                }) {
                    Text("CANCEL_TRIAGE")
                        .foregroundColor(.red)
                }
            }
        }
        
    }
}

struct TriageQuestionnaier_Previews: PreviewProvider {
    static let isShowingSheet: Binding<Bool> = .constant(true)
    static var previews: some View {
        Spacer()
            .sheet(isPresented: isShowingSheet) {
                NavigationView {
                    TriageQuestionnaireView(
                        session: TriageSession(identification: "PREVIEW")
                    ) { }
                    .previewLayout(.device)
                }
            }
    }
}
