// Copyright (c) nami.ai

import SwiftUI
import StandardPairingUI

struct CustomTheme: ThemeProtocol {
    var navigationTitleColor: Color?
    
    var navigationBarColor: Color?
    
    var headline1: Font = .custom("Montserrat-Bold", size: 34)
    
    var headline2: Font = .custom("Montserrat-Bold", size: 28)
    
    var headline3: Font = .custom("Montserrat-Bold", size: 24)
    
    var headline4: Font = .custom("Montserrat-Bold", size: 20)
    
    var headline5: Font = .custom("Montserrat-Bold", size: 17)
    
    var headline6: Font = .custom("Montserrat-Bold", size: 14)
    
    var paragraph1: Font = .custom("Montserrat-Regular", size: 17)
    
    var paragraph2: Font = .custom("Montserrat-Regular", size: 14)
    
    var small1: Font = .custom("Montserrat-Regular", size: 11)
    
    var small2: Font = .custom("Montserrat-Regular", size: 8)
    
    var primaryActionButtonStyle: any ButtonStyle = BlueButton()
    
    var secondaryActionButtonStyle: any ButtonStyle = BlueButton()
    
    var tertiaryActionButtonStyle: any ButtonStyle = BlueButton()
    
    var destructiveActionButtonStyle: any ButtonStyle = BlueButton()
}

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Montserrat-Regular", size: 17))
            .padding()
            .background(Color(red: 0, green: 0, blue: 0.5))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}
