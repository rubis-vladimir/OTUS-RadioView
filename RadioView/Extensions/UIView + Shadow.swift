//
//  UIView + Shadow.swift
//  TestNew
//
//  Created by Владимир Рубис on 30.11.2022.
//

import UIKit

extension UIView {
    
    // Добавляет тень
    func addShadow(shadowColor: UIColor,
                   shadowOffset: CGSize,
                   shadowRadius: CGFloat,
                   shadowOpacity: Float) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
    }
}
