//
//  TargetSizeElementScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  Element-level coverage for WCAG 2.5.8 minimum target size across the three Target Size
//  screens, mirroring RoleElementScanTests' assertFires/assertDoesNotFire pattern.
//
//  The rule checks size FIRST, and that decides whether spacing is measured at all:
//
//    • at least 24×24pt → passes on size alone. Neighbours are never measured, because the
//      spacing exception exists to rescue targets SMALLER than the minimum; failing an
//      adequately-sized control for a tight gap would report something 2.5.8 does not ask.
//    • under 24×24pt → the exception is the only route through, and it needs at least 24pt of
//      clear space on every side that has a neighbour.
//
//  So the only shape that fails is undersized AND crowded. These tests are built around
//  proving that ordering rather than counting rows: the Fail screen's last pair is a
//  full-size crowded pair that must NOT be reported, and it is the most important assertion
//  in the file — a spacing-first implementation passes every other test here and fails that
//  one.
//
import XCTest

final class TargetSizeElementScanTests: XCTestCase {

    private let tooSmall = "Interactive control doesn't meet minimum target size requirements"
    private let verifySize = "Verify interactive control minimum target size requirements"

    private var targetSizeRules: [String] { [tooSmall, verifySize] }

    // MARK: - AccessibleTargetSizeFail — undersized and crowded

    /// 16×16 and 20×20, 8pt apart: each is under the minimum, and each is the reason the
    /// other cannot fall back on the spacing exception.
    func testTargetSizeFail_tinyPair_bothFail() throws {
        let issues = try runScan(screen: "AccessibleTargetSizeFailViewController")
        assertFires(issues, rule: tooSmall, elementContaining: "Dismiss")
        assertFires(issues, rule: tooSmall, elementContaining: "More information")
    }

    /// The stepper shape: 20×20 controls 8pt apart horizontally.
    func testTargetSizeFail_stepperPair_bothFail() throws {
        let issues = try runScan(screen: "AccessibleTargetSizeFailViewController")
        assertFires(issues, rule: tooSmall, elementContaining: "Decrease")
        assertFires(issues, rule: tooSmall, elementContaining: "Increase")
    }

    /// Inline list actions: wide enough, but only 20pt tall and 6pt apart vertically. Height
    /// alone under the minimum is enough — the rule needs both dimensions.
    func testTargetSizeFail_inlineListActions_bothFail() throws {
        let issues = try runScan(screen: "AccessibleTargetSizeFailViewController")
        assertFires(issues, rule: tooSmall, elementContaining: "Edit")
        assertFires(issues, rule: tooSmall, elementContaining: "Delete")
    }

    /// Two undersized controls occupying the same space: there is no gap to measure and no
    /// side to attribute it to, so both are reported.
    func testTargetSizeFail_overlappingPair_bothFail() throws {
        let issues = try runScan(screen: "AccessibleTargetSizeFailViewController")
        assertFires(issues, rule: tooSmall, elementContaining: "Back layer")
        assertFires(issues, rule: tooSmall, elementContaining: "Front layer")
    }

    /// The counter-example, and the reason this file exists: a 60×60 control with a
    /// neighbour 10pt below it. Neither is a failure, because size is checked first. An
    /// implementation that measured spacing on every control regardless of size would report
    /// both of these, and it would be wrong.
    func testTargetSizeFail_fullSizeCrowdedPair_isNotReportedAsAFailure() throws {
        let issues = try runScan(screen: "AccessibleTargetSizeFailViewController")
        assertDoesNotFire(issues, rule: tooSmall, elementContaining: "Save")
        assertDoesNotFire(issues, rule: tooSmall, elementContaining: "Cancel")

        // They are still measured — silence would be indistinguishable from being skipped.
        let verifies = issues.filter { $0.rule == verifySize }
        XCTAssertEqual(verifies.count, 2, "The two full-size controls should each ask to be verified: \(verifies.map(\.element))")
    }

    func testTargetSizeFail_coverage() throws {
        let issues = try runScan(screen: "AccessibleTargetSizeFailViewController")
        let failures = issues.filter { $0.rule == tooSmall }
        XCTAssertEqual(failures.count, 8, "Expected eight undersized-and-crowded controls, got: \(failures.map(\.element))")
    }

    // MARK: - AccessibleTargetSizePartial and Pass

    /// Every control on the Partial screen either clears 24×24 or has the clear space to be
    /// excused, so nothing on it is a defect — which is exactly what makes it the awkward
    /// tier to review by eye.
    func testTargetSizePartial_reportsNoSizeFailure() throws {
        let issues = try runScan(screen: "AccessibleTargetSizePartialViewController")
        let failures = issues.filter { $0.rule == tooSmall }
        XCTAssertTrue(failures.isEmpty, "Target Size Partial should report no size failure, got: \(failures.map(\.element))")
        XCTAssertFalse(issues.filter { $0.rule == verifySize }.isEmpty, "…but its controls should still be measured")
    }

    /// Nothing here is a defect, and every control still reports the Validate row: a frame
    /// measured once, at one Dynamic Type size in one orientation, is evidence rather than
    /// proof, so the scan says what it measured and asks a person to confirm it holds.
    func testTargetSizePass_noFailuresButEveryControlAsksToBeVerified() throws {
        let issues = try runScan(screen: "AccessibleTargetSizePassViewController")

        let failures = issues.filter { $0.rule == tooSmall }
        XCTAssertTrue(failures.isEmpty, "Target Size Pass must report no size failure, got: \(failures.map(\.element))")

        let verifies = issues.filter { $0.rule == verifySize }
        XCTAssertFalse(verifies.isEmpty, "Every measured control should ask to be verified: \(issues.map(\.rule))")
        XCTAssertTrue(
            verifies.allSatisfy { $0.status.lowercased() == "validate" },
            "The verify row must be Validate, not Fail: \(verifies.map { "[\($0.status)] \($0.element)" })"
        )
    }

    /// A control is never silently skipped, which is what makes the absence of a row on any
    /// one control meaningful.
    func testEveryScreen_reportsAnOutcomeForItsControls() throws {
        let screens = [
            "AccessibleTargetSizeFailViewController",
            "AccessibleTargetSizePartialViewController",
            "AccessibleTargetSizePassViewController",
        ]
        for screen in screens {
            let issues = try runScan(screen: screen)
            let measured = issues.filter { targetSizeRules.contains($0.rule) }
            XCTAssertFalse(measured.isEmpty, "\(screen) produced no target-size rows at all")
        }
    }

    // MARK: - Assertion helpers (same shape as RoleElementScanTests.swift's own)

    private func assertFires(
        _ issues: [A11yIssue],
        rule: String,
        elementContaining substring: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let matches = issues.filter {
            $0.rule == rule && $0.status.lowercased() == "fail" && $0.element.contains(substring)
        }
        XCTAssertFalse(
            matches.isEmpty,
            "Expected a [FAIL] '\(rule)' for element containing '\(substring)' — none found. All issues: \(issues.map { "[\($0.status)] \($0.rule) — \($0.element)" })",
            file: file, line: line
        )
    }

    private func assertDoesNotFire(
        _ issues: [A11yIssue],
        rule: String,
        elementContaining substring: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let matches = issues.filter { $0.rule == rule && $0.element.contains(substring) }
        XCTAssertTrue(
            matches.isEmpty,
            "Did not expect '\(rule)' for element containing '\(substring)', but found: \(matches.map { "[\($0.status)] \($0.element)" })",
            file: file, line: line
        )
    }
}
