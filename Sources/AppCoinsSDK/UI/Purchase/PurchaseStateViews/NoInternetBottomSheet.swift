//
//  NoInternetBottomSheet.swift
//  
//
//  Created by aptoide on 25/05/2023.
//

import Foundation
import SwiftUI
import URLImage

internal struct NoInternetBottomSheet: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel
    
    internal var body: some View {

        ZStack {
            APPCColor.darkBlue
                
            VStack(spacing: 0) {
                ZStack {
                    VStack(spacing: 0) {
                        HStack {}.frame(maxHeight: .infinity)
                        
                        Image("no-internet-white", bundle: Bundle.module)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                        
                        Text(Constants.noInternetTitle)
                            .font(FontsUi.APC_Title3_Bold)
                            .foregroundColor(APPCColor.white)
                            .padding(.top, 16)
                        
                        Text(Constants.noInternetText)
                            .font(FontsUi.APC_Footnote)
                            .foregroundColor(APPCColor.white)
                            .padding(.top, 15)
                            .frame(width: UIScreen.main.bounds.width - 48)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {viewModel.reload()}) {
                            ZStack {
                                APPCColor.pink
                                
                                Text(Constants.retryConnection)
                                    .font(FontsUi.APC_Body_Bold)
                                    .foregroundColor(APPCColor.white)
                            }.frame(width: UIScreen.main.bounds.width - 48, height: 48)
                                .cornerRadius(10)
                                .padding(.top, 54)
                        }
                        
                        HStack {}.frame(maxHeight: .infinity)
                    }
                }
            }.frame(height: 396, alignment: .top)
            
        }.frame(width: UIScreen.main.bounds.size.width, height: 396)
            .cornerRadius(13, corners: [.topLeft, .topRight])
        
    }
}
