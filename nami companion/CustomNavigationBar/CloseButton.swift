// Copyright (c) nami.ai

import SwiftUI

public struct CloseButton: View {
    // MARK: Public
    public init() {
        
    }

    public var body: some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(foregroundColor)
                // Hack to maximize the similarity to chevron image asset.
                // SVG has preset 4 px paddings.
                .padding(9)
        }
    }

    // MARK: Private

    private let image = Image(systemName: "xmark")
    private let foregroundColor = Color.white
    private let backgroundColor = Color(UIColor.white)
}
