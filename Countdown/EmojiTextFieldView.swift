//
//  EmojiTextFieldView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI

struct EmojiTextField: UIViewRepresentable {
    @Binding var emoji: String
    
    func makeUIView(context: UIViewRepresentableContext<EmojiTextField>) -> EmojiUITextField {
        let textField = EmojiUITextField(frame: .zero)
        textField.text = emoji
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.textAlignment = .center
        return textField
    }
    
    func updateUIView(_ uiView: EmojiUITextField, context: Context) {
    }
    
    func makeCoordinator() -> EmojiTextFieldCoordinator {
        return EmojiTextFieldCoordinator(self)
    }
}

internal class EmojiTextFieldCoordinator: NSObject, UITextFieldDelegate {
    var emojiTextField: EmojiTextField
    
    init(_ textField: EmojiTextField) {
        self.emojiTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.emojiTextField.emoji = textField.text!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.count == 1 {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            return true
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.text = ""
        return true
    }
}

internal class EmojiUITextField: UITextField {
    override var textInputContextIdentifier: String? {
        return ""
    }

    override var textInputMode: UITextInputMode? {
        return UITextInputMode.activeInputModes.first {
            $0.primaryLanguage == "emoji"
        }
    }
}

struct EmojiTextFieldView_Previews: PreviewProvider {
    @State static var emoji: String = "🎉"
    
    static var previews: some View {
        EmojiTextField(emoji: $emoji)
    }
}
