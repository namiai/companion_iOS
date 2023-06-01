//
//  File.swift
//  
//
//  Created by Yachin Ilya on 14.02.2023.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 08) & 0xFF) / 255.0,
            blue: Double((hex >> 00) & 0xFF) / 255.0,
            opacity: alpha
        )
    }
    
    static var accent: Color { Color("AccentColor", bundle: nil) }
    static var headline: Color { Color("Headline", bundle: nil) }
    static var bodyText: Color { Color("BodyText", bundle: nil) }
    static var darkText: Color { Color("DarkText", bundle: nil) }
    static var primary: Color { Color("Primary", bundle: nil) }
    static var onPrimary: Color { Color("OnPrimary", bundle: nil) }
    static var linkText: Color { Color("LinkText", bundle: nil) }
    static var lowerBackground: Color { Color("LowerBackground", bundle: nil) }
    static var negative: Color { Color("Negative", bundle: nil) }
    static var warning: Color { Color("Warning", bundle: nil) }
    static var positive: Color { Color("Positive", bundle: nil) }
    static var allGood: Color { Color("AllGood", bundle: nil) }
    static var borderStroke: Color { Color("BorderStroke", bundle: nil) }
    static var graphLines: Color { Color("GraphLines", bundle: nil) }
    static var placeholder: Color { Color("Placeholder", bundle: nil) }
    static var authButtonStroke: Color { Color("AuthButtonStroke", bundle: nil) }
    static var profileTileBackground: Color { Color("ProfileTileBackground", bundle: nil) }
    static var buttonedFieldBackground: Color { Color("ButtonedFieldBackground", bundle: nil) }
    static var buttonedFieldStroke: Color { Color("ButtonedFieldStroke", bundle: nil) }
    
    static var systemBackground: Self {
        Color(UIColor.systemBackground)
    }

    static var textLabel: Self {
        Color(UIColor.label)
    }

    static var invertedTextLabel: Self {
        UITraitCollection.current.userInterfaceStyle == .dark ? Color(UIColor.darkText) : Color(UIColor.lightText)
    }

    static var tint: Self {
        Color(UIView().tintColor)
    }
}
