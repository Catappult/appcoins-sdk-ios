//
//  PurchaseViewWrapper.swift
//
//
//  Created by Graciano Caldeira on 12/12/2024.
//

import SwiftUI

struct PurchaseViewWrapper<Content: View>: View {
    
    @State private var contentFits: Bool = false
    internal var height: CGFloat
    let content: () -> Content
    
    init(height: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.height = height
        self.content = content
    }
    
    var body: some View {
        if #available(iOS 17, *) {
            GeometryReader { geometry in
                VStack {
                    content()
                        .background(
                            GeometryReader { innerGeometry in
                                Color.clear
                                    .onAppear {
                                        let contentHeight = innerGeometry.size.height
                                        contentFits = contentHeight <= height
                                    }
                            }
                        )
                }.hidden()
                
                if contentFits {
                    VStack {
                        content().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                } else {
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                VStack{}.frame(height: 0.001)
                                    .id("top")
                                
                                content().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                
                                VStack{}.frame(height: 0.001)
                                    .id("bottom")
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                            withAnimation(.easeInOut(duration: 30)) {
                                                scrollViewProxy.scrollTo("top", anchor: .top)
                                            }
                                        }
                                    }
                            }
                        }.defaultScrollAnchor(.bottom)
                    }
                }
            }
        }
    }
}
