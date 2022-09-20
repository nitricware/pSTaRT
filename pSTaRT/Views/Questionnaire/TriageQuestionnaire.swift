//
//  TriageQuestionnaier.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 11.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct TriageQuestionnaire: View {
    // MARK: Bindings from parent
    //@EnvironmentObject public var currentTriage: CurrentTriage
    @EnvironmentObject public var currentTriage: CurrentTriage
    @Binding public var isShowingTriage: Bool
    
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
            
            Spacer()
            
            VStack {
                if currentTriage.triageGroup.first!.identifier == .unidentified {
                    TriageQuestion()
                } else {
                    TriageConclusion(
                        isShowingTriage: $isShowingTriage
                    )
                }
            }
            
            Spacer()
            
            TriageRetriage(
                saveOnInteraction: false
            )
        }
        .environmentObject(currentTriage)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .navigationTitle(Text("TRIAGE_QUESTIONNAIRE"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // TODO: show confirmation dialogue
                Button(action: {
                    self.isShowingTriage.toggle()
                }) {
                    Text("CANCEL_TRIAGE")
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            self.currentTriage.triageStart = Date()
        }
        .onDisappear {
            self.currentTriage.identification = ""
        }
    }
}

struct TriageQuestionnaier_Previews: PreviewProvider {
    static let currentTriage: CurrentTriage = CurrentTriage(identification: "4 AS TEST1234")
    static let isShowingSheet: Binding<Bool> = .constant(true)
    static var previews: some View {
        Spacer()
            .sheet(isPresented: isShowingSheet) {
                NavigationView {
                    TriageQuestionnaire(
                        isShowingTriage: isShowingSheet
                    )
                    .environmentObject(self.currentTriage)
                    .previewLayout(.device)
                }
            }
    }
}
