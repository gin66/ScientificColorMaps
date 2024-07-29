// Copyright (c) 2024, Jochen Kiemes
// see LICENSE
final class ScientificColorMaps: Sendable {
    let name: String

    // This is an array of 256 triples in range 0 to 1
    let rgb_data: [(Float, Float, Float)]

    // If defined, then this is an array of 100 triples in range 0 to 1
    let categorical: [(Float, Float, Float)]?

    init(_ name: String, raw data: [(Float, Float, Float)], categories: [(Float, Float, Float)]? = nil) {
        self.name = name
        rgb_data = data
        categorical = categories
    }
    func discrete10() -> [(Float, Float, Float)] {
        [1, 29, 58, 86, 114, 143, 171, 199, 228, 256].map {
            rgb_data[$0-1]
        }
    }
    func discrete25() -> [(Float, Float, Float)] {
        [1, 12, 22, 33, 44, 54, 65, 75, 86, 97, 107,
         118, 129, 139, 150, 160, 171, 182, 192, 203,
         214, 224, 235, 245, 256].map {
            rgb_data[$0-1]
        }
    }
    func discrete50() -> [(Float, Float, Float)] {
        [1, 6, 11, 17, 22, 27, 32, 37, 43, 48, 53, 58,
         63, 69, 74, 79, 84, 89, 95, 100, 105, 110, 115,
         121, 126, 131, 136, 142, 147, 152, 157, 162,
         168, 173, 178, 183, 194, 199, 204, 209, 214,
         220, 225, 230, 235, 240, 246, 251, 256].map {
            rgb_data[$0-1]
        }
    }
    func discrete100() -> [(Float, Float, Float)] {
        [1, 4, 6, 9, 11, 14, 16, 19, 22, 24, 27, 29,
         32, 34, 37, 40, 42, 45, 47, 50, 53, 55, 58,
         60, 63, 65, 68, 71, 73, 76, 78, 81, 83, 86,
         89, 91, 94, 96, 99, 101, 104, 107, 109, 112,
         114, 117, 119, 122, 125, 127, 130, 132, 135,
         138, 140, 143, 145, 148, 150, 153, 156, 158,
         161, 163, 166, 168, 171, 174, 176, 179, 181,
         184, 186, 189, 192, 194, 197, 199, 202, 204,
         207, 210, 212, 215, 217, 220, 223, 225, 228,
         230, 233, 235, 238, 241, 243, 246, 248, 251, 
         253, 256].map {
            rgb_data[$0-1]
        }
    }
}