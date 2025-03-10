//
//  ColorDeficiencyTests.swift
//
//
//  Created by Jochen Kiemes on 05.08.24.
//

import XCTest

@testable import ScientificColorMaps

#if canImport(simd)
  import simd

  final class ColorDeficiencyTests: XCTestCase {
    func testMappingIdentity() throws {
      let cds = ColorDeficiency.protanomaly(severity: 0)
      let rgb = simd_float3(1, 1, 1)
      let mapped_rgb = cds.mapRGB(rgb: rgb)

      XCTAssertEqual(mapped_rgb, simd_float3(1, 1, 1))
    }
    func testMappingProtanomaly() throws {
      let cds = ColorDeficiency.protanomaly(severity: 1)
      let rgb = simd_float3(1, 0, 0)
      let mapped_rgb = cds.mapRGB(rgb: rgb)

      XCTAssertEqual(mapped_rgb.x, 0.152286, accuracy: 1e-6)
    }
    func testMappingDeuteranomaly() throws {
      let cds = ColorDeficiency.deuteranomaly(severity: 1)
      let rgb = simd_float3(0, 1, 0)
      let mapped_rgb = cds.mapRGB(rgb: rgb)

      XCTAssertEqual(mapped_rgb.y, 0.672501, accuracy: 1e-6)
    }
    func testMappingTritoanomaly() throws {
      let cds = ColorDeficiency.tritanomaly(severity: 1)
      let rgb = simd_float3(0, 0, 1)
      let mapped_rgb = cds.mapRGB(rgb: rgb)

      XCTAssertEqual(mapped_rgb.z, 0.303900, accuracy: 1e-6)
    }
  }
#endif
