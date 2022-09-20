//
//  MainToolbar.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 19.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct MainToolbar: ToolbarContent {
    @Binding public var isShowingTipJar: Bool
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                isShowingTipJar.toggle()
            }) {
                Image(systemName: "giftcard")
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                
            }) {
                Image(systemName: "gearshape")
            }
            .hidden()
        }
        if UIDevice.current.model.contains("iPhone") {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink{
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
                    MainToolbar(
                        isShowingTipJar: .constant(false)
                    )
                }
        }
    }
}
