//
//  NWVersionCheck.swift
//  pSTaRT
//
//  Created by Kurt Frey on 11.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//

enum VersionComparisonResult {
    case equal
    case newer
    case older
}

struct NWVersion {
    struct VersionStruct {
        let major: Int
        let minor: Int
        let patch: Int
        let overflow: String?
        let string: String
    }
    
    private let versionString: String
    var version: VersionStruct{
        return explode(versionString: versionString)
    }
    
    
    init (versionString: String?) {
        self.versionString = versionString ?? "0.0.0"
    }
    
    private func explode(versionString: String) -> VersionStruct {
        let components = versionString.split(separator: ".")
        
        return VersionStruct(
            major: Int(part(0, of: components) ?? "0") ?? 0,
            minor: Int(part(1, of: components) ?? "0") ?? 0,
            patch: Int(part(2, of: components) ?? "0") ?? 0,
            overflow: part(3, of: components),
            string: self.versionString
        )
    }
    
    public func compare(with version: String) -> VersionComparisonResult {
        let rhs = NWVersion(versionString: version)
        let l = (self.version.major, self.version.minor, self.version.patch)
        let r = (rhs.version.major, rhs.version.minor, rhs.version.patch)
        if l == r { return .equal }
        return l > r ? .newer : .older
    }
    
    private func part(_ i: Int, of components: [Substring]) -> String? {
        components.indices.contains(i) ? String(components[i]) : nil
    }
}
