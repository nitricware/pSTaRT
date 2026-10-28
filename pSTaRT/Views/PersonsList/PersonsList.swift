//
//  PersonsList.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 12.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI
import CoreData

struct PersonsList: View {
    @State public var isShowingDeleteAll: Bool = false
    @State public var isShowingDeleteError: Bool = false
    @State public var isShowingCSVExport: Bool = false
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Persons.objectID,
                ascending: true
            )
        ],
        animation: .default
    )
    
    private var persons: FetchedResults<Persons>
    
    var body: some View {
        List {
            if !UIDevice.current.model.contains("iPad") {
                Section ("OVERVIEW") {
                    TriageGroupsOverview()
                }
            }
            
            ForEach(TriageGroup.assignable) { group in
                PersonListSection(with: group)
            }
        }
        .navigationTitle("PERSONS_LIST")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.isShowingDeleteAll.toggle()
                }) {
                    Image(systemName: "trash")
                        .tint(.red)
                }
                .disabled(self.persons.count < 1)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button (action: {
                    //shareCSV()
                    isShowingCSVExport.toggle()
                }) {
                    Image(systemName: "tray")
                }
                .disabled(self.persons.count < 1)
            }
        }
        .alert("DELETE_ALL", isPresented: $isShowingDeleteAll) {
            Button("CANCEL", role: .cancel) { }
            Button("CONFIRM", role: .destructive) {
                let database = pSTaRTDBHelper()
                do {
                    try database.deleteAll()
                } catch {
                    self.isShowingDeleteError.toggle()
                }
            }
        }
        .alert("DELETE_ERROR", isPresented: $isShowingDeleteError) {
            Button("OK", role: .cancel) { }
        }
        .sheet(isPresented: $isShowingCSVExport, content: {
            NavigationStack {
                ExportList(isShowing: $isShowingCSVExport)
            }
        })
    }
}

struct PersonsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PersonsList()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
