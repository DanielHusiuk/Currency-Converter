//
//  CustomTextField.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 21.09.2026.
//

import UIKit

final class CustomTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupFieldStyle()
    }
    
    private func setupFieldStyle() {
        let leadingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.bounds.height))
        leadingView.backgroundColor = .clear
        
        self.leftView = leadingView
        self.leftViewMode = .always
        self.backgroundColor = .secondarySystemBackground
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
    }
    
    func updateBorderColor(isEditing: Bool) {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: { [self] in
                self.layer.borderColor = isEditing ? UIColor.tintColor.cgColor : UIColor.clear.cgColor
        })
    }
}
