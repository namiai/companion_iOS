// Copyright (c) nami.ai

import SwiftUI

// MARK: - NamiChatBubble

struct NamiChatBubble: View {
    // MARK: Lifecycle

    init(_ text: String) {
        self.text = text
    }

    // MARK: Internal

    var text: String

    var body: some View {
        RoundedRectContainerView(excludingCorners: .topLeft, backgroundColor: Color.white) {
            HStack {
                Text(text)
                    .multilineTextAlignment(.leading)
//                    .font(NamiTextStyle.headline4.font)
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - NamiChatBubble_Previews

struct NamiChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            VStack {
                VStack {
                    NamiChatBubble("The first thing to know is that there’s many things you can do with nami. So please take your time to check them all out.")
                    NamiChatBubble("Hello, World!")
                }
                VStack {
                    NamiChatBubble("The first thing to know is that there’s many things you can do with nami. So please take your time to check them all out.")
                    NamiChatBubble("Hello, World!")
                }
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
            }
        }
        .previewLayout(.fixed(width: 320, height: 740))
    }
}
