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
        var data: [(Float, Float, Float, String, String)] = []
        let currentDirectory = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath)

        let referenceMap = ScientificColorMaps.batlow
        for colorMap in ScientificColorMaps.palettes() {
            var mapTypes: [(String, Int, [ScientificColor])] = [("range", 1, colorMap.discrete50())]
            if let colors = colorMap.categorical {
                let first10: [ScientificColor] = colors[0..<10].map{$0}
                mapTypes.append(("categorical", 5, first10))
            }

            for (type, scale, colors) in mapTypes {
                for (cds, name) in [
                    (ColorDeficiency.protanomaly(severity: 0), "normal"),
                    (ColorDeficiency.protanomaly(severity: 1), "protanomaly"),
                    (ColorDeficiency.deuteranomaly(severity: 1), "deuteranomaly"),
                    (ColorDeficiency.tritanomaly(severity: 1), "tritanomaly"),
                ] {
                    let description = "\(colorMap.name)_\(type)_\(name)"
                    var differenceImage: [Float] = []
                    var avgDifference: Float = 0
                    var pixelCount = 0
                    for xi in 0..<colors.count {
                        let xcol = cds.mapRGB(rgb: colors[xi].asSimd())
                        for _ in 1...scale {
                            for yi in 0..<colors.count {
                                var difference: Float = -1.0
                                if xi > yi {
                                    let ycol = cds.mapRGB(rgb: colors[yi].asSimd())
                                    difference = simd_distance(xcol, ycol)
                                    pixelCount += 1
                                    avgDifference += difference
                                }
                                for _ in 1...scale {
                                    differenceImage.append(difference)
                                }
                            }
                        }
                    }

                    let minDifference = differenceImage.filter { $0 > 0 }.min()!
                    let maxDifference = differenceImage.max()!
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
                                raw: $0.baseAddress!, w: colors.count * scale,
                                h: colors.count * scale),
                            let destination = CGImageDestinationCreateWithURL(
                                destinationURL as CFURL, "public.png" as CFString, 1, nil)
                        else { return false }
                        CGImageDestinationAddImage(destination, cgImage, nil)
                        return CGImageDestinationFinalize(destination)
                    }

                    let minMax = String(format: "min/max=%.4f/%.4f", minDifference, maxDifference)
                    let avg = String(format: "avg=%.4f", avgDifference)
                    print("difference \(type) \(avg), \(minMax): \(description)")

                    data.append((minDifference, maxDifference, avgDifference, type, description))
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

            markdownLines.append("") // add blank line before table
            markdownLines.append("|minimum|maximum|average|map name|delta image|")
            markdownLines.append("|-------|-------|-------|--------|-----------|")
            data.sort{ $0.2 > $1.2}
            for entry in data.filter({$0.3 == type}) {
                let minDiff = String(format: "%.4f", entry.0)
                let maxDiff = String(format: "%.4f", entry.1)
                let avgDiff = String(format: "%.4f", entry.2)
                let name = entry.4
                let url = "\(type)/\(entry.4).png"
                markdownLines.append("|\(minDiff)|\(maxDiff)|\(avgDiff)|\(name)|![\(name)](\(url))|")
            }
            markdownLines.append("") // ensure end of line
            let s = markdownLines.joined(separator: "\n")
            try! s.write(to: destinationURL, atomically: true, encoding: .utf8)
        }
    }
}
