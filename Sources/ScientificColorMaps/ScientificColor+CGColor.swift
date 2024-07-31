//
//  ScientificColor+UIColor.swift
//
//
//  Created by Jochen Kiemes on 31.07.24.
//

import Foundation

#if canImport(CoreGraphics)
import CoreGraphics

public extension ScientificColor {
    func asCGColor()-> CGColor {
        CGColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
    }
    func into() -> CGColor {
        asCGColor()
    }
}

#endif
