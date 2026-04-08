//
//  AuthUI.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 30/03/26.
//

import UIKit

// MARK: - Shared UI factory for Auth screens
// An enum with no cases is a pure namespace — cannot be instantiated
enum AuthUI {

    static func fieldLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    static func textField(
        placeholder: String,
        icon: String,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        autocapitalize: UITextAutocapitalizationType = .none
    ) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.keyboardType = keyboardType
        tf.isSecureTextEntry = isSecure
        tf.autocapitalizationType = autocapitalize
        tf.autocorrectionType = .no
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.returnKeyType = .next
        tf.translatesAutoresizingMaskIntoConstraints = false

        // Left icon
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 48))
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 10, y: 14, width: 18, height: 18)
        iconContainer.addSubview(iconView)
        tf.leftView = iconContainer
        tf.leftViewMode = .always

        return tf
    }

    static func eyeButton(targeting textField: UITextField) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "eye"),       for: .normal)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        btn.tintColor = .secondaryLabel
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 48)
        btn.addAction(UIAction { [weak textField, weak btn] _ in
            guard let btn, let textField else { return }
            btn.isSelected.toggle()
            textField.isSecureTextEntry = !btn.isSelected
        }, for: .touchUpInside)
        return btn
    }
}
