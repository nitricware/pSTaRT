//
//  PLSInput.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 10.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI
import CodeScanner
import CoreData

struct IdentificationInput: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding public var identification: String
    @Binding var isShowingScanner: Bool
    var onScannerDismiss: () -> Void = {}
    let onStart: (String) -> Void
    
    @State private var isTorchOn: Bool = false
    
    // Once target is iOS 27+, this lays the groundwork for .alert(error, actions)
    @State private var errorMessage: Error?
    @State private var showsErrorAlert: Bool = false
    
    @AppStorage(AppSettings.Key.scannerCodeTypes) private var storedTypes = AppSettings.Default.scannerCodeTypes
    @AppStorage(AppSettings.Key.identificationMaxLength) private var maxLength = AppSettings.Default.identificationMaxLength
    
    @State private var identificationRejection: Int = 0
    
    var body: some View {
        VStack {
            HStack {
                TextField("IDENTIFICATION", text: $identification)
                    .font(
                        .system(size: 36.0, weight: .regular, design: .monospaced)
                    )
                    .padding(.vertical, 8.0)
                    .minimumScaleFactor(0.1)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.none)
                    .keyboardType(.asciiCapable)
                    .onChange(of: identification) { _, newValue in
                        let scalars = newValue.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) }
                        var filtered = String(String.UnicodeScalarView(scalars))
                        
                        if filtered.count > maxLength { filtered = String(filtered.prefix(maxLength)) }
                        if filtered != newValue {
                            identification = filtered
                            identificationRejection += 1
                        }
                    }
                    .sensoryFeedback(.warning, trigger: identificationRejection)
                
                if !identification.isEmpty {
                    Button {
                        identification = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("CLEAR_IDENTIFICATION"))
                }
                
                Button(action: {
                    isShowingScanner.toggle()
                }) {
                    Image(systemName: "barcode.viewfinder")
                        .resizable()
                        .frame(width: 36.0, height: 36.0, alignment: .trailing)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 50.0)
            .padding()
            .glassEffect()
            
            Button(action: {
                do {
                    let id = identification.trimmingCharacters(in: .whitespacesAndNewlines)
                    try viewContext.validateNewIdentification(id)
                    onStart(id)
                } catch {
                    errorMessage = error
                    showsErrorAlert = true
                }
            }) {
                Text("START_TRIAGE")
                .font(
                    .system(size: 36.0, weight: .bold)
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .tint(.green)
        }
        
        // MARK: Scanner
        .sheet(isPresented: $isShowingScanner, onDismiss: onScannerDismiss) {
            // https://www.hackingwithswift.com/books/ios-swiftui/scanning-qr-codes-with-swiftui
            ZStack (alignment: .top) {
                CodeScannerView(
                    codeTypes: BarcodeType.decode(storedTypes).map(\.objectType),
                    simulatedData: "04 ASO SCANTEST123",
                    isTorchOn: isTorchOn,
                    completion: handleScan
                )
                .background(Color.red)
                .ignoresSafeArea()
                
                HStack {
                    Button {
                        isShowingScanner.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                    .controlSize(.large)
                    .tint(Color.red)
                    
                    Spacer()
                    
                    Button {
                        isTorchOn.toggle()
                    } label: {
                        Image(
                            systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill"
                        )
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                    .controlSize(.large)
                    .tint(Color.yellow)
                }
                .padding(20.0)
            }
        }
        .alert(errorMessage?.localizedDescription ?? String(localized: "common.unknownError"), isPresented: $showsErrorAlert) {
            Button("common.ok", role: .cancel) { }
            if (errorMessage as? pSTaRTErrors) == .duplicateID {
                Button("DUPLICATE_IGNORE", role: .confirm) {
                    onStart(identification.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        isTorchOn = false
        switch result {
        case .success(let result):
            let scanned = String(result.string.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) })
            if scanned.count > maxLength {
                self.showsErrorAlert.toggle()
                self.errorMessage = pSTaRTErrors.identificationTooLong
            } else {
                identification = String(scanned)
            }
        case .failure(let error):
            self.showsErrorAlert.toggle()
            self.errorMessage = pSTaRTErrors(scanError: error)
        }
    }
}

struct PLSInput_Previews: PreviewProvider {
    static var previews: some View {
        IdentificationInput(identification: .constant("TESTTRIAGE"),
                            isShowingScanner: .constant(false)) { _ in }
        .previewLayout(.sizeThatFits)
    }
}
