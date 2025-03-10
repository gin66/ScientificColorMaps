//
//  ScientificColorMap+CDS.swift
//
//
//  Created by Jochen Kiemes on 04.08.24.
//

import Foundation

#if canImport(simd)

  import simd

  public enum ColorDeficiency {
    case protanomaly(severity: Float)
    case deuteranomaly(severity: Float)
    case tritanomaly(severity: Float)

    public func getMatrix() -> simd_float3x3 {
      let index: Int
      let severity: Float
      switch self {
      case .protanomaly(let v):
        index = 0
        severity = v
      case .deuteranomaly(let v):
        index = 1
        severity = v
      case .tritanomaly(let v):
        index = 2
        severity = v
      }
      let clamped = max(min(severity * 10, 10.0), 0.0)
      let matrixIndex = Int(clamped)
      let decimal = clamped - Float(matrixIndex)

      if matrixIndex < 10 {
        let m_low = ColorDeficiency.simulationMatrices[matrixIndex][index]
        let m_high = ColorDeficiency.simulationMatrices[matrixIndex + 1][index]
        return m_low * (1.0 - decimal) + m_high * decimal
      } else {
        return ColorDeficiency.simulationMatrices[10][index]
      }
    }

    public func mapRGB(rgb: simd_float3) -> simd_float3 {
      let matrix = getMatrix()
      let result = matrix * rgb
      let clamped: simd_float3 = min(max(result, 0), 1.0)
      return clamped
    }

    static let simulationMatrices: [[simd_float3x3]] = [
      //        0.0
      [
        simd_float3x3(rows: [
          simd_float3(x: 1.000000, y: 0.000000, z: -0.000000),
          simd_float3(x: 0.000000, y: 1.000000, z: 0.000000),
          simd_float3(x: -0.000000, y: -0.000000, z: 1.000000),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 1.000000, y: 0.000000, z: -0.000000),
          simd_float3(x: 0.000000, y: 1.000000, z: 0.000000),
          simd_float3(x: -0.000000, y: -0.000000, z: 1.000000),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 1.000000, y: 0.000000, z: -0.000000),
          simd_float3(x: 0.000000, y: 1.000000, z: 0.000000),
          simd_float3(x: -0.000000, y: -0.000000, z: 1.000000),
        ]),
      ],
      //        0.1
      [
        simd_float3x3(rows: [
          simd_float3(x: 0.856167, y: 0.182038, z: -0.038205),
          simd_float3(x: 0.029342, y: 0.955115, z: 0.015544),
          simd_float3(x: -0.002880, y: -0.001563, z: 1.004443),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.866435, y: 0.177704, z: -0.044139),
          simd_float3(x: 0.049567, y: 0.939063, z: 0.011370),
          simd_float3(x: -0.003453, y: 0.007233, z: 0.996220),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.926670, y: 0.092514, z: -0.019184),
          simd_float3(x: 0.021191, y: 0.964503, z: 0.014306),
          simd_float3(x: 0.008437, y: 0.054813, z: 0.936750),
        ]),
      ],
      //        0.2
      [
        simd_float3x3(rows: [
          simd_float3(x: 0.734766, y: 0.334872, z: -0.069637),
          simd_float3(x: 0.051840, y: 0.919198, z: 0.028963),
          simd_float3(x: -0.004928, y: -0.004209, z: 1.009137),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.760729, y: 0.319078, z: -0.079807),
          simd_float3(x: 0.090568, y: 0.889315, z: 0.020117),
          simd_float3(x: -0.006027, y: 0.013325, z: 0.992702),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.895720, y: 0.133330, z: -0.029050),
          simd_float3(x: 0.029997, y: 0.945400, z: 0.024603),
          simd_float3(x: 0.013027, y: 0.104707, z: 0.882266),
        ]),
      ],
      //        0.3
      [
        simd_float3x3(rows: [
          simd_float3(x: 0.630323, y: 0.465641, z: -0.095964),
          simd_float3(x: 0.069181, y: 0.890046, z: 0.040773),
          simd_float3(x: -0.006308, y: -0.007724, z: 1.014032),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.675425, y: 0.433850, z: -0.109275),
          simd_float3(x: 0.125303, y: 0.847755, z: 0.026942),
          simd_float3(x: -0.007950, y: 0.018572, z: 0.989378),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.905871, y: 0.127791, z: -0.033662),
          simd_float3(x: 0.026856, y: 0.941251, z: 0.031893),
          simd_float3(x: 0.013410, y: 0.148296, z: 0.838294),
        ]),
      ],
      //        0.4
      [
        simd_float3x3(rows: [
          simd_float3(x: 0.539009, y: 0.579343, z: -0.118352),
          simd_float3(x: 0.082546, y: 0.866121, z: 0.051332),
          simd_float3(x: -0.007136, y: -0.011959, z: 1.019095),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.605511, y: 0.528560, z: -0.134071),
          simd_float3(x: 0.155318, y: 0.812366, z: 0.032316),
          simd_float3(x: -0.009376, y: 0.023176, z: 0.986200),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.948035, y: 0.089490, z: -0.037526),
          simd_float3(x: 0.014364, y: 0.946792, z: 0.038844),
          simd_float3(x: 0.010853, y: 0.193991, z: 0.795156),
        ]),
      ],
      //        0.5
      [
        simd_float3x3(rows: [
          simd_float3(x: 0.458064, y: 0.679578, z: -0.137642),
          simd_float3(x: 0.092785, y: 0.846313, z: 0.060902),
          simd_float3(x: -0.007494, y: -0.016807, z: 1.024301),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.547494, y: 0.607765, z: -0.155259),
          simd_float3(x: 0.181692, y: 0.781742, z: 0.036566),
          simd_float3(x: -0.010410, y: 0.027275, z: 0.983136),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 1.017277, y: 0.027029, z: -0.044306),
          simd_float3(x: -0.006113, y: 0.958479, z: 0.047634),
          simd_float3(x: 0.006379, y: 0.248708, z: 0.744913),
        ]),
      ],
      //        0.6
      [
        simd_float3x3(rows: [
          simd_float3(x: 0.385450, y: 0.769005, z: -0.154455),
          simd_float3(x: 0.100526, y: 0.829802, z: 0.069673),
          simd_float3(x: -0.007442, y: -0.022190, z: 1.029632),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.498864, y: 0.674741, z: -0.173604),
          simd_float3(x: 0.205199, y: 0.754872, z: 0.039929),
          simd_float3(x: -0.011131, y: 0.030969, z: 0.980162),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 1.104996, y: -0.046633, z: -0.058363),
          simd_float3(x: -0.032137, y: 0.971635, z: 0.060503),
          simd_float3(x: 0.001336, y: 0.317922, z: 0.680742),
        ]),
      ],
      //        0.7
      [
        simd_float3x3(rows: [
          simd_float3(x: 0.319627, y: 0.849633, z: -0.169261),
          simd_float3(x: 0.106241, y: 0.815969, z: 0.077790),
          simd_float3(x: -0.007025, y: -0.028051, z: 1.035076),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.457771, y: 0.731899, z: -0.189670),
          simd_float3(x: 0.226409, y: 0.731012, z: 0.042579),
          simd_float3(x: -0.011595, y: 0.034333, z: 0.977261),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 1.193214, y: -0.109812, z: -0.083402),
          simd_float3(x: -0.058496, y: 0.979410, z: 0.079086),
          simd_float3(x: -0.002346, y: 0.403492, z: 0.598854),
        ]),
      ],
      //        0.8
      [
        simd_float3x3(rows: [
          simd_float3(x: 0.259411, y: 0.923008, z: -0.182420),
          simd_float3(x: 0.110296, y: 0.804340, z: 0.085364),
          simd_float3(x: -0.006276, y: -0.034346, z: 1.040622),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.422823, y: 0.781057, z: -0.203881),
          simd_float3(x: 0.245752, y: 0.709602, z: 0.044646),
          simd_float3(x: -0.011843, y: 0.037423, z: 0.974421),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 1.257728, y: -0.139648, z: -0.118081),
          simd_float3(x: -0.078003, y: 0.975409, z: 0.102594),
          simd_float3(x: -0.003316, y: 0.501214, z: 0.502102),
        ]),
      ],
      //        0.9
      [
        simd_float3x3(rows: [
          simd_float3(x: 0.203876, y: 0.990338, z: -0.194214),
          simd_float3(x: 0.112975, y: 0.794542, z: 0.092483),
          simd_float3(x: -0.005222, y: -0.041043, z: 1.046265),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.392952, y: 0.823610, z: -0.216562),
          simd_float3(x: 0.263559, y: 0.690210, z: 0.046232),
          simd_float3(x: -0.011910, y: 0.040281, z: 0.971630),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 1.278864, y: -0.125333, z: -0.153531),
          simd_float3(x: -0.084748, y: 0.957674, z: 0.127074),
          simd_float3(x: -0.000989, y: 0.601151, z: 0.399838),
        ]),
      ],
      //         1.0
      [
        simd_float3x3(rows: [
          simd_float3(x: 0.152286, y: 1.052583, z: -0.204868),
          simd_float3(x: 0.114503, y: 0.786281, z: 0.099216),
          simd_float3(x: -0.003882, y: -0.048116, z: 1.051998),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 0.367322, y: 0.860646, z: -0.227968),
          simd_float3(x: 0.280085, y: 0.672501, z: 0.047413),
          simd_float3(x: -0.011820, y: 0.042940, z: 0.968881),
        ]),
        simd_float3x3(rows: [
          simd_float3(x: 1.255528, y: -0.076749, z: -0.178779),
          simd_float3(x: -0.078411, y: 0.930809, z: 0.147602),
          simd_float3(x: 0.004733, y: 0.691367, z: 0.303900),
        ]),
      ],
    ]
  }

#endif
