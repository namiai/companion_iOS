// Copyright (c) nami.ai

import SwiftUI
import UIKit

// MARK: - NamiTextFieldStyle

enum NamiTextFieldStyle {
    case neutral
    case positive
    case negative
}

// MARK: - NamiTextField

struct NamiTextField: View {
    // MARK: Lifecycle

    init(placeholder: String, text: Binding<String>, isEditing: Binding<Bool>? = nil, returnKeyType: UIReturnKeyType = .default) {
        self.placeholder = placeholder
        self.returnKeyType = returnKeyType
        _text = text
        isEditingExternal = isEditing
    }

    // MARK: Internal

    var fieldStyle: NamiTextFieldStyle = .neutral
    /// The text under the textfield. If present, will be rendered
    /// in the given ``style``.
    var fieldSubText: String?
    var secureTextEntry = false

    var body: some View {
        VStack {
            RoundedRectContainerView(
                cornerRadius: cornerRadius,
                strokeWidth: 1.0,
                strokeColor: strokeColorWithStyle
            ) {
                TextFieldView(placeholder: placeholder, text: $text, isEditing: isEditing, returnKeyType: returnKeyType)
//                    .font(NamiTextStyle.paragraph1.uiFont)
                    .tintColor(Color.accent)
                    .secureTextEntry(secureTextEntry)
                    .padding()
            }
            if let subTextPresent = fieldSubText {
                HStack {
                    Text(subTextPresent)
//                        .font(NamiTextStyle.small.font)
                        .foregroundColor(subTextColorWithStyle)
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: cornerRadius * 0.5, bottom: 0, trailing: cornerRadius * 0.5))
            }
        }
    }

    var strokeColorWithStyle: Color {
        switch fieldStyle {
        case .neutral:
            if isEditing.wrappedValue {
                return Color.accent
            } else {
                return Color.borderStroke
            }
        case .positive:
            return Color.positive
        case .negative:
            return Color.negative
        }
    }

    var subTextColorWithStyle: Color {
        switch fieldStyle {
        case .neutral:
            return Color.bodyText
        case .positive:
            return Color.positive
        case .negative:
            return Color.negative
        }
    }

    // MARK: Private

    private let cornerRadius: CGFloat = 16.0
    private var placeholder: String
    private var returnKeyType: UIReturnKeyType
    @Binding private var text: String
    @State private var isEditingInternal = false
    private var isEditingExternal: Binding<Bool>?

    private var isEditing: Binding<Bool> {
        isEditingExternal ?? $isEditingInternal
    }
}
