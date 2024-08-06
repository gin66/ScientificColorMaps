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
            var mapTypes: [(String, Int, [ScientificColor])] = [("range", 1, colorMap.discrete50())]
            if let colors = colorMap.categorical {
                let first10: [ScientificColor] = colors[0..<10].map { $0 }
                mapTypes.append(("categorical", 5, first10))
            }

            for (type, scale, colors) in mapTypes {
                for (cds, name) in cdsList {
                    // width and height without scale
                    let width = colors.count
                    let height = colors.count
                    let description = "\(colorMap.name)_\(type)_\(name)"
                    var differenceImage: [Float] = []
                    var avgDifference: Float = 0
                    var pixelCount = 0
                    for _yi in 0..<colors.count {
                        let yi = colors.count - 1 - _yi
                        let ycol = cds.mapRGB(rgb: colors[yi].asSimd())
                        for _ in 1...scale {
                            for xi in 0..<colors.count {
                                let xcol = cds.mapRGB(rgb: colors[xi].asSimd())
                                var difference: Float = -1.0  // this will be encoded as transparent
                                if xi < yi {
                                    difference = simd_distance(xcol, ycol)
                                    pixelCount += 1
                                    avgDifference += difference
                                }
                                else if xi > colors.count - yi {
                                    // contrast to black - dark background
                                    let bcol = cds.mapRGB(rgb: simd_float3.zero)
                                    difference = simd_distance(bcol, ycol)
                                }
                                else  {
                                    // contrast to white - light background
                                    let bcol = cds.mapRGB(rgb: simd_float3.one)
                                    difference = simd_distance(xcol, bcol)
                                }
                                for _ in 1...scale {
                                    differenceImage.append(difference)
                                }
                            }
                        }
                    }

                    avgDifference = avgDifference / Float(pixelCount)

                    var u8Image = differenceImage.flatMap {
                        difference in
                        if difference >= 0 {
                            let col = referenceMap.mapToColor(
                                value: difference, maxValue: sqrt(3)
                            )
                            .asSimd()
                            return [
                                UInt8(col.x * 255), UInt8(col.y * 255), UInt8(col.z * 255), 255,
                            ]
                        }
                        return [0, 0, 0, 0]
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
