//
//  PersonDetailRow.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 19.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct PersonDetailRow<Content>: View where Content: View {
    let caption: LocalizedStringKey
    let content: Content
    
    init(caption: LocalizedStringKey, @ViewBuilder content: @escaping () -> Content) {
        self.caption = caption
        self.content = content()
    }
    
    var body: some View {
        VStack {
            Text(caption)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.gray)
            self.content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PersonDetailRow_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailRow (
            caption: "IDENTIFICATION"
        ) {
            Text("4 AS ROWTEST1234")
        }
        .previewLayout(.sizeThatFits)
    }
}
