// Copyright (c) 2024, Jochen Kiemes

import Foundation

let colormaps: [String] = [
    "acton",
    "bam",
    "bamO",
    "bamako",
    "batlow",
    "batlowK",
    "batlowW",
    "berlin",
    "bilbao",
    "broc",
    "brocO",
    "buda",
    "bukavu",
    "cork",
    "corkO",
    "davos",
    "devon",
    "fes",
    "glasgow",
    "grayC",
    "hawaii",
    "imola",
    "lajolla",
    "lapaz",
    "lipari",
    "lisbon",
    "managua",
    "navia",
    "naviaW",
    "nuuk",
    "oleron",
    "oslo",
    "roma",
    "romaO",
    "tofino",
    "tokyo",
    "turku",
    "vanimo",
    "vik",
    "vikO"
]

func readMap(map: String, categorical: Bool) -> [[Float]]? {
    let currentDirectory =  URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let baseUrl = currentDirectory
            .appending(component: "ScientificColourMaps8")
            .appending(component: map)
    let fileUrl: URL
    if categorical {
        fileUrl = baseUrl
            .appending(component: "CategoricalPalettes")
            .appending(component: "\(map)S.txt")
    }
    else {
        fileUrl = baseUrl
            .appending(component: "\(map).txt")
    }
    do {
        let fileData = try String(contentsOf: fileUrl, encoding: .ascii)
        let lines = fileData.split(separator: "\n")
        var colormap: [[Float]] = []
        for line in lines {
            let numbers = line.components(separatedBy: " ").compactMap { Float($0) }
            colormap.append(numbers)
            assert(numbers.count == 3)
        }
        assert(colormap.count == (categorical ? 100 : 256))
        return colormap
    }
    catch {
        return nil
    }
}

var maps: [String: ([[Float]], [[Float]]?)] = [:]
for map in colormaps {
    print("Read colormap \(map)")
    let cm = readMap(map: map, categorical: false)!
    let cm_categorical = readMap(map: map, categorical: true)
    maps[map] = (cm, cm_categorical)
}

let fileHeader = """
        // This file is auto generated by running: swift run
        //
        // The source file is covered by licenses:
        // Copyright (c) 2023, Fabio Crameri
        // see ScientificColourMaps8/+LICENCE.pdf
        //
        // The color data is derived from Version 8.0.1 downloadable here:
        //    https://www.fabiocrameri.ch/colourmaps/
        //
        // Copyright (c) 2024, Jochen Kiemes
        // see LICENSE
        extension ScientificColorMaps {
        """


var palettes: [String] = []
var palettesWithCategory: [String] = []
for (map, cmPair) in maps {
    var swiftCode: [String] = []
    swiftCode.append(fileHeader)
    swiftCode.append("   private static let \(map)_raw: [(Float,Float,Float)] = [")
    for rgb in cmPair.0 {
        swiftCode.append(String(format: "      (%.6f, %.6f, %.6f),", rgb[0], rgb[1], rgb[2]))
    }
    swiftCode.append("   ]")
    palettes.append(map)
    if let cm = cmPair.1 {
        palettesWithCategory.append(map)
        swiftCode.append("   private static let \(map)_category_raw: [(Float,Float,Float)] = [")
        for rgb in cm {
            swiftCode.append(String(format: "      (%.6f, %.6f, %.6f),", rgb[0], rgb[1], rgb[2]))
        }
        swiftCode.append("   ]")
        swiftCode.append("   static let \(map) = ScientificColorMaps(\"\(map)\", raw: ScientificColorMaps.\(map)_raw, categories: \(map)_category_raw)")
    }
    else {
        swiftCode.append("   static let \(map) = ScientificColorMaps(\"\(map)\", raw: ScientificColorMaps.\(map)_raw)")
    }
    swiftCode.append("}")

    let code = swiftCode.joined(separator: "\n")
    let currentDirectory =  URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileUrl = currentDirectory
            .appending(component: "Sources")
            .appending(component: "ScientificColorMaps")
            .appending(component: "\(map).swift")
    try code.write(to: fileUrl, atomically: true, encoding: .utf8)
}

// create Palettes.swift
var swiftCode: [String] = []
swiftCode.append(fileHeader)
swiftCode.append("   static func palettes() -> [ScientificColorMaps] {")
swiftCode.append("      [")
for palette in palettes {
    swiftCode.append("        ScientificColorMaps.\(palette),")
}
swiftCode.append("      ]")
swiftCode.append("   }")
swiftCode.append("   static func categorizedPalettes() -> [ScientificColorMaps] {")
swiftCode.append("      [")
for palette in palettesWithCategory {
    swiftCode.append("        ScientificColorMaps.\(palette),")
}
swiftCode.append("      ]")
swiftCode.append("   }")
swiftCode.append("}")
let code = swiftCode.joined(separator: "\n")
let currentDirectory =  URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let fileUrl = currentDirectory
        .appending(component: "Sources")
        .appending(component: "ScientificColorMaps")
        .appending(component: "Palettes.swift")
try code.write(to: fileUrl, atomically: true, encoding: .utf8)
