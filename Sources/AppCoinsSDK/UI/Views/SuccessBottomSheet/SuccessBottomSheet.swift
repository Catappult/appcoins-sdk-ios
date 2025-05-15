//
//  SuccessBottomSheet.swift
//  
//
//  Created by aptoide on 08/03/2023.
//

import SwiftUI

internal struct SuccessBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    
    @State internal var isPresented: Bool = false
    
    internal var body: some View {
        ZStack {
            ColorsUi.APC_BottomSheet_LightGray_Background
            
            if case let .direct(transaction) = transactionViewModel.transaction {
                WebshopSuccessView()
            } else {
                if authViewModel.isLoggedIn {
                    LoggedInSuccessView()
                } else {
                    LoggedOutSuccessView()
                }
            }
            
            VStack(spacing: 0) {
                DismissHeader()
                HStack{}.frame(maxHeight: .infinity)
            }
        }.frame(
            width: viewModel.orientation == .landscape ? UIScreen.main.bounds.width - 176 : UIScreen.main.bounds.size.width,
            height: viewModel.orientation == .landscape ? UIScreen.main.bounds.height * 0.9 : 420
        )
        .cornerRadius(13, corners: [.topLeft, .topRight])
        .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
        .transition(.move(edge: isPresented ? .bottom : .top))
        .onAppear { withAnimation(.easeIn) { isPresented = true } }
    }
}
