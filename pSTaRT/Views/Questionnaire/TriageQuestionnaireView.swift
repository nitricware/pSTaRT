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
    //@State public var currentTriage: TriageQuestionnaire = TriageQuestionnaire()
    @StateObject public var currentTriage: CurrentTriage = CurrentTriage()
    
    @Binding public var isShowingTriage: Bool
    @Binding public var identification: String
    
    var body: some View {
        VStack {
            Text("CURRENT_PERSON")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(currentTriage.identification)
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
                currentTriage.triageStart,
                format: Date.FormatStyle().year().month(.twoDigits).day().hour().minute().second()
            )
            .font(
                .system(size: 36.0, weight: .regular, design: .monospaced)
            )
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .frame(maxWidth: .infinity, alignment: .leading)
            if let location = currentTriage.location {
                HStack {
                    Spacer()

                    Map(
                        position: $currentTriage.mapCameraPostion,
                        interactionModes: []
                    ) {
                        Marker(identification, systemImage: "cross.case", coordinate: location.coordinate)
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
                if currentTriage.currentGroup == .unidentified {
                    TriageQuestion()
                } else {
                    TriageConclusion(
                        isShowingTriage: $isShowingTriage
                    )
                }
            }
            
            TriageRetriage(
                saveOnInteraction: false
            )
        }
        .onAppear() {
            currentTriage.identification = identification
        }
        .onChange(of: isShowingTriage) { oldValue, newValue in
            // reset identification on close
            if oldValue && !newValue {
                identification = ""
            }
        }
        .environmentObject(currentTriage)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .navigationTitle(Text("TRIAGE_QUESTIONNAIRE"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.isShowingTriage.toggle()
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
                        isShowingTriage: isShowingSheet,
                        identification: .constant("TESTTRIAGE")
                    )
                    .previewLayout(.device)
                }
            }
    }
}
