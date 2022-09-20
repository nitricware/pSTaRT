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
    @ObservedObject public var storeManager: StoreManager = StoreManager()
    @AppStorage("givenMoney") var tipJar: Double = 0.00
    
    var body: some View {
        NavigationView {
            VStack (spacing: 20) {
                Text("TIPJAR_INTRODUCTION")
                if storeManager.myProducts.count > 0 {
                    ForEach(storeManager.myProducts, id: \.self) { product in
                        Button(action: {
                            print("Purchasing \(product)")
                            storeManager.purchaseProduct(product: product)
                        }) {
                            Text("TIPJAR_BUTTON \(product.priceLocale.currencySymbol ?? "") \(product.price)")
                        }
                    }
                } else {
                    Text("TIPJAR_LOADING")
                }
                
                Text("TIPJAR_THANKS \(Locale.current.currencySymbol ?? "") \(tipJar)")
            }
            .multilineTextAlignment(.center)
            .padding()
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        self.isShowingTipJar.toggle()
                    }) {
                        Image(systemName: "xmark.circle")
                    }
                }
            }
            .navigationTitle("TIPJAR_TITLE")
        }
        .onAppear {
            storeManager.getProducts(productIDs: ["4euroTip"])
            SKPaymentQueue.default().add(storeManager)
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
