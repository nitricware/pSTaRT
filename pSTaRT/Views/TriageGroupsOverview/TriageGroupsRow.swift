//
//  TriageGroupsRow.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 19.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct TriageGroupsRow: View {
    public var triageGroup: TriageGroups = .unidentified
    private let iconSize: CGFloat = 40.0
    var body: some View {
        HStack {
            TriageGroupIcon(
                triageGroup: TriageGroup(triageGroup)
            )
                .frame(width: iconSize, height: iconSize, alignment: .center)
            TriageGroupCounter(
                triageGroup: triageGroup
            )
        }
    }
}

struct TriageGroupsRow_Previews: PreviewProvider {
    static var previews: some View {
        TriageGroupsRow()
    }
}
