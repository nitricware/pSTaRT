//
//  NWIAPListener.swift
//  pSTaRT
//
//  Created by Kurt Frey on 10.06.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//
//  https://developer.apple.com/documentation/storekit/transaction/updates#Discussion
//  alternative: https://github.com/superwall/CaffeinePal/tree/finished
//  not used here, because .updates only applies to purchaes outdside of the app (see https://developer.apple.com/documentation/storekit/transaction/updates)

import StoreKit

@Observable
final class NWIAPListener {
    
    var updates: Task<Void, Never>? = nil
    
    init() {
        updates = newTransactionListenerTask()
    }


    deinit {
        // Cancel the update handling task when you deinitialize the class.
        updates?.cancel()
    }
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                await self.handle(updatedTransaction: verificationResult)
            }
        }
    }
    
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            return
        }
        // Here should be code to handle different kinds of transactions, like revocation, expiration, etc.
        // This is not really required for this app. So whenever handle() fires, we add the price to the
        // internal counter (UserDefaults) which will be reset on re-install of the app anyway.
        if let price = transaction.price {
            let currentTipJar = UserDefaults.standard.double(forKey: "givenMoney")
            UserDefaults.standard.set(currentTipJar + Double(truncating: price as NSNumber), forKey: "givenMoney")
        }
        
        await transaction.finish()
    }
}
