# Scientific Color Maps for Swift

This is package, which uses color data from https://www.fabiocrameri.ch/colourmaps/.

After package import, there is a static class available called `ScientificColorMaps`.

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

# Note:

API may change

# License

The color data has its own license. See in the respective file +LICENCE.pdf