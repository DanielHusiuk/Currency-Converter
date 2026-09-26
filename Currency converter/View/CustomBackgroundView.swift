//
//  CustomBackgroundView.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 21.09.2026.
//

import UIKit

final class CustomBackgroundView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }
    
    private func setupUI() {
        layer.cornerRadius = 22
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
    }
    
}
