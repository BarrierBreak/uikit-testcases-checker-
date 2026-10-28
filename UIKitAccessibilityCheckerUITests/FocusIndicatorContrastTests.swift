//
//  FocusIndicatorContrastTests.swift
//
//  Focus indicator colour contrast, one test per tier. The scan is narrowed to the focus rules
//  (BB40117 "Insufficient color contrast for focus indicator", BB40119 "Color alone used to
//  indicate focus"), and the rows each Focus screen promises in its doc comment are counted.
//
//    Pass     3 rings, all easy to see and more than a colour          -> nothing
//    Fail     4 rings: light and grey 2pt (117), dark hairline (119),
//             light hairline (both)                                    -> 3 x BB40117, 2 x BB40119
//    Partial  2 sound rings, a light 2pt ring, a dark hairline         -> 1 x BB40117, 1 x BB40119
//
import XCTest

final class FocusIndicatorContrastTests: XCTestCase {

    private let contrast = "Insufficient color contrast for focus indicator"
    private let colourOnly = "Color alone used to indicate focus"

    /// "<status> <title>" for every focus row of the screen, sorted.
    private func rows(_ screen: String, file: StaticString = #filePath, line: UInt = #line) throws -> [String] {
        try runScan(screen: screen, family: "focus", includePasses: true, file: file, line: line)
            .filter { $0.rule == contrast || $0.rule == colourOnly }
            .map { "\($0.status) \($0.rule)" }
            .sorted()
    }

    func testFocusIndicatorContrastPass() throws {
        XCTAssertEqual(try rows("AccessibleFocusPassViewController"), [])
    }

    func testFocusIndicatorContrastFail() throws {
        let expected = Array(repeating: "Fail \(contrast)", count: 3) + Array(repeating: "Fail \(colourOnly)", count: 2)
        XCTAssertEqual(try rows("AccessibleFocusFailViewController"), expected.sorted())
    }

    func testFocusIndicatorContrastPartial() throws {
        XCTAssertEqual(try rows("AccessibleFocusPartialViewController"), ["Fail \(colourOnly)", "Fail \(contrast)"].sorted())
    }
}
