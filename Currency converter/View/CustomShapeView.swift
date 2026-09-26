//
//  CustomShapeView.swift
//  Currency converter
//
//  Created by Daniel Husiuk on 22.09.2026.
//

import UIKit

final class CustomShapeView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        layer.mask = maskLayer
    }
    
}
