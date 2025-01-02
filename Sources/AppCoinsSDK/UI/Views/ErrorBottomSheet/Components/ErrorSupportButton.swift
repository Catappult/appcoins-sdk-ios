//
//  ErrorSupportButton.swift
//
//
//  Created by aptoide on 02/01/2025.
//

import SwiftUI

internal struct ErrorSupportButton: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @Binding internal var toast: FancyToast?
    @State internal var address: String?
    
    internal var body: some View {
        Button(action: {
            var subject: String
            
            if let address = address { subject = "[iOS] Payment Support: \(address)" }
            else { subject = "[iOS] Payment Support" }
            
            if let subject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let emailURL = URL(string: "mailto:info@appcoins.io?subject=\(subject)") {
                UIApplication.shared.open(emailURL) { success in
                    if !success { toast = FancyToast(type: .info, title: Constants.supportAvailableSoonTitle, message: Constants.supportAvailableSoonMessage) }
                }
            } else {
                toast = FancyToast(type: .info, title: Constants.supportAvailableSoonTitle, message: Constants.supportAvailableSoonMessage)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(ColorsUi.APC_BackgroundLightGray_Button)
                
                Text(Constants.appcSupport)
                    .font(FontsUi.APC_Body_Bold)
                    .foregroundColor(ColorsUi.APC_Pink)
            }
        }
        .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
