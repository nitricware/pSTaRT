//
//  TriageQuestionnaire.swift
//  pSTaRT
//
//  Created by Kurt Frey on 29.10.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//
import Foundation
import CoreLocation

@Observable
final class TriageSession {
    public var identification: String = ""
    public var triageStart: Date = Date()
    public var currentGroup: TriageGroup = .unidentified
    
    
}
