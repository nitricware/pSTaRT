//
//  PersonsList.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 12.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct PersonsList: View {
    @State public var isShowingDeleteAll: Bool = false
    @State public var isShowingDeleteError: Bool = false
    @State public var isShowingShareSheet: Bool = false
    @State public var isShowingActivityIndicator: Bool = false
    
    @FetchRequest (
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
                TriageGroupsOverview()
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            
            PersonListSection(with: TriageGroup(.one))
            PersonListSection(with: TriageGroup(.two))
            PersonListSection(with: TriageGroup(.three))
            PersonListSection(with: TriageGroup(.four))
        }
        .navigationTitle("PERSONS_LIST")
        .overlay {
            // https://stackoverflow.com/questions/72324576/transition-issue-on-overlay
            VStack {
                if isShowingActivityIndicator {
                    Text("LOADING CSV")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background(.thinMaterial)
                        .transition(.opacity)
                }
            }
            .animation(Animation.easeInOut(duration: 0.1), value: isShowingActivityIndicator)
            
        }
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
                    shareCSV()
                }) {
                    Image(systemName: "square.and.arrow.up")
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
    }
    
    func shareCSV() {
        self.isShowingActivityIndicator.toggle()
        DispatchQueue.global(qos: .userInitiated).async {
            let database = pSTaRTDBHelper()
            // https://developer.apple.com/forums/thread/707511
            database.provideCSV(completion: { url in
                DispatchQueue.main.async {
                    // TODO: Show error, when URL is nil
                    let activityVC = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
                    
                    guard
                        let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let firstWindow = firstScene.windows.first else {
                        return
                    }

                    let viewController = firstWindow.rootViewController
                    
                    activityVC.completionWithItemsHandler = { (_,_,_,_) in
                        database.removeCSV()
                        self.isShowingActivityIndicator.toggle()
                    }
                    activityVC.popoverPresentationController?.sourceView = firstWindow
                    activityVC.popoverPresentationController?.sourceRect = CGRect(
                        x: UIScreen.main.bounds.maxX - 20,
                        y: UIScreen.main.bounds.minY + 70,
                        width: 0,
                        height: 0
                    )
                    activityVC.popoverPresentationController?.permittedArrowDirections = [.up]
                    viewController!.present(activityVC, animated: true, completion: nil)
                    
                }
            })
        }
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
