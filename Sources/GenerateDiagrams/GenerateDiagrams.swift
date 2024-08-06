import CoreGraphics
import Foundation
import ImageIO
import ScientificColorMaps
import UniformTypeIdentifiers
import simd

func byteArrayRGBAU8ToCGImage(
    raw: UnsafeMutablePointer<UInt8>,  // Your byte array
    w: Int,  // your image's width
    h: Int  // your image's height
) -> CGImage? {
    // 4 bytes(rgba channels) for each pixel
    let bytesPerPixel = 4
    // (8 bits per each channel)
    let bitsPerComponent = 8

    let bitsPerPixel = bytesPerPixel * bitsPerComponent
    // channels in each row (width)
    let bytesPerRow: Int = w * bytesPerPixel

    let cfData = CFDataCreate(nil, raw, w * h * bytesPerPixel)
    let cgDataProvider = CGDataProvider(data: cfData!)!

    let deviceColorSpace = CGColorSpaceCreateDeviceRGB()

    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
    let image: CGImage? = CGImage(
        width: w,
        height: h,
        bitsPerComponent: bitsPerComponent,
        bitsPerPixel: bitsPerPixel,
        bytesPerRow: bytesPerRow,
        space: deviceColorSpace,
        bitmapInfo: bitmapInfo,
        provider: cgDataProvider,
        decode: nil,
        shouldInterpolate: true,
        intent: CGColorRenderingIntent.defaultIntent)

    return image
}

@main
struct GenerateDiagramsMain {
    static func main() {
        var data: [String: Float] = [:]
        let currentDirectory = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath)

        let cdsList: [(ColorDeficiency, String)] = [
            (ColorDeficiency.protanomaly(severity: 0), "normal"),
            (ColorDeficiency.protanomaly(severity: 1), "protanomaly"),
            (ColorDeficiency.deuteranomaly(severity: 1), "deuteranomaly"),
            (ColorDeficiency.tritanomaly(severity: 1), "tritanomaly"),
        ]

