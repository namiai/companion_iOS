// Copyright (c) nami.ai

import SwiftUI

extension TextFieldView {
    func tintColor(_ color: Color) -> TextFieldView {
        var view = self
        view.tintColor = UIColor(color)
        return view
    }

    func textColor(_ color: Color) -> TextFieldView {
        var view = self
        view.textColor = UIColor(color)
        return view
    }

    func font(_ font: UIFont) -> TextFieldView {
        var view = self
        view.font = font
        return view
    }

    func secureTextEntry(_ secure: Bool) -> TextFieldView {
        var view = self
        view.secureTextEntry = secure
        return view
    }
}
