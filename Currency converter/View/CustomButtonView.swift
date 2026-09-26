//
//  CustomButtonView.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 21.09.2026.
//

import UIKit

final class CustomButtonView: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }
    
    private func setupUI() {
        layer.cornerRadius = 10
    }
}
