//
//  ScientificColor+UIColor.swift
//
//
//  Created by Jochen Kiemes on 31.07.24.
//

import Foundation

#if canImport(CoreImage)
import CoreImage

public extension ScientificColor {
    func asCIColor()-> CIColor {
        CIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
    }
    func into() -> CIColor {
        asCIColor()
    }
}

#endif
