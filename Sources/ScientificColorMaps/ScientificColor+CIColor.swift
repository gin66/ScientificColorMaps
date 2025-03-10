//
//  ScientificColor+UIColor.swift
//
//
//  Created by Jochen Kiemes on 31.07.24.
//

import Foundation

#if canImport(CoreImage)
  import CoreImage

  extension ScientificColor {
    public func asCIColor() -> CIColor {
      CIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
    }
    public func into() -> CIColor {
      asCIColor()
    }
  }

#endif
