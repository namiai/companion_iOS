// Copyright (c) nami.ai

import SwiftUI

// MARK: - TextFieldView

struct TextFieldView: UIViewRepresentable {
    // MARK: Lifecycle

    init(placeholder: String, text: Binding<String>, isEditing: Binding<Bool>, returnKeyType: UIReturnKeyType = .default) {
        self.placeholder = placeholder
        self.returnKeyType = returnKeyType
        _text = text
        _isEditing = isEditing
    }

    // MARK: Internal

    final class Coordinator: NSObject {
        // MARK: Lifecycle

        init(text: Binding<String>, isEditing: Binding<Bool>, showsPassword: Binding<Bool>, showImageName: String, hideImageName: String) {
            _text = text
            _isEditing = isEditing
            _showsPassword = showsPassword
            self.showImageName = showImageName
            self.hideImageName = hideImageName
        }

        // MARK: Internal

        @Binding var text: String
        @Binding var isEditing: Bool
        @Binding var showsPassword: Bool
        lazy var showButton = Self.button(imageName: showImageName, target: self, action: #selector(Coordinator.showButtonTapped))
        lazy var hideButton = Self.button(imageName: hideImageName, target: self, action: #selector(Coordinator.hideButtonTapped))

        @objc
        func showButtonTapped() {
            showsPassword = true
        }

        @objc
        func hideButtonTapped() {
            showsPassword = false
        }

        // MARK: Private

        private let showImageName: String
        private let hideImageName: String

        private static func button(imageName: String, target: Coordinator, action: Selector) -> UIButton {
            let button = UIButton(type: .custom)
            let image = UIImage(systemName: imageName)
            button.setImage(image, for: .normal)
            button.addTarget(target, action: action, for: .touchUpInside)
            button.sizeToFit()
            return button
        }
    }

    var font: UIFont?
    var textColor: UIColor?
    var tintColor: UIColor?
    var secureTextEntry = false

    static func dismantleUIView(_ uiView: UITextField, coordinator: Coordinator) {
        uiView.removeTarget(coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isEditing: $isEditing, showsPassword: $showsPassword, showImageName: "eye", hideImageName: "eye.slash")
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator

        update(textField: textField, coordinator: context.coordinator)

        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)

        if isEditing {
            textField.becomeFirstResponder()
        }

        textField.returnKeyType = returnKeyType

        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        update(textField: textField, coordinator: context.coordinator)

        if textField.window != nil {
            // This triggers “AttributeGraph: cycle detected” error if not dispatched.
            DispatchQueue.main.async {
                if isEditing {
                    if textField.isFirstResponder == false {
                        textField.becomeFirstResponder()
                    }
                } else {
                    textField.resignFirstResponder()
                }
            }
        }
    }

    // MARK: Private

    @State private var showsPassword = false

    private var placeholder: String
    private var returnKeyType: UIReturnKeyType
    @Binding private var text: String
    @Binding private var isEditing: Bool

    private func update(textField: UITextField, coordinator: Coordinator) {
        textField.placeholder = placeholder
        textField.text = text
        textField.font = font
        textField.adjustsFontForContentSizeCategory = true
        textField.textColor = textColor
        if let tintColor = tintColor {
            textField.tintColor = tintColor
        }

        textField.clearsOnBeginEditing = false
        if secureTextEntry {
            textField.clearButtonMode = .never
            if showsPassword {
                textField.isSecureTextEntry = false
                textField.rightView = coordinator.hideButton
            } else {
                textField.isSecureTextEntry = true
                textField.rightView = coordinator.showButton
            }
            textField.rightViewMode = .always
        } else {
            textField.isSecureTextEntry = false
            textField.clearButtonMode = .always
            textField.rightView = nil
            textField.rightViewMode = .never
        }

        textField.returnKeyType = returnKeyType

        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}

// MARK: - TextFieldView.Coordinator + UITextFieldDelegate

extension TextFieldView.Coordinator: UITextFieldDelegate {
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        text = textField.text ?? ""
    }

    func textFieldDidBeginEditing(_: UITextField) {
        DispatchQueue.main.async { [weak self] in
            if self?.isEditing == false {
                self?.isEditing = true
            }
        }
    }

    func textFieldDidEndEditing(_: UITextField) {
        DispatchQueue.main.async { [weak self] in
            if self?.isEditing == true {
                self?.isEditing = false
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            return true
        }
        return false
    }
}

// MARK: - TextFieldView_Previews

struct TextFieldView_Previews: PreviewProvider {
    @State static var text = "Text"
    @State static var isEditing = false

    static var previews: some View {
        Group {
            TextFieldView(placeholder: "Hello", text: $text, isEditing: $isEditing)
                .padding()
        }
        .previewLayout(.fixed(width: 400, height: 700))
    }
}
