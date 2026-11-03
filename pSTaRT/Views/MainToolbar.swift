//
//  MainToolbar.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 19.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct MainToolbar: ToolbarContent {
    @Binding var sheet: OverviewSheet?
    
    let showsPersonsListLink: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                sheet = .tipJar
            }) {
                Image(systemName: "giftcard")
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                sheet = .settings
            }) {
                Image(systemName: "gearshape")
            }
        }
        if showsPersonsListLink {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    PersonsList()
                } label: {
                    Image(systemName: "tablecells")
                }
            }
        }
    }
}

struct MainToolbar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Hello, World!")
                .toolbar {
                    MainToolbar(sheet: .constant(nil),
                        showsPersonsListLink: false
                    )
                }
        }
    }
}
