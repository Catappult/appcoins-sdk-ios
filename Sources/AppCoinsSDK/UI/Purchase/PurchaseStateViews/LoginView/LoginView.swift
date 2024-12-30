//
//  LoginView.swift
//
//
//  Created by Graciano Caldeira on 28/11/2024.
//

import SwiftUI

struct LoginView: View {
    
    var body: some View {
        ZStack {
            LoginViewFormLayer()
            LoginViewButtonLayer()
        }.frame(maxHeight: .infinity, alignment: .bottom)
    }
}
