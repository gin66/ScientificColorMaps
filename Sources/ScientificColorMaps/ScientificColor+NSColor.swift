//
//  ScientificColor+NSColor.swift
//
//
//  Created by Jochen Kiemes on 31.07.24.
//

import Foundation

#if canImport(AppKit)
  import AppKit

  extension ScientificColor {
    public func asNSColor() -> NSColor {
      NSColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
    }
    public func into() -> NSColor {
      asNSColor()
    }
  }

#endif
