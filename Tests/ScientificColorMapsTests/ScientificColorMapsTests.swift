import XCTest
@testable import ScientificColorMaps

final class ScientificColorMapsTests: XCTestCase {
    func testExistence() throws {
        let batlow = ScientificColorMap.batlow

        XCTAssertEqual(batlow.rgb_data.count, 256)
    }
    func testIterator() throws {
        let colormaps = ScientificColorMap.palettes()

        for scm in colormaps {
            XCTAssertEqual(scm.rgb_data.count, 256)
        }
    }
    func testIteratorCategorized() throws {
        let colormaps = ScientificColorMap.categorizedPalettes()

        for scm in colormaps {
            XCTAssertNotNil(scm.categorical)
            if let categorical = scm.categorical {
                XCTAssertEqual(categorical.count, 100)
            }
        }
    }
    func testMapColor() throws {
        let batlow = ScientificColorMap.batlow

        XCTAssertEqual(batlow.mapToColor(value: 0), batlow.rgb_data.first)
        XCTAssertEqual(batlow.mapToColor(value: 1), batlow.rgb_data.last)
        XCTAssertEqual(batlow.mapToColor(value: 0.5), batlow.rgb_data[128])
        XCTAssertEqual(batlow.mapToColor(value: 0.5).index, 128)
        XCTAssertEqual(batlow.mapToColor(value: -1, minValue: -1, maxValue: 42), batlow.rgb_data.first)
        XCTAssertEqual(batlow.mapToColor(value: 42, minValue: -1, maxValue: 42), batlow.rgb_data.last)
    }
    func testDiscrete() throws {
        let batlow = ScientificColorMap.batlow

        XCTAssertEqual(batlow.discrete10().count, 10)
        XCTAssertEqual(batlow.discrete25().count, 25)
        XCTAssertEqual(batlow.discrete50().count, 50)
        XCTAssertEqual(batlow.discrete100().count, 100)
    }
}

