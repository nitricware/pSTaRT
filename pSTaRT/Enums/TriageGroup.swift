//
//  TriageGroup.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 10.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI

enum TriageGroup: Int16, CaseIterable, Identifiable {
    case unidentified = 0, one, two, three, four

    /// Groups a person can be assigned to (excludes `.unidentified`).
    static let assignable: [TriageGroup] = [.one, .two, .three, .four]

    var id: Self { self }

    var roman: String {
        switch self {
        case .one: "I"
        case .two: "II"
        case .three: "III"
        case .four: "IV"
        case .unidentified: "?"
        }
    }

    var color: Color {
        switch self {
        case .one: .red
        case .two: .yellow
        case .three: .green
        case .four: .blue
        case .unidentified: .gray
        }
    }

    var description: String {
        switch self {
        case .one: NSLocalizedString("T1", comment: "T1")
        case .two: NSLocalizedString("T2", comment: "T2")
        case .three: NSLocalizedString("T3", comment: "T3")
        case .four: NSLocalizedString("T4", comment: "T4")
        case .unidentified: NSLocalizedString("T0", comment: "no triage done yet")
        }
    }

    /// Core Data stores the group as Int16; unknown values fall back to `.unidentified`.
    init(stored value: Int16) {
        self = TriageGroup(rawValue: value) ?? .unidentified
    }
}
