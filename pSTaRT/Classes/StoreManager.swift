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
    
    private var productDict = [String: Double]()
    
    @MainActor
    func getProducts(productIDs: [String]) async {
        do {
            myProducts = try await Product.products(for: productIDs)
        } catch {
            print(error)
        }
    }
    
    func purchaseProduct(product: Product) async {
        if AppStore.canMakePayments {
            print("purchasing product ... \(product)")
            do {
                let payment = try await product.purchase()
                switch payment {
                case .success(let verification):
                    if case .verified(let transaction) = verification {
                        print("Purchase successful: \(transaction.id)")
                        await transaction.finish()
                        let currentTipJar = UserDefaults.standard.double(forKey: "givenMoney")
                        UserDefaults.standard.set(currentTipJar + Double(truncating: transaction.price! as NSNumber), forKey: "givenMoney")
                    }
                case .userCancelled:
                    print("User cancelled the purchase.")
                default:
                    break
                }
            } catch {
                print(error)
            }
        } else {
            print("User can't make payment.")
        }
    }
}
