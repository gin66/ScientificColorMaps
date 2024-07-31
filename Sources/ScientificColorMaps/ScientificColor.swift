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
public final class ScientificColor: Sendable, Equatable, Hashable {
    let index: Int
    let red: Float
    let green: Float
    let blue: Float

    public static func == (lhs: ScientificColor, rhs: ScientificColor) -> Bool {
        lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
    }
    public func hash(into hasher: inout Hasher) {
        red.hash(into: &hasher)
        green.hash(into: &hasher)
        blue.hash(into: &hasher)
    }

    init(_ index: Int, _ red: Float, _ green: Float, _ blue: Float) {
        self.index = index
        self.red = red
        self.green = green
        self.blue = blue
    }
    public func asTuple() -> (red: Float, green: Float, blue: Float) {
        (red, green, blue)
    }
    public func asArray() -> [Float] {
        [red, green, blue]
    }
    public func into() ->  (red: Float, green: Float, blue: Float) {
        asTuple()
    }
    public func into() -> [Float] {
        asArray()
    }
}
