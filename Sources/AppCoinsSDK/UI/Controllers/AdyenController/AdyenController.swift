//
//  AdyenController.swift
//  
//
//  Created by aptoide on 29/08/2023.
//

import SwiftUI
@_implementationOnly import Adyen
@_implementationOnly import AdyenSession
@_implementationOnly import AdyenCard
@_implementationOnly import AdyenComponents
@_implementationOnly import AdyenActions

internal class AdyenController : AdyenSessionDelegate, PresentationDelegate, ObservableObject {
    
    internal static var shared: AdyenController = AdyenController()
    
    internal var session: AdyenSession? = nil
    internal var context: AdyenContext? = nil
    internal var transactionUID: String? = nil
    internal var method: Method? = nil
    
    internal var successHandler: ((_ method: Method, _ transactionUID: String) -> Void)?
    internal var awaitHandler: ((_ message: String, _ description: String) -> Void)?
    internal var failedHandler: ((_ message: String, _ description: String) -> Void)?
    internal var cancelHandler: (() -> Void)?
    
    @Published internal var presentableComponent: PresentableComponent? = nil
    @Published internal var redirectComponent: RedirectComponent? = nil
    @Published internal var isAdyenRedirectPresented: Bool = false
    
    @Published internal var state: AdyenState = .none
    
    internal func startSession(method: Method, value: Decimal, currency: String, session: AdyenTransactionSession, successHandler: @escaping (_ method: Method, _ transactionUID: String) -> Void, awaitHandler: @escaping (_ message: String, _ description: String) -> Void, failedHandler: @escaping (_ message: String, _ description: String) -> Void, cancelHandler: @escaping () -> Void) {
        
        // successHandler and awaitHandler can be the same if the verification is always done with APPC service
        self.successHandler = successHandler
        self.awaitHandler = awaitHandler
        self.failedHandler = failedHandler
        self.cancelHandler = cancelHandler
        
        self.transactionUID = session.transactionUID
        self.method = method
        
        DispatchQueue.main.async {
            
            let clientKey = Utils.getAdyenGatewayAccess()

            // Set the client key and environment in an instance of APIContext.
            if let apiContext = try? APIContext(environment: BuildConfiguration.adyenEnvironment, clientKey: clientKey), let countryCode = Utils.getCountryCode() {
                
                // Create the amount with the value in minor units and the currency code.
                let amount = Amount(value: value, currencyCode: currency)
                // Create the payment object with the amount and country code.
                let payment = Payment(amount: amount, countryCode: countryCode)
                // Create an instance of AdyenContext, passing the instance of APIContext, payment object, and optional analytics configuration.
                // Payment object is used to specify the value that appears on the Pay button, if no value is specified than the button will display just "Pay"
                // Add Analytics Configuration Later On
                let adyenContext = AdyenContext(apiContext: apiContext, payment: nil)
                self.context = adyenContext
                
                let configuration = AdyenSession.Configuration(
                    sessionIdentifier: session.sessionID, // The id from the API response.
                    initialSessionData: session.sessionData,
                    context: adyenContext
                )

                AdyenSession.initialize(with: configuration, delegate: self, presentationDelegate: self) { [weak self] result in
                    switch result {
                    case let .success(session):
                        //Store the session object.
                        self?.session = session
                        
                        if let paymentMethods = self?.session?.sessionContext.paymentMethods {
                            if method == .creditCard {
                                if paymentMethods.stored.isEmpty {
                                    if let paymentMethod = paymentMethods.paymentMethod(ofType: CardPaymentMethod.self) {
                                        self?.setUpNewCreditCardComponent(paymentMethod: paymentMethod, adyenContext: adyenContext)
                                    } else { failedHandler("Failed to initialize an Adyen session", "There is no payment method at AdyenController.swift:startSession") }
                                } else {
                                    DispatchQueue.main.async { self?.state = .choosingCreditCard }
                                }
                            } else if method == .paypalAdyen {
                                if let paymentMethod = paymentMethods.regular.first(where: {$0.name == "PayPal"}) {
                                    self?.setUpPayPalRedirectComponent(paymentMethod: paymentMethod, adyenContext: adyenContext)
                                } else { failedHandler("Failed to initialize an Adyen session", "There is no Paypal method available at AdyenController.swift:startSession") }
                            } else { failedHandler("Failed to initialize an Adyen session", "There is no payment method at AdyenController.swift:startSession") }
                        } else { failedHandler("Failed to initialize an Adyen session", "There are no payment methods at AdyenController.swift:startSession") }
                        
                    case .failure(let error):
                        failedHandler("Failed to initialize an Adyen session", "Error: \(error.localizedDescription) at AdyenController.swift:startSession")
                    }
                }
            } else {
                failedHandler("Failed to initialize an Adyen session", "There is no client API context at AdyenController.swift:startSession")
            }
        }
    }
    
