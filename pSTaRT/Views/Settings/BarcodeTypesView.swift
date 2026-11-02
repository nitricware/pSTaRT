//
//  BarcodeTypesView.swift
//  pSTaRT
//
//  Created by Kurt Frey on 02.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import SwiftUI

struct BarcodeTypesView: View {
    @AppStorage(AppSettings.Key.scannerCodeTypes) private var storedTypes = AppSettings.Default.scannerCodeTypes

    private var selection: Set<BarcodeType> { BarcodeType.decode(storedTypes) }

    var body: some View {
        Form {
            section("BARCODE_1D", types: BarcodeType.allCases.filter { !$0.isTwoDimensional })
            section("BARCODE_2D", types: BarcodeType.allCases.filter(\.isTwoDimensional))
            Section {
            } footer: {
                Text("BARCODE_TYPES_FOOTER")
            }
        }
        .navigationTitle("SCANNER_CODE_TYPES")
    }

    private func section(_ title: LocalizedStringKey, types: [BarcodeType]) -> some View {
        Section(title) {
            ForEach(types) { type in
                let isSelected = selection.contains(type)
                Button {
                    toggle(type)
                } label: {
                    HStack {
                        Text(type.displayName)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .foregroundStyle(.primary)
                // the last selected type cannot be removed
                .disabled(isSelected && selection.count == 1)
            }
        }
    }

    private func toggle(_ type: BarcodeType) {
        var types = selection
        if types.contains(type) {
            types.remove(type)
        } else {
            types.insert(type)
        }
        storedTypes = BarcodeType.encode(types)
    }
}