        let referenceMap = ScientificColorMaps.vik
        for colorMap in ScientificColorMaps.palettes() {
            var mapTypes: [(String, Int, Int, [ScientificColor])] = [
                ("range", 1, 9, colorMap.discrete50())
            ]
            if let colors = colorMap.categorical {
                let first10: [ScientificColor] = colors[0..<10].map { $0 }
                mapTypes.append(("categorical", 5, 1, first10))
            }

            for (type, scale, barPoints, colors) in mapTypes {
                for (cds, name) in cdsList {
                    // calculate color differences
                    var diff: [[Float]] = []
                    var diffBlack: [Float] = []
                    var diffWhite: [Float] = []
                    var avgDifference: Float = 0
                    var pixelCount = 0
                    for yi in 0..<colors.count {
                        let ycol = cds.mapRGB(rgb: colors[yi].asSimd())
                        var row: [Float] = []
                        for xi in 0..<colors.count {
                            let xcol = cds.mapRGB(rgb: colors[xi].asSimd())
                            let difference = simd_distance(xcol, ycol)
                            row.append(difference)
                            pixelCount += 1
                            avgDifference += difference
                        }
                        diff.append(row)
                    }
                    for i in 0..<colors.count {
                        let rcol = cds.mapRGB(rgb: colors[i].asSimd())

                        // contrast to black - dark background
                        let bcol = cds.mapRGB(rgb: simd_float3.zero)
                        diffBlack.append(simd_distance(bcol, rcol))

                        // contrast to white - light background
                        let wcol = cds.mapRGB(rgb: simd_float3.one)
                        diffWhite.append(simd_distance(wcol, rcol))
                    }

                    let description = "\(colorMap.name)_\(type)_\(name)"
                    var differenceImage: [[simd_float3]] = []
                    let gridColor = simd_float3.one * 0.7
                    for yi in 0..<colors.count {
                        var row: [simd_float3] = []

                        for _ in 1...barPoints {
                            row.append(colors[yi].asSimd())
                        }
                        row.append(gridColor)

                        for xi in 0..<colors.count {
                            let difference: Float
                            var col: simd_float3? = nil
                            if xi == yi {
                                col = simd_float3.zero
                                difference = 0
                            }
                            else if xi < yi {
                                difference = diff[yi][xi]
                            }
                            else if xi > colors.count - yi {
                                difference = diffBlack[yi]
                                if colors.count - xi > colors.count / 4 {
                                    col = simd_float3.zero
                                }
                            }
                            else {
                                difference = diffWhite[xi]
                                if yi > colors.count / 4 {
                                    col = simd_float3.one
                                }
                            }
                            if col == nil {
                                col = referenceMap.mapToColor(value: difference, maxValue: sqrt(3))
                                    .asSimd()
                            }
                            row.append(col!)
                        }
                        differenceImage.append(row)
                    }
                    avgDifference = avgDifference / Float(pixelCount)

                    // append color bar
                    differenceImage.append(differenceImage.first!.map { _ in gridColor })
                    var barRow: [simd_float3] = []
                    for i in 0..<(colors.count + barPoints + 1) {
                        let xi = i - (barPoints + 1)
                        if xi < -1 {
                            barRow.append(simd_float3.zero)
                        }
                        else if xi < 0 {
                            barRow.append(gridColor)
                        }
                        else {
                            barRow.append(colors[xi].asSimd())
                        }
                    }
                    for _ in 0...barPoints {
                        differenceImage.append(barRow)
                    }

                    // scale image
                    var scaledImage: [[simd_float3]] = []
                    for row in differenceImage {
                        let newRow = row.flatMap {
                            col in
                            (1...scale).map { _ in col }
                        }
                        for _ in 1...scale {
                            scaledImage.append(newRow)
                        }
                    }

                    // Flip y axes
                    scaledImage.reverse()

                    // width and height without scale
                    let width = colors.count + barPoints + 1
                    let height = colors.count + barPoints + 1
                    var u8Image = scaledImage.flatMap {
                        row in
                        return row.flatMap {
                            col in
                            return [
                                UInt8(col.x * 255), UInt8(col.y * 255), UInt8(col.z * 255), 255,
                            ]
                        }
                    }

                    let destinationURL =
                        currentDirectory
                        .appendingPathComponent("Diagrams")
                        .appendingPathComponent(type)
                        .appendingPathComponent("\(description).png")

                    _ = u8Image.withUnsafeMutableBufferPointer {
                        guard
                            let cgImage = byteArrayRGBAU8ToCGImage(
                                raw: $0.baseAddress!, w: width * scale,
                                h: height * scale),
                            let destination = CGImageDestinationCreateWithURL(
                                destinationURL as CFURL, "public.png" as CFString, 1, nil)
                        else { return false }
                        CGImageDestinationAddImage(destination, cgImage, nil)
                        return CGImageDestinationFinalize(destination)
                    }

                    let avg = String(format: "avg=%.4f", avgDifference)
                    print("difference \(type) \(avg): \(description)")

                    data[description] = avgDifference
                }
            }
        }

        // Create markdown
        for type in ["categorical", "range"] {
            var markdownLines: [String] = []
            let destinationURL =
                currentDirectory
                .appendingPathComponent("Diagrams")
                .appendingPathComponent("Readme_\(type).md")

            var selectedData: [String: Float] = [:]
            for (name, value) in data {
                if name.contains(type) {
                    selectedData[name] = value
                }
            }

            var collectedData: [(Float, String, [Float])] = []
            for colorMap in ScientificColorMaps.palettes() {
                var avgList: [Float] = []
                for (_, name) in cdsList {
                    let description = "\(colorMap.name)_\(type)_\(name)"
                    if let avg = selectedData[description] {
                        avgList.append(avg)
                    }
                }
                if avgList.count == cdsList.count {
                    let minAvg = avgList.min()!
                    collectedData.append((minAvg, "\(colorMap.name)_\(type)", avgList))
                }
            }

            markdownLines.append("")  // add blank line before table

            let headers = cdsList.map { $0.1 }.joined(separator: "|")
            let headerlines = cdsList.map { _ in "---" }.joined(separator: "|")
            markdownLines.append("|min average|map name|\(headers)|")
            markdownLines.append("|-----------|--------|\(headerlines)|")

            collectedData.sort { $0.0 > $1.0 }
            for entry in collectedData {
                let avgDiff = String(format: "%.4f", entry.0)
                let name = entry.1
                let imageList = cdsList.map { "![\(name)_\($0.1)](\(type)/\(name)_\($0.1).png)" }
                    .joined(separator: "|")
                markdownLines.append("\(avgDiff)|\(name)|\(imageList)|")
            }
            markdownLines.append("")  // ensure end of line
            let s = markdownLines.joined(separator: "\n")
            try! s.write(to: destinationURL, atomically: true, encoding: .utf8)
        }
    }
}
