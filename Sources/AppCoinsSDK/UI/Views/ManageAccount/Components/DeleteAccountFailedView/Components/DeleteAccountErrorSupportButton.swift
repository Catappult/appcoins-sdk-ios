//
//  DeleteAccountErrorSupportButton.swift
//  AppCoinsSDK
//
//  Created by aptoide on 26/05/2025.
//

import SwiftUI

internal struct DeleteAccountErrorSupportButton: View {
    
    @Binding internal var toast: FancyToast?
    
    internal var body: some View {
        Button(action: {
            var subject: String
            subject = "[iOS] Payment Support"
            
            if let subject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let emailURL = URL(string: "mailto:info@appcoins.io?subject=\(subject)") {
                UIApplication.shared.open(emailURL) { success in
                    if !success { toast = FancyToast(type: .info, title: Constants.supportAvailableSoonTitle, message: Constants.supportAvailableSoonMessage) }
                }
            } else {
                toast = FancyToast(type: .info, title: Constants.supportAvailableSoonTitle, message: Constants.supportAvailableSoonMessage)
            }
        }) {
            Text(Constants.appcSupport)
                .font(FontsUi.APC_Body_Bold)
                .foregroundColor(ColorsUi.APC_Pink)
        }
    }
}
