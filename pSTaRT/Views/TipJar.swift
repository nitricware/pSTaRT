//
//  TipJar.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 20.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import SwiftUI
import StoreKit

struct TipJar: View {
    @Binding public var isShowingTipJar: Bool
    @StateObject public var storeManager: StoreManager = StoreManager()
    @AppStorage("givenMoney") var tipJar: Double = 0.00
    
    // Once target is iOS 27+, this lays the groundwork for .alert(error, actions)
    @State private var errorMessage: Error?
    @State private var showsErrorAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack (spacing: 20) {
                Text("🚑")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.system(size: 200.0, weight: .bold, design: .default))
                Text("Support pSTaRT")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if storeManager.myProducts.count > 0 {
                    ForEach(storeManager.myProducts, id: \.self) { product in
                        Text("TIPJAR_INTRODUCTION \(product.displayPrice)")
                            .multilineTextAlignment(.leading)
                        Button(action: {
                            print("Purchasing \(product)")
                            Task {
                                do {
                                    try await storeManager.purchaseProduct(product: product)
                                } catch {
                                    
                                }
                            }

                        }) {
                            Text("TIPJAR_BUTTON \(product.displayPrice)")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glassProminent)
                    }
                } else {
                    Text("TIPJAR_LOADING")
                }
                
                Text("TIPJAR_THANKS \(Locale.current.currencySymbol ?? "") \(tipJar)")
            }
            .task {
                await storeManager.getProducts(productIDs: ["4euroTip"])
            }
            .multilineTextAlignment(.center)
            .padding()
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        self.isShowingTipJar.toggle()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .alert(errorMessage?.localizedDescription ?? String(localized: "common.unknownError"), isPresented: $showsErrorAlert) {
                Button("common.ok", role: .cancel) { }
            }
        }
        
    }
}

struct TipJar_Previews: PreviewProvider {
    static var previews: some View {
        Spacer()
            .sheet(isPresented: .constant(true)) {
                TipJar(
                    isShowingTipJar: .constant(true)
                )
            }
    }
}
