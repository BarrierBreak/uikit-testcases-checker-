//
//  NativeStateElementScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  Element-level regression coverage for the "Native State" example screen family
//  (AccessibleNativeStatePass/Fail/Partial), mirroring RoleElementScanTests.swift's
//  assertFires/assertDoesNotFire pattern. The custom-control State screens are covered
//  separately in StateElementScanTests.swift.
//
//  This file previously pinned down a deliberate gap: only the UISwitch was covered, because
//  the state checks were scoped to a plain boolean toggle and the other eight native controls
//  are different bug shapes (a range value, a selection, an enablement, a busy indicator).
//  Those shapes now each have their own source-level check, so every one of them is asserted
//  here instead.
//
//  The rule these screens exist to demonstrate: UIKit already announces a UISwitch, UISlider,
//  UIStepper, UISegmentedControl, UIPageControl, UIProgressView and a selected/disabled
//  UIButton's own state correctly, for free. Every defect here comes from a developer
//  REPLACING that live state with a hand-written string or trait which then has to be
//  maintained by hand and is not — so the Pass tier's correctness comes from writing LESS
//  accessibility code, not more.
//
//  One inherent exception, asserted nowhere: the UIActivityIndicatorView. It defaults to
//  `hidesWhenStopped = true`, so while idle it is not on screen and a scan correctly skips
//  it — the source-level finding for it exists but has no live element to attach to until the
//  spinner is actually running.
//
import XCTest

final class NativeStateElementScanTests: XCTestCase {

    private let missing = "Missing state information for interactive control"
    private let incorrect = "Incorrect State value provided for interactive control"
    private let notUpdated = "State does not get updated on user interaction"
    private let verifyUpdates = "Verify if the state for interactive control gets updated on user interaction"

    private var stateRules: [String] { [missing, incorrect, notUpdated, verifyUpdates] }

    // MARK: - AccessibleNativeStateFail — announcements that contradict the screen

    /// `accessibilityValue = isOn ? "Off" : "On"` — refreshed on every change, always backwards.
    func testNativeStateFail_switch_valueIsInverted() throws {
        let issues = try runScan(screen: "AccessibleNativeStateFailViewController")
        assertFires(issues, rule: incorrect, elementContaining: "Enable notifications")
        assertOnlyRule(issues, rule: incorrect, elementContaining: "Enable notifications")
    }

    /// Reports `maximumValue` rather than `value`, so it announces "100 percent" wherever the
    /// thumb sits — and no valueChanged action is wired to recompute it either way.
    func testNativeStateFail_slider_valueNeverTracksTheThumb() throws {
        let issues = try runScan(screen: "AccessibleNativeStateFailViewController")
        assertFires(issues, rule: notUpdated, elementContaining: "Volume")
        assertOnlyRule(issues, rule: notUpdated, elementContaining: "Volume")
    }

    /// `isAccessibilityElement = false` on the stepper and its label: the element that would
    /// carry the value is gone from the tree, so it reports as an unnamed control with no state.
    func testNativeStateFail_stepper_isRemovedFromTheTree() throws {
        let issues = try runScan(screen: "AccessibleNativeStateFailViewController")
        let unnamed = issues.filter { stateRules.contains($0.rule) && $0.element.hasPrefix("no name") }
        XCTAssertEqual(
            unnamed.map(\.rule), [missing],
            "Expected the stepper to report missing state as an unnamed element, got: \(unnamed.map { "\($0.rule) — \($0.element)" })"
        )
    }

    /// A hand-written value replaces UIKit's own "selected, 2 of 3" announcement.
    func testNativeStateFail_segmentedControl_valueHidesTheRealSelection() throws {
        let issues = try runScan(screen: "AccessibleNativeStateFailViewController")
        assertFires(issues, rule: notUpdated, elementContaining: "Favorite color")
        assertOnlyRule(issues, rule: notUpdated, elementContaining: "Favorite color")
    }

    func testNativeStateFail_pageControl_alwaysAnnouncesTheLastPage() throws {
        let issues = try runScan(screen: "AccessibleNativeStateFailViewController")
        assertFires(issues, rule: notUpdated, elementContaining: "Onboarding pages")
        assertOnlyRule(issues, rule: notUpdated, elementContaining: "Onboarding pages")
    }

    /// `.selected` written into the traits by hand while the action toggles nothing at all —
    /// an empty star announced as selected, permanently.
    func testNativeStateFail_toggleButton_selectedTraitIsHardcoded() throws {
        let issues = try runScan(screen: "AccessibleNativeStateFailViewController")
        assertFires(issues, rule: incorrect, elementContaining: "Mark as favorite")
        assertOnlyRule(issues, rule: incorrect, elementContaining: "Mark as favorite")
    }

