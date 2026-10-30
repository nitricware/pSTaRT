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
    
    // MARK: Bindings from parent
    @Binding public var isShowingTriage: Bool
    
    // MARK: Sheet States
    @State private var isShowingScanner: Bool = false
    
    @State private var isTorchOn: Bool = false
    
    // Once target is iOS 27+, this lays the groundwork for .alert(error, actions)
    @State private var errorMessage: Error?
    @State private var showsErrorAlert: Bool = false
    
    @Binding public var identification: String
    
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
                if identification.isEmpty {
                    errorMessage = pSTaRTErrors.emptyInput
                    showsErrorAlert.toggle()
                    return
                }
            
                do {
                    let duplicateCheck = try viewContext.isDuplicate(id: identification)
                    if duplicateCheck {
                        errorMessage = pSTaRTErrors.duplicateID
                        showsErrorAlert.toggle()
                        return
                    }
                } catch {
                    errorMessage = error
                    showsErrorAlert.toggle()
                    return
                }
                self.isShowingTriage.toggle()
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
        .sheet(isPresented: $isShowingScanner) {
            // https://www.hackingwithswift.com/books/ios-swiftui/scanning-qr-codes-with-swiftui
            ZStack (alignment: .top) {
                CodeScannerView(
                    // Code39: ASB
                    codeTypes: [.code39],
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
                    self.isShowingTriage.toggle()
                }
            }
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        isTorchOn = false
        switch result {
        case .success(let result):
            self.identification = result.string
        case .failure(let error):
            self.showsErrorAlert.toggle()
            self.errorMessage = error
        }
    }
}

struct PLSInput_Previews: PreviewProvider {
    static var previews: some View {
        IdentificationInput(
            isShowingTriage: .constant(false), identification: .constant("TESTTRIAGE")
        )
        .environmentObject(CurrentTriage(identification: "PREVIEW"))
        .previewLayout(.sizeThatFits)
    }
}