    internal func handleRedirectURL(redirectURL: URL?) -> Bool {
        if let redirectURL = redirectURL, let bundleIdentifier = Bundle.main.bundleIdentifier, redirectURL.scheme == bundleIdentifier + ".iap" {
            RedirectComponent.applicationDidOpen(from: redirectURL)
            return true
        }
        return false
    }
    
    internal func present(component: Adyen.PresentableComponent) {
        DispatchQueue.main.async { self.presentableComponent = component }
    }
    
    internal func didComplete(with result: AdyenSessionResult, component: any Adyen.Component, session: AdyenSession) {
        
        if component is RedirectComponent { self.isAdyenRedirectPresented = false }
        
        switch result.resultCode {
            
            // The payment was successfully authorised.
        case .authorised:
            if let successHandler = successHandler {
                if let transactionUID = transactionUID, let method = method {
                    successHandler(method, transactionUID)
                } else {
                    if let failedHandler = failedHandler { failedHandler("Failed Adyen Payment", "Missing required parameters: transaction uid is nil or payment method is nil. ResultCode: \(result.resultCode.rawValue) at AdyenController.swift:didComplete") }
                }
            }
            // The payment was refused. The response also contains a refusal reason that indicates why it was refused.
        case .refused:
            if let failedHandler = failedHandler { failedHandler("Failed Adyen Payment", "Payment was refused for the method: \(self.method?.rawValue ?? ""). ResultCode: \(result.resultCode.rawValue) at AdyenController.swift:didComplete") }
            
            // The final status of the payment isn't available yet. This is common for payments with an asynchronous flow, such as Boleto or iDEAL.
        case .pending:
            if let awaitHandler = awaitHandler { awaitHandler("Failed Adyen Payment", "Payment is pending for the method: \(self.method?.rawValue ?? ""). ResultCode: \(result.resultCode.rawValue) at AdyenController.swift:didComplete") }
            
            // The payment was cancelled (by either the shopper or your system) before processing was completed.
        case .cancelled:
            if let cancelHandler = cancelHandler { cancelHandler() }
            
            // An error occurred during payment processing. The response also contains an error code that gives more details about the error.
        case .error:
            if let failedHandler = failedHandler { failedHandler("Failed Adyen Payment", "An error occurred regarding the payment with method: \(self.method?.rawValue ?? ""). ResultCode: \(result.resultCode.rawValue) at AdyenController.swift:didComplete") }
            
            // The payment request was received, but the final status of the payment isn't available yet. Some payments, like SEPA Direct Debit, take time to process.
        case .received:
            if let awaitHandler = awaitHandler { awaitHandler("Failed Adyen Payment", "The payment status isn't available for method: \(self.method?.rawValue ?? ""). ResultCode: \(result.resultCode.rawValue) at AdyenController.swift:didComplete") }
            
            // Show the voucher or QR code to the shopper. Won't be used for Credit Card Payments.
        case .presentToShopper:
            // Replace later if payment method that uses vouchers or QR codes is integrated.
            if let failedHandler = failedHandler { failedHandler("Failed Adyen Payment", "A Voucher or QR code were presented to the shopper. ResultCode: \(result.resultCode.rawValue) at AdyenController.swift:didComplete") }
        }
    }

    internal func didFail(with error: Error, from component: Adyen.Component, session: AdyenSession) {
        if let componentError = error as? Adyen.ComponentError {
            switch componentError {
            case .cancelled:
                if let cancelHandler = self.cancelHandler { cancelHandler() }
            case .paymentMethodNotSupported:
                if let failedHandler = self.failedHandler { failedHandler("Failed Adyen Payment", "Payment method not supported at AdyenController.swift:didFail") }
            }
        } else if let failedHandler = self.failedHandler { failedHandler("Failed Adyen Payment", "Component error is nil at AdyenController.swift:didFail") }
    }
    
    internal func cancel() {
        if let cancelHandler = self.cancelHandler { cancelHandler() }
    }
    
    private func setUpChooseCreditCardComponent() {
        DispatchQueue.main.async { self.state = .choosingCreditCard }
    }
    
