// Copyright (c) nami.ai

import SwiftUI

extension NamiTextField {
    func style(_ style: NamiTextFieldStyle) -> NamiTextField {
        var view = self
        view.fieldStyle = style
        return view
    }

    func subText(_ subText: String?) -> NamiTextField {
        var view = self
        view.fieldSubText = subText
        return view
    }

    func secureTextEntry(_ secure: Bool) -> NamiTextField {
        var view = self
        view.secureTextEntry = secure
        return view
    }
}
