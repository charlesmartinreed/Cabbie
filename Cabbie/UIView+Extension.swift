//
//  UIView+Extension.swift
//  Cabbie
//
//  Created by Charles Martin Reed on 1/10/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import UIKit

extension UIView {
    func createSimpleGradient(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func createComplexGradient(colors: UIColor...) {
        let colors = colors.map() { $0.cgColor }
        //let numberOfColors = colors.count
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        
        //without specifying locations, each color takes up an equal amount of space
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
        
    }
}
