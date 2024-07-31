//
//  ScientificColor+UIColor.swift
//
//
//  Created by Jochen Kiemes on 31.07.24.
//

import Foundation

#if canImport(UIKit)
import UIKit

public extension ScientificColor {
    func asUIColor()-> UIColor {
        UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
    }
    func into() -> UIColor {
        asNSColor()
    }
}
#endif
