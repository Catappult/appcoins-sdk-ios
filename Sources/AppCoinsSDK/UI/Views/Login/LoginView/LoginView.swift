//
//  LoginView.swift
//
//
//  Created by Graciano Caldeira on 28/11/2024.
//

import SwiftUI

internal struct LoginView: View {
    
    @ObservedObject internal var authViewModel: AuthViewModel = AuthViewModel.shared
    @State private var toast: FancyToast? = nil
    
    internal var body: some View {
        ZStack {
            LoginViewFormLayer()
            LoginViewButtonLayer()
        }.frame(maxHeight: .infinity, alignment: .bottom)
        .toastView(toast: $toast)
        .onChange(of: authViewModel.presentTCError) { isPresented in
            if isPresented { self.toast = FancyToast(type: .error, title: "Missing fields", message: "Please read and accept Aptoide's Terms and Conditions and Privacy Policy") }
            else { self.toast = nil }
        }
    }
}
