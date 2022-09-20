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
    @EnvironmentObject public var currentTriage: CurrentTriage
    @Binding public var isShowingTriage: Bool
    
    // MARK: Sheet States
    @State private var isShowingScanner: Bool = false
    
    // MARK: Alert States
    @State private var isShowingScannerError: Bool = false
    @State private var isShowingIDError: Bool = false
    @State private var isShowingEmptyError: Bool = false
    @State private var errorText: String = ""
    
    var body: some View {
        VStack {
            HStack {
                // TextField("IDENTIFICATION", text: $currentTriage.identification)
                TextField("IDENTIFICATION", text: $currentTriage.identification)
                    .font(
                        .system(size: 36.0, weight: .regular, design: .monospaced)
                    )
                    .minimumScaleFactor(0.1)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.none)
                    .frame(maxHeight: 40.0)
                Button(action: {
                    isShowingScanner.toggle()
                }) {
                    Image(systemName: "barcode.viewfinder")
                        .resizable()
                        .frame(width: 36.0, height: 36.0, alignment: .trailing)
                }
                .onDisappear{
                    self.currentTriage.identification = ""
                }
            }
            
            Button(action: {
                if currentTriage.identification.isEmpty {
                    self.isShowingEmptyError.toggle()
                    return
                }
            
                do {
                    let database = pSTaRTDBHelper()
                    let duplicateCheck = try database.isDuplicate(id: currentTriage.identification)
                    if duplicateCheck {
                        self.isShowingIDError.toggle()
                        return
                    }
                } catch {
                    self.isShowingIDError.toggle()
                    return
                }
                self.currentTriage.reset(with: currentTriage.identification)
                self.isShowingTriage.toggle()
            }) {
                Text("START_TRIAGE")
                    .font(
                        .system(size: 36.0, weight: .bold, design: .default)
                    )
            
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle)
            .tint(.green)
            
        }
        // MARK: Scanner
        .sheet(isPresented: $isShowingScanner) {
            // https://www.hackingwithswift.com/books/ios-swiftui/scanning-qr-codes-with-swiftui
            CodeScannerView(
                codeTypes: [.code39],
                simulatedData: "04 ASO SCANTEST123",
                isTorchOn: true,
                completion: handleScan)
            .ignoresSafeArea()
        }
        // MARK: Alerts
        .alert("SCAN_ERROR_TITLE", isPresented: $isShowingScannerError) {
            Text("SCAN_ERROR_TEXT")
            Text(errorText)
            Button("OK", role: .cancel) { }
        }
        .alert("ID_ERROR_TITLE", isPresented: $isShowingIDError) {
            Text("ID_ERROR_TEXT")
            Button("DUPLICATE_IGNORE") {
                self.isShowingTriage.toggle()
            }
            Button("DUPLICATE_CHANGE", role: .cancel) { }
        }
        .alert("EMPTY_ERROR_TITLE", isPresented: $isShowingEmptyError) {
            Text("EMPTY_ERROR_TEXT")
            Button("DUPLICATE_CHANGE", role: .cancel) { }
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            self.currentTriage.identification = result.string
        case .failure(let error):
            self.isShowingScannerError.toggle()
            self.errorText = error.localizedDescription
        }
    }
}

struct PLSInput_Previews: PreviewProvider {
    static var previews: some View {
        IdentificationInput(
            isShowingTriage: .constant(false)
        )
        .environmentObject(CurrentTriage())
        .previewLayout(.sizeThatFits)
    }
}
