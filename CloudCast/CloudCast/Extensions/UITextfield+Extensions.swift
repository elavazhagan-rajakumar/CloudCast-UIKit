//
//  UITextfield+Extensions.swift
//  CloudCast
//
//  Created by Rajarathinam Ganasekarapandian on 30/03/26.
//

import UIKit

extension UITextField {
    // Adds left inner padding
    func leftPadding(_ amount: CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftViewMode = .always
    }
}

extension UILabel {
    // Letter spacing for subtitle text
    func letterSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        let attributed = NSAttributedString(
            string: text,
            attributes: [.kern: spacing]
        )
        attributedText = attributed
    }
}
