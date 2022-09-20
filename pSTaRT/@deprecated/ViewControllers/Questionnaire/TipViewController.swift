//
//  TipViewController.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 21.01.21.
//  Copyright © 2021 Kurt Höblinger. All rights reserved.
//

/*
 This ViewController (VC) can be understood as an ongoing tutorial
 for In-App-Purchases (IAP) in UIKit. SwiftUI is a different
 story unfortunately.
 
 *Disclaimer:* If the code is expressive, a comment will
 be omitted (i.e. in the viewDidLoad() function)
 
 The VC must inherit from UIViewController of course but also from
 SKProductsRequestDelegate because it requests which IAPs are
 available and from SKPaymentTransactionObserver because the VC
 doesn't just act as a store front that displays the IAPs but
 also as a check out where the transactions happen.
 
 Througout the code, the requested products will be referenced.
 Thus, the VC has a private var that is an array of the requested
 products.
 
 In App Store Connect (ASC) the following things must be done:

 TODO: Copy reddit post
 */

import UIKit
import StoreKit

class TipViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    private var products: [SKProduct] = [SKProduct]()

    @IBOutlet weak var tipDescription: UILabel!
    @IBOutlet weak var giveButton: UIButton!
    @IBOutlet weak var tipStatus: UILabel!
    
    override func viewDidLoad() {
        self.giveButton.isEnabled = false
        self.giveButton.setTitle(
            NSLocalizedString("WAIT_FOR_REQUEST", comment: "please wait..."),
            for: .normal
        )
        self.fetchProducts()
        super.viewDidLoad()
        self.updateTipStatus()
    }
    
    private func updateTipStatus() {
        tipStatus.text = String(
            format: NSLocalizedString("TIP_CURRENT_STATE", comment: "current state"),
            UserDefaults.standard.float(forKey: "givenMoney")
        )
    }
    
    @IBAction func closeSheet(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func purchaseTip(_ sender: Any) {
        /*
         This code is smelly. Since this app currently only has one IAP,
         this if let construct checks if the product request aleready
         finished and then loads the first product into variable p.
         */
        if let p = products.first {
            self.purchase(product: p)
        } else {
            let ac = NWUtils.createSimpleAlert(
                title: NSLocalizedString("TIP_NOT_READY_HEAD", comment: "not ready"),
                message: NSLocalizedString("TIP_NOT_READY_BODY", comment: "not ready"),
                dismiss: NSLocalizedString("OK", comment: "not ready")
            )
            self.show(ac, sender: self)
        }
    }
    
    /*
     MARK: In-App-Purchase Code
     The actual IAP Code starts here. There are three fundamental steps:
     - fetching: Request the IAPs by referencing their identifier
     - buy: initiate the buy process
     - observe: You need to wait for the products to be fetched and for the
         payment to go thru.
     */
    
    /*
     MARK: Fetch
     In order to be able to reference the products later, this code
     loads the specified productIdentifiers. Do not confuse this with
     a different API that could fetch all the product identifiers before.
     
     The identifier is exactly what was entered in App Store Connect.
     There is no developer identification (com.developer) prepended.
     */
    private func fetchProducts() {
        print("Products requested.")
        let request = SKProductsRequest(productIdentifiers: ["4euroTip"])
        request.delegate = self
        request.start()
    }
    
    /*
     MARK: Buy
     Buying involves adding this VC as delegate to handle tha callbacks
     and adding a payment to a SKPaymentQueue.
     */
    
    private func purchase(product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        
        let payment = SKPayment(product: product)
        // This VC is added as the delegate
        SKPaymentQueue.default().add(self)
        // Here, the payment is added to the PaymentQueue
        SKPaymentQueue.default().add(payment)
    }
    
    /*
     MARK: observe
     Observation starts as soon as the products are requests and ends once
     the payments went thru and are done.
     */
    
    /// Called once the request for products is finished.
    /// Here, the function alters the descriptive labels in the VC with
    /// the price of the product on the main thread
    /// - Parameters:
    ///   - request: The initial request
    ///   - response: The response
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) -> Void {
        print("Products received.")
        self.products = response.products
        
        DispatchQueue.main.async {
            if let p = self.products.first {
                self.tipDescription.text = String(
                    format: NSLocalizedString("TIP_DESCRIPTION", comment: "description with value"),
                    p.price as! Double
                )
                self.giveButton.setTitle(
                    String(
                        format: NSLocalizedString("TIP_PURCHASE_BUTTON", comment: "description with value"),
                        p.price as! Double
                    ),
                    for: .normal
                )
                self.giveButton.isEnabled = true
            }
        }
    }
    
    /// Called if the request threw an error.
    /// This implementation checks if the error is because of the
    /// SKProductRequest.
    /// - Parameters:
    ///   - request: The throwing request
    ///   - error: The thrown error
    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard request is SKProductsRequest else {
            return
        }
        
        print("Error: \(error.localizedDescription)")
    }
    
    
    /// Called multiple times during the purchase process
    /// - Parameters:
    ///   - queue: The queue in question
    ///   - transactions: The transaction that triggered this function
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({ transaction in
            /*
             Currently, this app only has one product.
             The 4,- tip. The productIdentifier of the transaction must match.
             
             If this app had more than just one product and it makes a difference
             which product just got processed (i.e. enable different features, add
             different values to a counter) the code had to check which payment went
             thru.
             */
            guard transaction.payment.productIdentifier == products.first?.productIdentifier else {
                return
            }
            
            switch transaction.transactionState {
                case .purchasing:
                    /*
                     This case matches as soon as the Confirm dialog of the app store appears.
                     */
                    print("Purchasing of \(transaction.payment.productIdentifier) commenced.")
            case .purchased, .restored:
                    /*
                     Fired once the user dismissed the success dialogue from iOS.
                     Since the payment went thru, the code now has to finish the
                     transaction. Without this code, the transaction stays in the
                     queue and leads to shenannigans.
                 
                     Restoring consumable IAPs is not possible.
                     */
                    print("Purchasing of \(transaction.payment.productIdentifier) finished.")
                    SKPaymentQueue.default().finishTransaction(transaction)
                    
                    /*
                     To show the user the amount of money they've given, a counter
                     in the app's UserDefaults is incremented. The label displaying
                     this counter is then updated.
                     */
                    let money = UserDefaults.standard.float(forKey: "givenMoney")
                    UserDefaults.standard.setValue(Float(truncating: products.first!.price) + money, forKey: "givenMoney")
                    self.updateTipStatus()
                    print("Adding \(Float(truncating: products.first!.price)) to money bank containig \(money)")
                    
                    let ac = NWUtils.createSimpleAlert(
                        title: NSLocalizedString("THANKS_HEAD", comment: "header"),
                        message: NSLocalizedString("THANKS_BODY", comment: "body"),
                        dismiss: NSLocalizedString("OK", comment: "confirm")
                    )
                    
                    self.show(ac, sender: self)
                case .deferred:
                    /*
                     Triggered, when the purchase needs confirmation by a parent for example.
                     The transaction is not finished yet.
                     */
                    print("Payment of \(transaction.payment.productIdentifier) was deferred.")
                    /*
                     TODO: display alert that says thank you, but value might not be displayed
                     waiting for confirmation and then triggering something would be to much hassle)
                     */
                case .failed:
                    /*
                     Fired if the purchase is not completed.
                     Could also be that the user cancelled.
                     Since the transaction is technically finished, the
                     code must finish the transaction.
                     */
                    print("Purchasing of \(transaction.payment.productIdentifier) failed.")
                    SKPaymentQueue.default().finishTransaction(transaction)
            @unknown default:
                /*
                 If - at any time in the future - apple decides to add another
                 state that is not handled above, this part of the switch will
                 trigger and throw a fatal error. Thanks Obama. Erm Apple.
                 */
                fatalError()
            }
        })
    }
}
