// Copyright (c) 2024, Jochen Kiemes
// see LICENSE
final class ScientificColorMaps: Sendable {
    let rgb_data: [(Float, Float, Float)]

    init(raw data: [(Float, Float, Float)]) {
        rgb_data = data
    }
}