//
//  TextTierScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  Per-element coverage for the two text families' Pass/Fail/Partial tiers (WCAG 1.4.4):
//
//    • AccessibleTextResize{Pass,Fail,Partial}    — BB40032 / BB40031
//    • AccessibleTextClipping{Pass,Fail,Partial}  — BB40030 / BB40033
//
//  Asserted as exact counts rather than "contains", because the interesting property of these
//  tiers is the split. A Partial screen reporting only failures, or a Fail screen where two of
//  five elements quietly pass, would satisfy a `contains` assertion while being wrong — and
//  that second case really happened: the clipping Fail tier was built with a text view whose
//  scrolling was disabled (so its contentSize could never exceed its bounds) and a two-line
//  label in a two-line-high frame, and neither clipped.
//
//  Each screen is scanned for its own family only, so these counts are not disturbed by rules
//  from elsewhere. The one row that still comes through is the engine's per-element
//  manual-review row, which is added outside the rule filter by design and subtracted here.
//
import XCTest

final class TextTierScanTests: XCTestCase {

    private let manualReviewTitle = "Check if interactive control name is descriptive"

    private let resizePass = "Text can be resized"
    private let resizeFail = "Text fails to resize"
    private let clipPass = "Text is not getting clipped"
    private let clipFail = "Text getting clipped"

    /// Rule title -> number of rows, for one screen scanned as one family.
    private func counts(_ screen: String, family: String) throws -> [String: Int] {
        let rows = try runScan(screen: screen, family: family, includePasses: true)
            .filter { $0.rule != manualReviewTitle }
        return Dictionary(grouping: rows, by: { $0.rule }).mapValues(\.count)
    }

    // MARK: - Resize (BB40031 / BB40032)

    func testTextResizePass_everyLabelScales() throws {
        let c = try counts("AccessibleTextResizePassViewController", family: "textResize")
        XCTAssertEqual(c[resizePass], 5, "All five elements opt into Dynamic Type")
        XCTAssertNil(c[resizeFail], "Nothing on the Pass tier may fail to resize")
    }

    func testTextResizeFail_noLabelScales() throws {
        let c = try counts("AccessibleTextResizeFailViewController", family: "textResize")
        XCTAssertEqual(c[resizeFail], 5, "All five elements have a fixed font size")
        XCTAssertNil(c[resizePass], "Nothing on the Fail tier may pass")
    }

    /// The half-migrated screen: body copy scales, the small chrome does not.
    func testTextResizePartial_reportsBothOutcomes() throws {
        let c = try counts("AccessibleTextResizePartialViewController", family: "textResize")
        XCTAssertEqual(c[resizePass], 3, "Title, body and footnote were migrated")
        XCTAssertEqual(c[resizeFail], 2, "The badge and tab caption are still hard-coded")
    }

    // MARK: - Clipping (BB40033 / BB40030)

    func testTextClippingPass_nothingIsClipped() throws {
        let c = try counts("AccessibleTextClippingPassViewController", family: "textClipping")
        XCTAssertEqual(c[clipPass], 5, "All five elements have room for their text")
        XCTAssertNil(c[clipFail], "Nothing on the Pass tier may clip")
    }

    func testTextClippingFail_everyElementIsClipped() throws {
        let c = try counts("AccessibleTextClippingFailViewController", family: "textClipping")
        XCTAssertEqual(c[clipFail], 5, "All five elements lose part of their text")
        XCTAssertNil(c[clipPass], "Nothing on the Fail tier may pass")
    }

    func testTextClippingPartial_reportsBothOutcomes() throws {
        let c = try counts("AccessibleTextClippingPartialViewController", family: "textClipping")
        XCTAssertEqual(c[clipPass], 3, "Heading, body and price all fit")
        XCTAssertEqual(c[clipFail], 2, "The promo strapline and the disclaimer are cut")
    }

    // MARK: - The tiers isolate one defect each

    /// A clipping screen must not also fail the resize rule, and vice versa. Both tiers were
    /// built so that the family under test is the only thing wrong with them — otherwise a
    /// reader cannot tell which defect a screen is demonstrating.
    func testEachTierIsolatesItsOwnDefect() throws {
        for screen in ["AccessibleTextClippingPassViewController",
                       "AccessibleTextClippingFailViewController",
                       "AccessibleTextClippingPartialViewController"] {
            let c = try counts(screen, family: "textResize")
            XCTAssertNil(c[resizeFail], "\(screen) is about clipping, but something fails to resize")
        }

        for screen in ["AccessibleTextResizePassViewController",
                       "AccessibleTextResizePartialViewController"] {
            let c = try counts(screen, family: "textClipping")
            XCTAssertNil(c[clipFail], "\(screen) is about resizing, but something is clipped")
        }
    }
}
