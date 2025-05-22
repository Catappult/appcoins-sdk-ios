//
//  ManageAccountBottomSheet.swift
//  AppCoinsSDK
//
//  Created by aptoide on 21/05/2025.
//

import SwiftUI

internal struct ManageAccountBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    @ObservedObject internal var authViewModel: AuthViewModel
    
    internal var body: some View {
        if #available(iOS 16.4, *) {
            if viewModel.orientation == .landscape {
                ManageAccountView(viewModel: viewModel, authViewModel: authViewModel)
                    .presentationCompactAdaptation(.fullScreenCover)
                    .clipShape(RoundedCorner(radius: 13, corners: [.topLeft, .topRight]))
                    .presentationBackground {
                        Color.black.opacity(0.001)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .onTapGesture {
                                viewModel.dismissManageAccountSheet()
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(.all)
                    .alert(
                        Constants.logOut,
                        isPresented: $authViewModel.isLogoutAlertPresented,
                        actions: {
                            Button(Constants.cancelText, role: .cancel) { }
                            Button(Constants.logOut, role: .destructive) { AuthViewModel.shared.logout() }
                        },
                        message: {
                            Text(Constants.confirmLogOutText)
                        }
                    )
                    .alert(
                        Constants.deleteAccountText,
                        isPresented: $authViewModel.isDeleteAccountAlertPresented,
                        actions: {
                            Button(Constants.cancelText, role: .cancel) { }
                            Button(Constants.deleteButton, role: .destructive) { AuthViewModel.shared.deleteAccount() }
                        },
                        message: {
                            Text(Constants.confirmDeleteAccountText)
                        }
                    )
                
            } else {
                ManageAccountView(viewModel: viewModel, authViewModel: authViewModel)
                    .alert(
                        Constants.logOut,
                        isPresented: $authViewModel.isLogoutAlertPresented,
                        actions: {
                            Button(Constants.cancelText, role: .cancel) { }
                            Button(Constants.logOut, role: .destructive) { AuthViewModel.shared.logout() }
                        },
                        message: {
                            Text(Constants.confirmLogOutText)
                        }
                    )
                    .alert(
                        Constants.deleteAccountText,
                        isPresented: $authViewModel.isDeleteAccountAlertPresented,
                        actions: {
                            Button(Constants.cancelText, role: .cancel) { }
                            Button(Constants.deleteButton, role: .destructive) { AuthViewModel.shared.deleteAccount() }
                        },
                        message: {
                            Text(Constants.confirmDeleteAccountText)
                        }
                    )
                    .presentationDetents([.height(420)])
            }
        }
    }
}
