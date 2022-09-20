//
//  TriageGroupIcon.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 11.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

struct TriageGroupIcon: View {
    public var triageGroup: TriageGroup = TriageGroup()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .foregroundColor(triageGroup.color)
                Text(triageGroup.identifier.rawValue)
                    .font(.system(size: geo.size.height - (geo.size.height*0.25), weight: .regular, design: .serif))
                    .minimumScaleFactor(0.1)
            }
        }
    }
}

struct TriageGroupIcon_Previews: PreviewProvider {
    static var triageGroup: TriageGroup = TriageGroup(.four)
    static var previews: some View {
        
        TriageGroupIcon(
            triageGroup: triageGroup
        )
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .frame(width: 50, height: 50, alignment: .center)
    }
}
