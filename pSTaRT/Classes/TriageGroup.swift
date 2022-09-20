//
//  TriageGroup.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 10.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import Foundation
import SwiftUI

class TriageGroup {
    public var color: Color = .gray
    public var identifier: TriageGroups = .unidentified
    public var description: String = NSLocalizedString("T0", comment: "no triage done yet")
    public var intVal: Int = 0
    public var roman: String = "X"
    
    convenience init(_ group: Int) {
        switch group {
        case 1:
            self.init(.one)
        case 2:
            self.init(.two)
        case 3:
            self.init(.three)
        case 4:
            self.init(.four)
        default:
            self.init(.unidentified)
        }
    }
    
    init(_ group: TriageGroups = .unidentified) {
        self.identifier = group
        switch group {
        case .one:
            color = Color.red
            description = NSLocalizedString("T1", comment: "T1")
            intVal = 1
            roman = "I"
        case .two:
            color = Color.yellow
            description = NSLocalizedString("T2", comment: "T2")
            intVal = 2
            roman = "II"
        case .three:
            color = Color.green
            description = NSLocalizedString("T3", comment: "T3")
            intVal = 3
            roman = "III"
        case .four:
            color = Color.blue
            description = NSLocalizedString("T4", comment: "T4")
            intVal = 4
            roman = "IV"
        default:
            color = Color.gray
            description = NSLocalizedString("T0", comment: "T0")
            intVal = 0
            roman = "X"
        }
    }
}
