// Copyright (c) nami.ai

import SwiftUI

// MARK: - NamiErrorChatBubble

struct NamiErrorChatBubble: View {
    // MARK: Lifecycle

    init(_ text: String) {
        self.text = text
    }

    var text: String

    var body: some View {
        RoundedRectContainerView(excludingCorners: .topLeft, backgroundColor: Color.white) {
            HStack(alignment: .firstTextBaseline) {
                errorIndicator()
                Text(text)
                    .multilineTextAlignment(.leading)
//                    .font(NamiTextStyle.headline4.font)
                Spacer()
            }
            .padding()
        }
    }

    // MARK: Private

    private func errorIndicator() -> some View {
        VStack {
            Image(systemName: "exclamationmark.circle.fill")
                .offset(y: 6)
        }
    }
}
