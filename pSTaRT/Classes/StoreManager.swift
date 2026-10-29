//
//  StoreManager.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 20.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//  Updated for StoreKit 2 on 9.6.2026
//

import StoreKit

class StoreManager: ObservableObject {
    @Published var myProducts: [Product] = []
    
    @MainActor
    func getProducts(productIDs: [String]) async {
        do {
            myProducts = try await Product.products(for: productIDs)
        } catch {
            print(error)
        }
    }
    
    func purchaseProduct(product: Product) async throws {
        if AppStore.canMakePayments {
            let payment = try await product.purchase()
            switch payment {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    if let price = transaction.price {
                        let currentTipJar = UserDefaults.standard.double(forKey: "givenMoney")
                        UserDefaults.standard.set(currentTipJar + Double(truncating: price as NSNumber), forKey: "givenMoney")
                    }
                    await transaction.finish()
                }
            case .userCancelled:
                break
            default:
                break
            }
        } else {
            throw pSTaRTErrors.purchaseUnableToPurchase
        }
    }
}
