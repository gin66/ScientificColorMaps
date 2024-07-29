# Scientific Color Maps
=====================

A collection of scientifically accurate color maps for use in data visualization.

## Overview

This package provides a set of pre-defined color maps that can be used to visualize data. Each color map is designed to accurately represent the underlying data, taking into account human perception and color theory.

## Features

* 32 scientifically accurate color maps, each with its own unique characteristics and uses.
* Categorized palettes for easy selection and use.
* Support for discrete color sampling (10, 25, 50, and 100 samples).
* Easy to use and integrate into your Swift project.

## Usage

To use the color maps in this package, simply import it into your Swift project and use the global instance of the desired color map. For example:

```swift
import ScientificColorMaps

let colorMap = ScientificColorMaps.batlow
```

## Color
Each color is represented as tuple of three float values as red, green and blue.

## List of Color palettes
Every color palette offers 256 colors
`ScientificColorMaps.palettes() -> [ScientificColorMaps]`

## List of Color palettes with categories
Every color palette offers 100 categories
`ScientificColorMaps.categorizedPalettes() -> [ScientificColorMaps]`

## API of ScientificColorMaps
* `name` ... String
* `rgb_data` ... array of 256 [(Float, Float, Float)]
* `categorical` ... array of 100 [(Float, Float, Float)] if defined, otherwise nil
* `discrete10() -> [(Float, Float, Float)]` ... subset of 10 colors
* `discrete25() -> [(Float, Float, Float)]` ... subset of 25 colors
* `discrete50()` -> [(Float, Float, Float)] ... subset of 50 colors
* `discrete100() -> [(Float, Float, Float)]` ... subset of 100 colors

# Code generator

Just run `swift run' in the package directory, which will (re-)create the color palette swift files in folder `Sources/ScientificColorMaps`

# Note:

API may change

# License

This package is licensed under the MIT License.
The color data has its own license. See in the respective file +LICENCE.pdf

## Acknowledgments

* This package was generated using data from Version 8.0.1 of the Scientific Colour Maps, available at <https://www.fabiocrameri.ch/colourmaps/>.
