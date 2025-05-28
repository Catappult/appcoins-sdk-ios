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
    
    @State private var alertPresenter = TextFieldAlert()
    
    internal var body: some View {
        if #available(iOS 16.4, *) {
            VStack(spacing: 0) {
                if viewModel.orientation == .landscape {
                    ZStack {
                        ColorsUi.APC_BottomSheet_LightGray_Background
                            .frame(maxHeight: .infinity, alignment: .top)
                            .frame(width: UIScreen.main.bounds.width - 176, height: UIScreen.main.bounds.height * 0.9)
                            .ignoresSafeArea(.all)
                        
                        switch authViewModel.manageAccountState {
                        case .manage:
                            ManageAccountView(viewModel: viewModel, authViewModel: authViewModel)
                        case .deleteSent:
                            DeleteAccountSentView(viewModel: viewModel, authViewModel: authViewModel)
                        case .deleteLoading:
                            APPCLoading()
                        case .deleteSuccess:
                            DeleteAccountSuccessView(viewModel: viewModel)
                        case .deleteFailed:
                            DeleteAccountFailedView(viewModel: viewModel)
                        }
                        
                    }
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
                    
                } else {
                    ZStack {
                        ColorsUi.APC_BottomSheet_LightGray_Background
                        
                        switch authViewModel.manageAccountState {
                        case .manage:
                            ManageAccountView(viewModel: viewModel, authViewModel: authViewModel)
                        case .deleteSent:
                            DeleteAccountSentView(viewModel: viewModel, authViewModel: authViewModel)
                        case .deleteLoading:
                            APPCLoading()
                        case .deleteSuccess:
                            DeleteAccountSuccessView(viewModel: viewModel)
                        case .deleteFailed:
                            DeleteAccountFailedView(viewModel: viewModel)
                        }
                        
                    }
                    .presentationDetents([.height(420)])
                    .background(ColorsUi.APC_BottomSheet_LightGray_Background)
                }
            }.alert(
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
            .onChange(of: authViewModel.isDeleteAccountAlertPresented) { isPresented in
                print("[AppCoinsSDK] Should be presenting: \(isPresented)")
                if isPresented {
                    print("[AppCoinsSDK] Should be presenting")
                    if authViewModel.deleteAccountEmail == "" {
                        self.alertPresenter.present(
                            title: Constants.deleteAccountText,
                            message: Constants.confirmDeleteAccountText,
                            placeholder: Constants.yourEmail,
                            confirmLabel: Constants.deleteButton,
                            cancelLabel: Constants.cancelText,
                            shouldBeEnabled: { text in
                                authViewModel.deleteAccountEmail = text
                                return authViewModel.validateEmail(email: text)
                            },
                            confirmAction: { text in authViewModel.deleteAccount() },
                            cancelAction: {
                                authViewModel.isSendingDelete = false
                                authViewModel.isDeleteAccountAlertPresented = false
                            }
                        )
                    } else {
                        self.alertPresenter.present(
                            title: Constants.deleteAccountText,
                            message: Constants.confirmDeleteAccountText,
                            placeholder: nil,
                            confirmLabel: Constants.deleteButton,
                            cancelLabel: Constants.cancelText,
                            shouldBeEnabled: { _ in return true },
                            confirmAction: { text in authViewModel.deleteAccount() },
                            cancelAction: {
                                authViewModel.isSendingDelete = false
                                authViewModel.isDeleteAccountAlertPresented = false
                            }
                        )
                    }
                }
            }
        }
    }
}
