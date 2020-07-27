//
//  EmojiTextFieldView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI

/// Allows a user to pick an emoji character using the Emoji keyboard.
/// - Note: This does not prevent the user from manually switching to other keyboards and inputting a non-Emoji character
public struct EmojiPicker: View {
    @Binding var emoji: String
    
    public var body: some View {
        EmojiPickerImpl(emoji: $emoji)
    }
}

fileprivate struct EmojiPickerImpl: UIViewRepresentable {
    @Binding var emoji: String
    
    func makeUIView(context: UIViewRepresentableContext<EmojiPickerImpl>) -> EmojiUITextField {
        let textField = EmojiUITextField(frame: .zero)
        textField.text = emoji
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.textAlignment = .center
        textField.tintColor = .clear
        
        return textField
    }
    
    func updateUIView(_ uiView: EmojiUITextField, context: Context) {
    }
    
    func makeCoordinator() -> EmojiTextFieldCoordinator {
        return EmojiTextFieldCoordinator(self)
    }
}

fileprivate class EmojiTextFieldCoordinator: NSObject, UITextFieldDelegate {
    private var emojiTextField: EmojiPickerImpl
    
    init(_ textField: EmojiPickerImpl) {
        self.emojiTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.emojiTextField.emoji = textField.text!
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.text = string
        
        if let text = textField.text, text.count == 1 {
            self.emojiTextField.emoji = textField.text!
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
            )
        }
        
        return true
    }
}

fileprivate class EmojiUITextField: UITextField {
    override var textInputContextIdentifier: String? {
        return ""
    }

    override var textInputMode: UITextInputMode? {
        return UITextInputMode.activeInputModes.first {
            $0.primaryLanguage == "emoji"
        }
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
}

struct EmojiPickerViewTest: View {
    @State private var text = "<none>"
    var body: some View {
        VStack {
            Text("Get: \(text)")
            EmojiPicker(emoji: $text)
        }
    }
}

struct EmojiTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiPickerViewTest()
    }
}
