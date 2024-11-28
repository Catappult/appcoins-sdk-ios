//
//  UserLoginView.swift
//
//
//  Created by Graciano Caldeira on 28/11/2024.
//

import SwiftUI

struct UserLoginView: View {
    
    @ObservedObject var viewModel: BottomSheetViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("")
        }.onDisappear(perform: {
            viewModel.setCanLogin(canLogin: false)
        })
    }
}
