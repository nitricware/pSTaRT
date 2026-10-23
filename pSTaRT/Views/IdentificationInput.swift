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
    //@EnvironmentObject public var currentTriage: CurrentTriage
    @Binding public var isShowingTriage: Bool
    
    // MARK: Sheet States
    @State private var isShowingScanner: Bool = false
    
    // MARK: Alert States
    @State private var isShowingScannerError: Bool = false
    @State private var isShowingIDError: Bool = false
    @State private var isShowingEmptyError: Bool = false
    @State private var errorText: String = ""
    
    @State private var isTorchOn: Bool = false
    
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
                    self.isShowingEmptyError.toggle()
                    return
                }
            
                do {
                    let database = pSTaRTDBHelper()
                    let duplicateCheck = try database.isDuplicate(id: identification)
                    if duplicateCheck {
                        self.isShowingIDError.toggle()
                        return
                    }
                } catch {
                    self.isShowingIDError.toggle()
                    return
                }
                //self..reset(with: identification)
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
        
        // MARK: Alerts
        .alert("SCAN_ERROR_TITLE", isPresented: $isShowingScannerError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("SCAN_ERROR_TEXT")
            Text(errorText)
        }
        .alert("ID_ERROR_TITLE", isPresented: $isShowingIDError) {
            Button("DUPLICATE_IGNORE", role: .confirm) {
                self.isShowingTriage.toggle()
            }
            Button("DUPLICATE_CHANGE", role: .cancel) { }
        } message: {
            Text("ID_ERROR_TEXT")
        }
        .alert("EMPTY_ERROR_TITLE", isPresented: $isShowingEmptyError) {
            Button("DUPLICATE_CHANGE", role: .cancel) { }
        } message: {
            Text("EMPTY_ERROR_TEXT")
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        isTorchOn = false
        switch result {
        case .success(let result):
            self.identification = result.string
        case .failure(let error):
            self.isShowingScannerError.toggle()
            self.errorText = error.localizedDescription
        }
    }
}

struct PLSInput_Previews: PreviewProvider {
    static var previews: some View {
        IdentificationInput(
            isShowingTriage: .constant(false), identification: .constant("TESTTRIAGE")
        )
        .environmentObject(CurrentTriage())
        .previewLayout(.sizeThatFits)
    }
}
