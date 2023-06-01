// Copyright (c) nami.ai

import SwiftUI

// MARK: - RoundedRectContainerView

struct RoundedRectContainerView<Subviews: View>: View {
    // MARK: Lifecycle

    init(
        cornerRadius: CGFloat = 16.0,
        excludingCorners: UIRectCorner = [],
        shadowRadius: CGFloat? = nil,
        strokeWidth: CGFloat? = nil,
        strokeColor: Color = Color.primary,
        backgroundColor: Color = Color(UIColor.systemBackground),
        @ViewBuilder subviews: () -> Subviews
    ) {
        cornersSettableRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        bgColor = backgroundColor
        self.subviews = subviews()
        roundedCorners = UIRectCorner(rawValue: UIRectCorner.allCorners.rawValue - excludingCorners.rawValue)
    }

    // MARK: Internal

    var subviews: Subviews
    var roundedCorners: UIRectCorner
    var cornersSettableRadius: CGFloat
    var shadowRadius: CGFloat?
    var strokeWidth: CGFloat?
    var strokeColor: Color
    var bgColor: Color

    var body: some View {
        VStack {
            subviews
        }
        .frame(maxWidth: .infinity, alignment: .center)
        // Setting corner radius to 0 is a hack
        // allowing to clip overflowing subviews,
        // Actual corners shape and radius is set through background.
        .cornerRadius(0)
        .background(SelectiveCornerRoundedShape(radius: Double(cornersSettableRadius), corners: roundedCorners)
            .fill(bgColor, strokeColor: strokeColor, lineWidth: strokeWidth ?? 0)
        )
        .shadow(radius: shadowRadius)
    }

    // MARK: Private

    private struct SelectiveCornerRoundedShape: Shape {
        var radius: Double
        var corners: UIRectCorner

        func path(in rect: CGRect) -> Path {
            Path(
                UIBezierPath(
                    roundedRect: rect,
                    byRoundingCorners: corners,
                    cornerRadii: CGSize(width: radius, height: radius)
                )
                .cgPath
            )
        }
    }
}

private extension View {
    @ViewBuilder
    func shadow(radius: CGFloat?) -> some View {
        if let r = radius, r.isZero == false { shadow(radius: r) }
        else { self }
    }
}

private extension Shape {
    func fill<Fill: ShapeStyle>(
        _ fillStyle: Fill,
        strokeColor: Color,
        lineWidth: CGFloat = 1
    ) -> some View {
        stroke(strokeColor, lineWidth: lineWidth)
            .background(fill(fillStyle))
    }
}
