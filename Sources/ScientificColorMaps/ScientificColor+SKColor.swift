//
//  ScientificColor+UIColor.swift
//
//
//  Created by Jochen Kiemes on 31.07.24.
//

import Foundation

#if canImport(SpriteKit)
  import SpriteKit

  extension ScientificColor {
    public func asSKColor() -> SKColor {
      SKColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
    }
    #if !canImport(UIKit) && !canImport(AppKit)
      // SKColor is an alias for UI/NSColor with UI/AppKit
      public func into() -> SKColor {
        asSKColor()
      }
    #endif
  }
#endif
