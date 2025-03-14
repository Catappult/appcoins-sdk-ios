//
//  PayingHeader.swift
//
//
//  Created by Graciano Caldeira on 07/10/2024.
//

import SwiftUI

internal struct PayingHeader: View {
    
    @ObservedObject internal var viewModel: BottomSheetViewModel = BottomSheetViewModel.shared
    @ObservedObject internal var transactionViewModel: TransactionViewModel = TransactionViewModel.shared
    
    internal var icon: some View {
        Image(uiImage: Utils.getAppIcon())
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .frame(maxWidth: 40, alignment: .leading)
    }
    
    internal var title: some View {
        HStack(spacing: 0) {
            if let title = transactionViewModel.transaction?.getTitle() {
                Text(title)
                    .foregroundColor(ColorsUi.APC_Black)
                    .font(FontsUi.APC_Body_Bold)
                    .lineLimit(1)
            } else {
                Text("")
                    .skeleton(with: true)
                    .frame(width: 125, height: 22, alignment: .leading)
                VStack{}.frame(maxWidth: .infinity)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    internal var price: some View {
        HStack(spacing: 0) {
            if let amount = transactionViewModel.transaction?.moneyAmount {
                Text((transactionViewModel.transaction?.moneyCurrency.sign ?? "") + String(amount))
                    .foregroundColor(ColorsUi.APC_Black)
                    .font(FontsUi.APC_Subheadline_Bold)
                    .lineLimit(1)
                
                VStack{}.frame(width: 4)
                
                Text(transactionViewModel.transaction?.moneyCurrency.currency ?? "-")
                    .foregroundColor(ColorsUi.APC_Black)
                    .font(FontsUi.APC_Caption1_Bold)
                    .lineLimit(1)
            } else {
                HStack(spacing: 0) {
                    Text("")
                        .skeleton(with: true)
                        .frame(width: 60, height: 14, alignment: .leading)
                    VStack{}.frame(maxWidth: .infinity)
                }.frame(maxWidth: .infinity)
            }
            
            VStack{}.frame(width: 16)
            
            if let appcAmount = transactionViewModel.transaction?.appcAmount {
                Text(verbatim: String(format: "%.2f", appcAmount) + " APPC")
                    .foregroundColor(ColorsUi.APC_BottomSheet_APPC)
                    .font(FontsUi.APC_Caption2)
            } else {
                HStack(spacing: 0) {
                    Text("")
                        .skeleton(with: true)
                        .frame(width: 55, height: 10, alignment: .leading)
                        .padding(.top, 2)
                    VStack{}.frame(maxWidth: .infinity)
                }.frame(maxWidth: .infinity)
            }
        }
        .frame(width: viewModel.orientation == .landscape ? 256 : UIScreen.main.bounds.width - 154, alignment: .bottomLeading)
    }
    
    internal var body: some View {
        PurchaseHeader {
            HStack(spacing: 0) {
                icon
                
                VStack{}.frame(width: 15)
                
                VStack(alignment: .leading, spacing: 0) {
                    title
                    
                    price
                    
                    VStack{}.frame(height: 4)
                }
            }
        }
    }
}
