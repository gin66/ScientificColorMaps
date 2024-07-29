// Copyright (c) 2024, Jochen Kiemes

import Foundation

// List of available colormaps
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

/**
 Reads a colormap from a file.

 - Parameters:
   - map: The name of the colormap to read.
   - categorical: Whether to read the categorical version of the colormap.

 - Returns: The colormap as a 2D array of floats, or nil if the file could not be read.
 */
func readMap(map: String, categorical: Bool) -> [[Float]]? {
    // Get the current directory
    let currentDirectory =  URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    // Construct the URL of the colormap file
    let baseUrl = currentDirectory
            .appendingPathComponent("ScientificColourMaps8")
            .appendingPathComponent(map)
    let fileUrl: URL
    if categorical {
        // Categorical colormaps are stored in a separate directory
        fileUrl = baseUrl
            .appendingPathComponent("CategoricalPalettes")
            .appendingPathComponent("\(map)S.txt")
    }
    else {
        // Non-categorical colormaps are stored in the base directory
        fileUrl = baseUrl
            .appendingPathComponent("\(map).txt")
    }

    do {
        // Read the file contents
        let fileData = try String(contentsOf: fileUrl, encoding: .ascii)

        // Split the file into lines
        let lines = fileData.split(separator: "\n")

        // Initialize the colormap array
        var colormap: [[Float]] = []

        // Iterate over each line in the file
        for line in lines {
            // Split the line into numbers
            let numbers = line.components(separatedBy: " ").compactMap { Float($0) }

            // Add the numbers to the colormap array
            colormap.append(numbers)

            // Assert that each line has exactly 3 numbers
            assert(numbers.count == 3)
        }

        // Assert that the colormap has the correct number of lines
        assert(colormap.count == (categorical ? 100 : 256))

        // Return the colormap
        return colormap
    }
    catch {
        // If an error occurs, return nil
        return nil
    }
}

// Dictionary to store the colormaps
var maps: [String: ([[Float]], [[Float]]?)] = [:]

// Iterate over each colormap and read its data
for map in colormaps {
    print("Read colormap \(map)")
    let cm = readMap(map: map, categorical: false)!
    let cm_categorical = readMap(map: map, categorical: true)
    maps[map] = (cm, cm_categorical)
}

// Header for the generated Swift code
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

// Arrays to store the names of palettes with and without categories
var palettes: [String] = []
var palettesWithCategory: [String] = []

// Iterate over each colormap and generate Swift code for it
for (map, cmPair) in maps {
    var swiftCode: [String] = []

    // Add the file header
    swiftCode.append(fileHeader)

    // Add the raw colormap data
    swiftCode.append("   private static let \(map)_raw: [(Float,Float,Float)] = [")
    for rgb in cmPair.0 {
        swiftCode.append(String(format: "      (%.6f, %.6f, %.6f),", rgb[0], rgb[1], rgb[2]))
    }
    swiftCode.append("   ]")

    // Add the palette to the list of palettes
    palettes.append(map)

    // If the colormap has a categorical version, add it to the list of palettes with categories
    if let cm = cmPair.1 {
        palettesWithCategory.append(map)

        // Add the categorical colormap data
        swiftCode.append("   private static let \(map)_category_raw: [(Float,Float,Float)] = [")
        for rgb in cm {
            swiftCode.append(String(format: "      (%.6f, %.6f, %.6f),", rgb[0], rgb[1], rgb[2]))
        }
        swiftCode.append("   ]")

        // Add the palette to the ScientificColorMaps extension
        swiftCode.append("   static let \(map) = ScientificColorMaps(\"\(map)\", raw: ScientificColorMaps.\(map)_raw, categories: \(map)_category_raw)")
    }
    else {
        // Add the palette to the ScientificColorMaps extension
        swiftCode.append("   static let \(map) = ScientificColorMaps(\"\(map)\", raw: ScientificColorMaps.\(map)_raw)")
    }

    // Close the extension
    swiftCode.append("}")

    // Join the Swift code into a single string
    let code = swiftCode.joined(separator: "\n")

    // Write the code to a file
    let currentDirectory =  URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileUrl = currentDirectory
            .appendingPathComponent("Sources")
            .appendingPathComponent("ScientificColorMaps")
            .appendingPathComponent("\(map).swift")
    try code.write(to: fileUrl, atomically: true, encoding: .utf8)
}

// Create the Palettes.swift file
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

// Join the Swift code into a single string
let code = swiftCode.joined(separator: "\n")

// Write the code to a file
let currentDirectory =  URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let fileUrl = currentDirectory
        .appendingPathComponent("Sources")
        .appendingPathComponent("ScientificColorMaps")
        .appendingPathComponent("Palettes.swift")
try code.write(to: fileUrl, atomically: true, encoding: .utf8)
