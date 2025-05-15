//
//  OverflowAnimationWrapper.swift
//
//
//  Created by Graciano Caldeira on 12/12/2024.
//

import SwiftUI

internal struct OverflowAnimationWrapper<Content: View>: View {
    
    @State private var contentFits: Bool = false
    internal var height: CGFloat
    internal var offset: CGFloat?
    internal let content: () -> Content
    
    @State private var scrollID: String? = "bottom"
    
    internal init(height: CGFloat, offset: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.height = height
        self.offset = offset
        self.content = content
    }
    
    internal var body: some View {
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
                    VStack{}.frame(height: offset)
                    
                    content().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            } else {
                if #available(iOS 17, *) {
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack {
                                VStack{}.frame(height: 0.001)
                                    .id("top")
                                
                                VStack{}.frame(height: offset)
                                
                                content().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                                VStack{}.frame(height: 0.001)
                                    .id("bottom")
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                            withAnimation(.easeInOut(duration: 0.5)) {
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
