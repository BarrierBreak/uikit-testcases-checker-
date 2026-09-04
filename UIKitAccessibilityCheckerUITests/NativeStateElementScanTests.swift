//
//  NativeStateElementScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  Element-level regression coverage for the "Native State" example screen family
//  (AccessibleNativeStatePass/Fail/Partial), mirroring RoleElementScanTests.swift's
//  assertFires/assertDoesNotFire pattern for the Role/Native Role screens. Unlike
//  A11yFrameworkScanTests (which only checks that a scan completes), these assert the
//  SPECIFIC rule/element pairing the framework reports for the one native control these
//  screens exercise a state rule on.
//
//  Of the nine native controls on each screen, only notificationsSwitch (a UISwitch) is
//  covered by any of the four active state rules — UIKitA11yScanRunner's
//  check_uikit_native_switch_state is deliberately scoped to UISwitch only, since it is
//  the one native control here whose state is a plain boolean toggle. The other eight
//  (UISlider, UIStepper, UISegmentedControl, UIPageControl, the two UIButtons, UIProgress-
//  View, UIActivityIndicatorView) are a different bug shape entirely — selection-among-
//  many, disabled-state, range/rating, busy-indicator — that none of the four state rules
//  are built to catch, on any tier; see AccessibleNativeStateFailUIKit.swift's own module
//  doc comment. This file exists to pin that scope down as a deliberate, visible baseline
//  rather than a silent gap: a state rule ever firing on one of those eight controls, or
//  on Pass's switch, is a real regression.
//

import XCTest

final class NativeStateElementScanTests: XCTestCase {

    private let stateRuleTitles = [
        "Missing state information for interactive control",
        "Verify if the state for interactive control gets updated on user interaction",
        "Incorrect State value provided for interactive control",
        "State does not get updated on user interaction",
    ]

    // MARK: - AccessibleNativeStateFail

    func testAccessibleNativeStateFail_switch_incorrectValue() throws {
        let issues = try runScan(screen: "AccessibleNativeStateFailViewController")
        // notificationsSwitch.accessibilityValue reads the wrong branch of its own
        // ternary (`isOn ? "Off" : "On"`) — a value that updates every time but with
        // inverted wording, so this is "incorrect", not "missing" or "doesn't update".
        assertFires(issues, rule: "Incorrect State value provided for interactive control", elementContaining: "Enable notifications")
        assertDoesNotFire(issues, rule: "Missing state information for interactive control", elementContaining: "Enable notifications")
        assertDoesNotFire(issues, rule: "State does not get updated on user interaction", elementContaining: "Enable notifications")
        assertDoesNotFire(issues, rule: "Verify if the state for interactive control gets updated on user interaction", elementContaining: "Enable notifications")
    }

    func testAccessibleNativeStateFail_onlyTheSwitchReportsAStateRule() throws {
        let issues = try runScan(screen: "AccessibleNativeStateFailViewController")
        let stateFails = issues.filter { stateRuleTitles.contains($0.rule) }
        XCTAssertEqual(
            stateFails.count, 1,
            "Expected only notificationsSwitch to report a state rule on this screen (the other eight native controls are a different bug shape, out of scope for these four rules); got: \(stateFails.map { "\($0.rule) — \($0.element)" })"
        )
    }

    // MARK: - AccessibleNativeStatePartial

    func testAccessibleNativeStatePartial_switch_doesNotUpdateOnInteraction() throws {
        let issues = try runScan(screen: "AccessibleNativeStatePartialViewController")
        // notificationsSwitch.accessibilityValue is hardcoded "Off" once during
        // buildLayout() and never touched again in the valueChanged action — a value
        // that exists but never refreshes, not a missing or wrong one.
        assertFires(issues, rule: "State does not get updated on user interaction", elementContaining: "Enable notifications")
        assertDoesNotFire(issues, rule: "Missing state information for interactive control", elementContaining: "Enable notifications")
        assertDoesNotFire(issues, rule: "Incorrect State value provided for interactive control", elementContaining: "Enable notifications")
        assertDoesNotFire(issues, rule: "Verify if the state for interactive control gets updated on user interaction", elementContaining: "Enable notifications")
    }

    func testAccessibleNativeStatePartial_onlyTheSwitchReportsAStateRule() throws {
        let issues = try runScan(screen: "AccessibleNativeStatePartialViewController")
        let stateFails = issues.filter { stateRuleTitles.contains($0.rule) }
        XCTAssertEqual(
            stateFails.count, 1,
            "Expected only notificationsSwitch to report a state rule on this screen; got: \(stateFails.map { "\($0.rule) — \($0.element)" })"
        )
    }

    // MARK: - AccessibleNativeStatePass — no manual accessibilityValue override anywhere,
    // so every control's state (including the switch) is UIKit's own automatic, correct
    // behavior — zero state-rule rows expected.

    func testAccessibleNativeStatePass_noStateRuleFindings() throws {
        let issues = try runScan(screen: "AccessibleNativeStatePassViewController")
        let stateIssues = issues.filter { stateRuleTitles.contains($0.rule) }
        XCTAssertTrue(
            stateIssues.isEmpty,
            "Native State Pass should report none of the four state rules at all (Fail or Validate), got: \(stateIssues.map { "[\($0.status)] \($0.rule) — \($0.element)" })"
        )
    }

    // MARK: - Assertion helpers (same shape as RoleElementScanTests.swift's own)

    private func assertFires(
        _ issues: [A11yIssue],
        rule: String,
        elementContaining substring: String?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let matches = issues.filter { issue in
            issue.rule == rule
                && issue.status.lowercased() == "fail"
                && (substring == nil || issue.element.contains(substring!))
        }
        XCTAssertFalse(
            matches.isEmpty,
            "Expected a [FAIL] '\(rule)'\(substring.map { " for element containing '\($0)'" } ?? "") — none found. All issues: \(issues.map { "[\($0.status)] \($0.rule) — \($0.element)" })",
            file: file, line: line
        )
    }

    /// Checks no row at all — Fail, Validate, or otherwise — reports `rule` for an element
    /// containing `substring`.
    private func assertDoesNotFire(
        _ issues: [A11yIssue],
        rule: String,
        elementContaining substring: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let matches = issues.filter { issue in
            issue.rule == rule && issue.element.contains(substring)
        }
        XCTAssertTrue(
            matches.isEmpty,
            "Did not expect '\(rule)' for element containing '\(substring)', but found: \(matches.map { "[\($0.status)] \($0.rule) — \($0.element)" })",
            file: file, line: line
        )
    }
}
