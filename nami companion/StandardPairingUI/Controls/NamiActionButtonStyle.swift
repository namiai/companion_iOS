// Copyright (c) nami.ai

import SwiftUI

// MARK: - NamiActionButtonStyle

struct NamiActionButtonStyle: ButtonStyle {
    // MARK: Lifecycle

    init(
        rank: AppearanceHierarchyRank = .primary,
        sharpCorner: UIRectCorner = .topRight
    ) {
        self.rank = rank
        self.sharpCorner = sharpCorner
    }

    // MARK: Internal

    struct NamiActionButton: View {
        let configuration: ButtonStyle.Configuration
        let rank: AppearanceHierarchyRank
        let excCorner: UIRectCorner
        @Environment(\.isEnabled) var isEnabled: Bool

        var body: some View {
            RoundedRectContainerView(
                excludingCorners: excCorner,
                strokeWidth: rank.strokeWidth,
                strokeColor: rank.strokeColor,
                backgroundColor: isEnabled
                    ? rank.foregroundColor
                    : rank.disabledForegroundColor
            ) {
                configuration.label
                    .foregroundColor(isEnabled ? rank.textColor : rank.disabledTextColor)
//                    .font(NamiTextStyle.headline5.font)
                    .padding(18)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .frame(maxWidth: 300.0)
        }
    }

    enum AppearanceHierarchyRank {
        case primary
        case secondary
        case tertiary
        case destructive

        // MARK: Internal

        var foregroundColor: Color {
            switch self {
            case .primary:
                return .black
            case .secondary:
                return .systemBackground
            case .tertiary:
                return .clear
            case .destructive:
                return .white
            }
        }

        var textColor: Color {
            switch self {
            case .primary:
                return .white
            case .secondary:
                return .black
            case .tertiary:
                return .black
            case .destructive:
                return .red
            }
        }

        var strokeColor: Color {
            switch self {
            case .secondary:
                return .black
            default:
                return .clear
            }
        }

        var strokeWidth: CGFloat? {
            switch self {
            case .secondary:
                return 1
            default:
                return nil
            }
        }

        var disabledForegroundColor: Color {
            foregroundColor // .opacity(0.4)
        }

        var disabledTextColor: Color {
            textColor.opacity(0.4)
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        NamiActionButton(configuration: configuration, rank: rank, excCorner: sharpCorner)
    }

    // MARK: Private

    private var rank: AppearanceHierarchyRank
    private var sharpCorner: UIRectCorner
}

// MARK: - NamiActionButtonStyle_Previews

struct NamiActionButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()

            VStack {
                Button("Example button", action: { print("Click-Clack") })
                    .buttonStyle(NamiActionButtonStyle())
                Button("Disabled primary", action: { print("Click-Clack") })
                    .buttonStyle(NamiActionButtonStyle())
                    .disabled(true)
                Button("Example secondary button", action: { print("Click-Clack") })
                    .buttonStyle(NamiActionButtonStyle(rank: .secondary))
                Button("Disabled secondary", action: { print("Click-Clack") })
                    .buttonStyle(NamiActionButtonStyle(rank: .secondary))
                    .disabled(true)
                Button("Example tertiary button", action: { print("Click-Clack") })
                    .buttonStyle(NamiActionButtonStyle(rank: .tertiary))
                Button("Disabled tertiary", action: { print("Click-Clack") })
                    .buttonStyle(NamiActionButtonStyle(rank: .tertiary))
                    .disabled(true)
                Button("Example destructive button", action: { print("Click-Clack") })
                    .buttonStyle(NamiActionButtonStyle(rank: .destructive))
                Button("Disabled destructive", action: { print("Click-Clack") })
                    .buttonStyle(NamiActionButtonStyle(rank: .destructive))
                    .disabled(true)
            }
            .padding()
        }
    }
}
