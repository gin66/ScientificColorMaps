//
//  ScientificColor+simd.swift
//
//
//  Created by Jochen Kiemes on 31.07.24.
//

import Foundation

#if canImport(simd)
  import simd

  extension ScientificColor {
    public func asSimd() -> simd_float3 {
      simd_float3(x: red, y: green, z: blue)
    }
    public func into() -> simd_float3 {
      asSimd()
    }
  }

#endif
