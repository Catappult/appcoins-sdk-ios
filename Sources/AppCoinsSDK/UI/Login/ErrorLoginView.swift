//
//  File.swift
//  
//
//  Created by aptoide on 20/12/2024.
//

import SwiftUI

struct ErrorLoginView: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @State private var toast: FancyToast? = nil
    
    var header: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                
                CloseButton(action: viewModel.dismiss)
                
                VStack{}.frame(width: 24)
            }
            .frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.width, height: 72)
            .background(BlurView(style: .systemMaterial))
            .onTapGesture { UIApplication.shared.dismissKeyboard() }
        }.frame(maxHeight: .infinity, alignment: .top)
    }
    
    var exclamationImageAndLabel: some View {
        VStack(spacing: 0) {
            Image("exclamation-red", bundle: Bundle.APPCModule)
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .frame(width: 80, height: 80)
            
            HStack{}.frame(height: 16)
            
            Text(Constants.errorText)
                .font(FontsUi.APC_Title3_Bold)
                .foregroundColor(ColorsUi.APC_Black)
            
            HStack{}.frame(height: 16)
            
            Text(Constants.somethingWentWrong)
                .font(FontsUi.APC_Footnote)
                .foregroundColor(ColorsUi.APC_Black)
        }
    }
    
    var tryAgainButton: some View {
        Button(action: { viewModel.setPurchaseState(newState: .paying) }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(ColorsUi.APC_Pink)
                
                Text(Constants.tryAgain)
                    .font(FontsUi.APC_Body_Bold)
                    .foregroundColor(ColorsUi.APC_White)
            }
        }.frame(width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 - 48 : UIScreen.main.bounds.width - 48, height: 50)
    }
    
    var supportButton: some View {
        Button(action: {
            var subject: String
            subject = "[iOS] Payment Support"
            
            if let subject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let emailURL = URL(string: "mailto:info@appcoins.io?subject=\(subject)") {
                UIApplication.shared.open(emailURL)
            } else {
                toast = FancyToast(type: .info, title: Constants.supportAvailableSoonTitle, message: Constants.supportAvailableSoonMessage)
            }
        }) {
            Text(Constants.appcSupport)
                .font(FontsUi.APC_Body_Bold)
                .foregroundColor(ColorsUi.APC_Pink)
        }
    }
    
    var errorBody: some View {
        VStack(spacing: 0) {
            HStack{}.frame(maxHeight: .infinity)
            
            exclamationImageAndLabel
            
            HStack{}.frame(maxHeight: .infinity)
            
            tryAgainButton
            
            HStack{}.frame(height: 20)
            
            supportButton
            
            HStack{}.frame(height: Utils.bottomSafeAreaHeight + 14)
        }.frame(alignment: .top)
    }
    
    var body: some View {
        ZStack {
            header
            
            errorBody
        }
    }
}