    internal func chooseNewCreditCardPayment() {
        if let paymentMethods = self.session?.sessionContext.paymentMethods, let paymentMethod = paymentMethods.paymentMethod(ofType: CardPaymentMethod.self), let context = context {
            setUpNewCreditCardComponent(paymentMethod: paymentMethod, adyenContext: context)
        }
    }
    
    internal func chooseStoredCreditCardPayment(paymentMethod: StoredCardPaymentMethod) {
        let paymentMethod = paymentMethod as AnyCardPaymentMethod
        if let context = context {
            setUpStoredCreditCardComponent(paymentMethod: paymentMethod, adyenContext: context)
        }
    }
    
    private func setUpNewCreditCardComponent(paymentMethod: AnyCardPaymentMethod, adyenContext: AdyenContext) {
        DispatchQueue.main.async { self.state = .newCreditCard }
        
        let style = self.getCreditCardFormStyle()
        
        let cardComponentConfiguration = CardComponent.Configuration(style: style, showsStorePaymentMethodField: true)
        
        let cardComponent = CardComponent(paymentMethod: paymentMethod,
                                          context: adyenContext,
                                          configuration: cardComponentConfiguration)
        
        cardComponent.update(storePaymentMethodFieldVisibility: true)
        cardComponent.update(storePaymentMethodFieldValue: true)
        
        // Set the session as the delegate.
        cardComponent.delegate = session
        self.present(component: cardComponent)
    }
    
    private func setUpStoredCreditCardComponent(paymentMethod: AnyCardPaymentMethod, adyenContext: AdyenContext) {
        DispatchQueue.main.async { self.state = .storedCreditCard }
        
        let cardComponent = CardComponent(paymentMethod: paymentMethod, context: adyenContext)
        
        // Set the session as the delegate.
        cardComponent.delegate = session
        
        self.present(component: cardComponent)
        
        let alertController = cardComponent.viewController
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController,
               let presentedPurchaseVC = rootViewController.presentedViewController as? PurchaseViewController {
                alertController.removeFromParent()
                presentedPurchaseVC.present(alertController, animated: true)
        }
    }
    
    private func setUpPayPalRedirectComponent(paymentMethod: Adyen.PaymentMethod, adyenContext: AdyenContext) {
        DispatchQueue.main.async { self.state = .paypal }
        
        let paypalComponent = InstantPaymentComponent(paymentMethod: paymentMethod,
                                                      context: adyenContext,
                                                      order: nil)
        paypalComponent.delegate = session
        paypalComponent.initiatePayment()
        self.isAdyenRedirectPresented = true
        
        let component = RedirectComponent(context: adyenContext)
        component.delegate = session
        component.presentationDelegate = self
        self.redirectComponent = component
    }
    
    private func getCreditCardFormStyle() -> FormComponentStyle {
        var style = FormComponentStyle()
        
        style.backgroundColor = UIColor(ColorsUi.APC_LightGray)
        style.textField.title.color = UIColor(ColorsUi.APC_DarkGray)
        style.textField.text.color = UIColor(ColorsUi.APC_Black)
        
        style.textField.tintColor = UIColor(ColorsUi.APC_Black)
        
        style.textField.placeholderText?.color = UIColor(ColorsUi.APC_LightGray)
        style.textField.placeholderText?.font = UIFont(name: "SFProText-Semibold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        style.mainButtonItem.button.backgroundColor = UIColor(ColorsUi.APC_Pink)
        style.mainButtonItem.button.cornerRounding = .fixed(10)
        style.mainButtonItem.button.title.color = UIColor(ColorsUi.APC_White)
        style.mainButtonItem.button.title.font = UIFont(name: "SFProText-Semibold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        style.toggle.title.color = UIColor(ColorsUi.APC_Black)
        style.toggle.title.textAlignment = .right
        style.toggle.title.font = UIFont(name: "SFProText-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        style.toggle.tintColor = UIColor(ColorsUi.APC_Pink)
        
        return style
    }
    
    internal func getCardLogo(for paymentMethod: StoredCardPaymentMethod) -> URL? {
        return LogoURLProvider(environment: BuildConfiguration.adyenEnvironment).logoURL(withName: paymentMethod.brand.rawValue)
    }
    
    internal func reset() {
        DispatchQueue.main.async {
            self.state = .none
            self.session = nil
            self.context = nil
            self.presentableComponent = nil
        }
    }
    
    internal enum AdyenState {
        case none
        case choosingCreditCard
        case newCreditCard
        case storedCreditCard
        case paypal
    }
}
