import XCTest
@testable import ScientificColorMaps

final class ScientificColorMapsTests: XCTestCase {
    func testExistence() throws {
        let batlow = ScientificColorMaps.batlow

        XCTAssertEqual(batlow.rgb_data.count, 256)
    }
    func testIterator() throws {
        let colormaps = ScientificColorMaps.palettes()

        for scm in colormaps {
            XCTAssertEqual(scm.rgb_data.count, 256)
        }
    }
    func testIteratorCategorized() throws {
        let colormaps = ScientificColorMaps.categorizedPalettes()

        for scm in colormaps {
            XCTAssertNotNil(scm.categorical)
            if let categorical = scm.categorical {
                XCTAssertEqual(categorical.count, 100)
            }
        }
    }
}
