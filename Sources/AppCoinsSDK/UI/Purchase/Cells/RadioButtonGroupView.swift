//
//  RadioButtonGroupView.swift
//  
//
//  Created by aptoide on 09/03/2023.
//

import Foundation
import SwiftUI

struct RadioButtonGroupView: View {
    
    @State var selected: Int?
    let setPaymentMethod: (Int) -> Void
    let options: [PaymentMethodView]
    
    var body: some View {
        
        VStack(spacing: 0) {
            ForEach(options) { option in
                HStack {
                    option
                        .onTapGesture {
                            if (!option.disabled) {
                                let index = options.firstIndex(of: option)!
                                if(selected != index) {
                                    // CHANGE IT LATER – right now only method available is AppCoins
                                    // setPaymentMethod(index)
                                    selected = index
                                }
                            }
                        }.frame(width: 272, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.vertical, 11)
                        
                    if (!isEnabled(option)) {
                        if (option.disabled) {
                            Circle()
                                .strokeBorder(ColorsUi.APC_LightGray, lineWidth: 2)
                                .frame(width: 22, height: 22, alignment: .trailing)
                                .padding(.trailing, 20)
                        } else {
                            Circle()
                                .fill(ColorsUi.APC_Pink.opacity(0.2))
                                .frame(width: 22, height: 22, alignment: .trailing)
                                .padding(.trailing, 20)
                        }
                    } else {
                        Circle()
                            .overlay(Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .edgesIgnoringSafeArea(.all)
                                .foregroundColor(ColorsUi.APC_Pink)
                            )
                            .frame(width: 22, height: 22, alignment: .trailing)
                            .padding(.trailing, 20)
                            .foregroundColor(ColorsUi.APC_White)
                    }
                    
                    
                }.frame(width: 328)
                
                if (option != options.last) {
                    Divider()
                        .background(ColorsUi.APC_LightGray)
                }
                    
            }
        }.background(ColorsUi.APC_White)
            .frame(width: 328)
            .cornerRadius(13)
        
    }
    
    private func isEnabled(_ option: PaymentMethodView) -> Bool {
        // For now, AppCoins Credits is always selected, change to option 0 later, when the others are no longer disabled
        if(selected == nil && self.options.firstIndex(of: option) == 0) { return true }
        else if(selected == options.firstIndex(of: option)) { return true }
        else { return false }
    }
    
}
