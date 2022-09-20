//
//  TriageOverview.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 10.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct TriageGroupsOverview: View {
    var body: some View {
        VStack {
            TriageGroupsRow(
                triageGroup: .one
            )
            TriageGroupsRow(
                triageGroup: .two
            )
            TriageGroupsRow(
                triageGroup: .three
            )
            TriageGroupsRow(
                triageGroup: .four
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TriageOverview_Previews: PreviewProvider {
    static var previews: some View {
        TriageGroupsOverview()
            .previewLayout(.sizeThatFits)
    }
}