    /// `.notEnabled` inserted by hand on a button whose `isEnabled` is true — the inverse of
    /// the Partial tier's bug, and the reason to drive enablement from the real property.
    func testNativeStateFail_disabledButton_notEnabledTraitContradictsIsEnabled() throws {
        let issues = try runScan(screen: "AccessibleNativeStateFailViewController")
        assertFires(issues, rule: incorrect, elementContaining: "Submit")
        assertOnlyRule(issues, rule: incorrect, elementContaining: "Submit")
    }

    func testNativeStateFail_progressView_announcesCompleteAtFortyPercent() throws {
        let issues = try runScan(screen: "AccessibleNativeStateFailViewController")
        assertFires(issues, rule: notUpdated, elementContaining: "Download progress")
        assertOnlyRule(issues, rule: notUpdated, elementContaining: "Download progress")
    }

    func testNativeStateFail_stateRuleCoverage() throws {
        let issues = try runScan(screen: "AccessibleNativeStateFailViewController")
        let rows = issues.filter { stateRules.contains($0.rule) }
        XCTAssertEqual(rows.count, 8, "Expected eight state rows, got: \(rows.map { "\($0.rule) — \($0.element)" })")
    }

    // MARK: - AccessibleNativeStatePartial — overrides frozen at launch

    /// Assigning any `accessibilityValue` to a UISwitch replaces its live on/off state, and
    /// the wired valueChanged action here is empty, so it announces "Off" forever.
    func testNativeStatePartial_switch_valueNeverRefreshed() throws {
        let issues = try runScan(screen: "AccessibleNativeStatePartialViewController")
        assertFires(issues, rule: notUpdated, elementContaining: "Enable notifications")
        assertOnlyRule(issues, rule: notUpdated, elementContaining: "Enable notifications")
    }

    /// Each of these carries a hand-written value that was correct at launch and is never
    /// recomputed — the single most common way to break a native control's state. The stepper
    /// is the clearest case: its own action updates the visible label and not the value.
    func testNativeStatePartial_frozenOverridesOnEveryValueControl() throws {
        let issues = try runScan(screen: "AccessibleNativeStatePartialViewController")
        for control in ["Volume", "Quantity", "Favorite color", "Onboarding pages", "Download progress"] {
            assertFires(issues, rule: notUpdated, elementContaining: control)
            assertOnlyRule(issues, rule: notUpdated, elementContaining: control)
        }
    }

    /// Driven by a private `isFavorite` Bool and an image swap, so the real `isSelected` — the
    /// property UIKit derives the `.selected` trait from — is never touched.
    func testNativeStatePartial_toggleButton_usesAShadowBoolInsteadOfIsSelected() throws {
        let issues = try runScan(screen: "AccessibleNativeStatePartialViewController")
        assertFires(issues, rule: missing, elementContaining: "Mark as favorite")
        assertOnlyRule(issues, rule: missing, elementContaining: "Mark as favorite")
    }

    func testNativeStatePartial_stateRuleCoverage() throws {
        let issues = try runScan(screen: "AccessibleNativeStatePartialViewController")
        let rows = issues.filter { stateRules.contains($0.rule) }
        XCTAssertEqual(rows.count, 7, "Expected seven state rows, got: \(rows.map { "\($0.rule) — \($0.element)" })")
    }

    // MARK: - AccessibleNativeStatePass

    /// The reference tier, and the point of the whole file: with one exception (the spinner,
    /// which has no state of its own) nothing here writes an accessibility value or trait at
    /// all — the real properties are set and UIKit does the announcing. Zero state findings.
    func testNativeStatePass_reportsNoStateRuleAtAll() throws {
        let issues = try runScan(screen: "AccessibleNativeStatePassViewController")
        let rows = issues.filter { stateRules.contains($0.rule) }
        XCTAssertTrue(
            rows.isEmpty,
            "Native State Pass must report none of the four state rules, Fail or Validate, got: \(rows.map { "[\($0.status)] \($0.rule) — \($0.element)" })"
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

    /// Asserts `rule` is the ONLY one of the four state rules reported for this element — the
    /// four outcomes are mutually exclusive per control, so a control reported under two of
    /// them is a routing bug even though each row on its own looks plausible.
    private func assertOnlyRule(
        _ issues: [A11yIssue],
        rule: String,
        elementContaining substring: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for other in stateRules where other != rule {
            assertDoesNotFire(issues, rule: other, elementContaining: substring, file: file, line: line)
        }
    }
}
