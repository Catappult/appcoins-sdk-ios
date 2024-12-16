//
//  PurchaseViewWrapper.swift
//
//
//  Created by Graciano Caldeira on 12/12/2024.
//

import SwiftUI

struct PurchaseViewWrapper<Content: View>: View {
    
    @State private var contentFits: Bool = false
    var magicLinkCodeViewTopSpace: CGFloat?
    var isMagicLinkCodeView: Bool = false
    var bottomSheetHeaderHeight: CGFloat = 0
    var availableHeigh: CGFloat
    let content: Content
    
    
    init(height: CGFloat, buttonHeightPlusTopSpace: CGFloat? = nil, bottomSheetHeaderHeight: CGFloat? = nil, buttonBottomSafeArea: CGFloat, magicLinkCodeViewTopSpace: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        
        if let buttonHeightPlusTopSpace = buttonHeightPlusTopSpace, let bottomSheetHeaderHeight = bottomSheetHeaderHeight {
            self.bottomSheetHeaderHeight = bottomSheetHeaderHeight
            self.availableHeigh = height - (buttonHeightPlusTopSpace + buttonBottomSafeArea) - bottomSheetHeaderHeight
        } else if let bottomSheetHeaderHeight = bottomSheetHeaderHeight {
            self.bottomSheetHeaderHeight = bottomSheetHeaderHeight
            self.availableHeigh = height  - bottomSheetHeaderHeight
        } else if let buttonHeightPlusTopSpace = buttonHeightPlusTopSpace {
            self.availableHeigh = height - (buttonHeightPlusTopSpace + buttonBottomSafeArea)
        } else { self.availableHeigh = height }
        
        if let magicLinkCodeViewTopSpace = magicLinkCodeViewTopSpace {
            self.isMagicLinkCodeView = true
            self.magicLinkCodeViewTopSpace = magicLinkCodeViewTopSpace
        }
    }
    
    var body: some View {
        if #available(iOS 17, *) {
            GeometryReader { geometry in
                VStack {
                    content
                        .background(
                            GeometryReader { innerGeometry in
                                Color.clear
                                    .onAppear {
                                        let contentHeight = innerGeometry.size.height
                                        let availableHeight = self.availableHeigh
                                        contentFits = contentHeight <= availableHeight
                                    }
                            }
                        )
                }
                .hidden()
                
                if contentFits {
                    VStack {
                        VStack{}.frame(height: isMagicLinkCodeView ? magicLinkCodeViewTopSpace ?? 0 : self.bottomSheetHeaderHeight)
                        
                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                } else {
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                VStack{}.frame(height: 0.001)
                                    .id("top")
                                
                                VStack{}.frame(height: isMagicLinkCodeView ? magicLinkCodeViewTopSpace ?? 0 : self.bottomSheetHeaderHeight)
                                
                                content
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                
                                VStack{}.frame(height: 0.001)
                                    .id("bottom")
                                    .onAppear(perform: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                            withAnimation(.easeInOut(duration: 30)) {
                                                scrollViewProxy.scrollTo("top", anchor: .top)
                                            }
                                        }
                                    })
                            }
                        }.defaultScrollAnchor(.bottom)
                    }
                }
            }
        }
    }
}
