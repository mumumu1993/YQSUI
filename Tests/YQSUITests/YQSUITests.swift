import XCTest
import SwiftUI
@testable import YQSUI


final class YQSUITests: XCTestCase {
    func colorComponents(_ color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))
    }

    func testHexInitializer() {
        let c = Color(hex: 0xFF0000)
        let comps = colorComponents(c)
        XCTAssertEqual(comps.r, 1.0, accuracy: 0.001)
        XCTAssertEqual(comps.g, 0.0, accuracy: 0.001)
        XCTAssertEqual(comps.b, 0.0, accuracy: 0.001)
        XCTAssertEqual(comps.a, 1.0, accuracy: 0.001)
    }

    func testHexStringInitializer() {
        let c = Color(hexString: "#00FF00", alpha: 0.5)
        let comps = colorComponents(c)
        XCTAssertEqual(comps.r, 0.0, accuracy: 0.001)
        XCTAssertEqual(comps.g, 1.0, accuracy: 0.001)
        XCTAssertEqual(comps.b, 0.0, accuracy: 0.001)
        XCTAssertEqual(comps.a, 0.5, accuracy: 0.001)
    }

    func testHexStringInvalid() {
        let c = Color(hexString: "GARBAGE")
        let comps = colorComponents(c)
        // Color.clear on iOS is RGBA (0,0,0,0)
        XCTAssertEqual(comps.a, 0.0, accuracy: 0.001)
    }

    func testRGBInitializer() {
        let c = Color(red: 255, green: 128, blue: 64)
        let comps = colorComponents(c)
        XCTAssertEqual(comps.r, 1.0, accuracy: 0.001)
        XCTAssertEqual(comps.g, 128.0/255.0, accuracy: 0.001)
        XCTAssertEqual(comps.b, 64.0/255.0, accuracy: 0.001)
    }

    func testPresetYqsBlue() {
        let comps = colorComponents(Color.yqsBlue)
        let expected = colorComponents(Color(hex: 0x007AFF))
        XCTAssertEqual(comps.r, expected.r, accuracy: 0.001)
        XCTAssertEqual(comps.g, expected.g, accuracy: 0.001)
        XCTAssertEqual(comps.b, expected.b, accuracy: 0.001)
    }
}
