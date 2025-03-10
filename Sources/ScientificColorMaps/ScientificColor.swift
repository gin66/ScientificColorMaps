//
//  ScientificColor.swift
//
//
//  Created by Jochen Kiemes on 31.07.24.
//

import Foundation

// Define our own class in order to be independent
//     In Swift, there are many color types:
//          UIColor - iOS
//          NSColor - macOS
//          CGColor
//          simd_float3 - could be used, but not well supported under Linux
//
public final class ScientificColor: Sendable, Equatable, Hashable, Codable {
  public let index: Int
  public let categoryIndex: Int?
  public let red: Float
  public let green: Float
  public let blue: Float
  let maxValueOfMap: Float

  public static func == (lhs: ScientificColor, rhs: ScientificColor) -> Bool {
    lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
      && lhs.maxValueOfMap == rhs.maxValueOfMap
  }
  public func hash(into hasher: inout Hasher) {
    red.hash(into: &hasher)
    green.hash(into: &hasher)
    blue.hash(into: &hasher)
    maxValueOfMap.hash(into: &hasher)
  }

  init(
    _ index: Int, _ categoryIndex: Int? = nil, _ red: Float, _ green: Float, _ blue: Float,
    maxValueOfMap: Float
  ) {
    self.index = index
    self.categoryIndex = categoryIndex
    self.red = red
    self.green = green
    self.blue = blue
    self.maxValueOfMap = maxValueOfMap
  }
  public func maximized() -> ScientificColor {
    ScientificColor(
      index, categoryIndex, red / maxValueOfMap, green / maxValueOfMap, blue / maxValueOfMap,
      maxValueOfMap: 1)
  }
  public func asTuple() -> (red: Float, green: Float, blue: Float) {
    (red, green, blue)
  }
  public func asArray() -> [Float] {
    [red, green, blue]
  }
  public func into() -> (red: Float, green: Float, blue: Float) {
    asTuple()
  }
  public func into() -> [Float] {
    asArray()
  }
}
