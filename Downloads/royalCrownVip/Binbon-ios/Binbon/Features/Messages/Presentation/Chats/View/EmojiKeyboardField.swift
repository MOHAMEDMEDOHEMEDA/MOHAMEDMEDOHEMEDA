//
//  EmojiKeyboardField.swift
//  Binbon
//
//  Created by Aya Mashaly on 24/06/2026.
//

import SwiftUI

struct EmojiKeyboardField: UIViewRepresentable {
    @Binding var isActive: Bool
    var onEmojiPicked: (String) -> Void

    func makeUIView(context: Context) -> EmojiTextField {
        let field = EmojiTextField()
        field.delegate = context.coordinator
        field.alpha = 0
        field.tintColor = .clear
        return field
    }

    func updateUIView(_ uiView: EmojiTextField, context: Context) {
        DispatchQueue.main.async {
            if isActive, !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else if !isActive, uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: EmojiKeyboardField

        init(parent: EmojiKeyboardField) { self.parent = parent }

        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
            if !string.isEmpty {
                parent.onEmojiPicked(string)
                textField.text = ""
            }
            return false
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isActive = false
        }
    }
}

class EmojiTextField: UITextField {
    override var textInputMode: UITextInputMode? {
        UITextInputMode.activeInputModes.first { $0.primaryLanguage == "emoji" }
    }
}
