import XCTest

/// Element-level regression coverage for the three custom-control State screens, mirroring
/// RoleElementScanTests.swift's assertFires/assertDoesNotFire pattern. The native-control
/// State screens are covered separately in NativeStateElementScanTests.swift.
///
/// Every control on Fail and Partial reports exactly one of the four state rules, and every
/// control on Pass reports none. Each test names the control it is about and asserts the
/// other three rules do NOT fire on it, so a finding drifting between outcomes (or quietly
/// disappearing) fails loudly rather than hiding inside a total count.
///
/// Sibling groups built in a loop — the radio rows, the segmented strip, the multi-select
/// rows — share one `.srcLine()` tag but are three separate live elements, so each of them
/// reports its own row. That is why the per-screen totals below are larger than the ten
/// controls each screen has.
final class StateElementScanTests: XCTestCase {

    private let missing = "Missing state information for interactive control"
    private let incorrect = "Incorrect State value provided for interactive control"
    private let notUpdated = "State does not get updated on user interaction"
    private let verifyUpdates = "Verify if the state for interactive control gets updated on user interaction"

    private var stateRules: [String] { [missing, incorrect, notUpdated, verifyUpdates] }

    // MARK: - AccessibleStateFail — state present but wrong

    /// `accessibilityValue = isOn ? "Off" : "On"` in both init and toggle(): it updates every
    /// time, just with the branches swapped.
    func testStateFail_customSwitch_valueIsInverted() throws {
        let issues = try runScan(screen: "AccessibleStateFailViewController")
        assertFires(issues, rule: incorrect, elementContaining: "Enable notifications")
        assertOnlyRule(issues, rule: incorrect, elementContaining: "Enable notifications")
    }

    /// `accessibilityValue = "Checked"` set once in init and never touched again in toggle().
    func testStateFail_customCheckbox_valueNeverRefreshed() throws {
        let issues = try runScan(screen: "AccessibleStateFailViewController")
        assertFires(issues, rule: notUpdated, elementContaining: "I agree to the Terms of Service")
        assertOnlyRule(issues, rule: notUpdated, elementContaining: "I agree to the Terms of Service")
    }

    func testStateFail_filterChip_neitherTraitNorValueRefreshed() throws {
        let issues = try runScan(screen: "AccessibleStateFailViewController")
        assertFires(issues, rule: notUpdated, elementContaining: "Wi-Fi Only")
        assertOnlyRule(issues, rule: notUpdated, elementContaining: "Wi-Fi Only")
    }

    func testStateFail_disclosureRow_alwaysReportsCollapsed() throws {
        let issues = try runScan(screen: "AccessibleStateFailViewController")
        assertFires(issues, rule: notUpdated, elementContaining: "Shipping details")
        assertOnlyRule(issues, rule: notUpdated, elementContaining: "Shipping details")
    }

    /// `isEnabled = true` alongside a hand-written `.notEnabled` trait: a working button
    /// announced as dimmed, so VoiceOver users skip a control that does real work.
    func testStateFail_saveDraftButton_notEnabledTraitContradictsIsEnabled() throws {
        let issues = try runScan(screen: "AccessibleStateFailViewController")
        assertFires(issues, rule: incorrect, elementContaining: "Save draft")
        assertOnlyRule(issues, rule: incorrect, elementContaining: "Save draft")
    }

    /// `.adjustable` with `accessibilityValue = "5 out of 5 stars"` frozen at the maximum, and
    /// no increment/decrement override to make the advertised swipe gesture do anything.
    func testStateFail_starRating_adjustableWithAFrozenValue() throws {
        let issues = try runScan(screen: "AccessibleStateFailViewController")
        assertFires(issues, rule: incorrect, elementContaining: "Rating")
        assertOnlyRule(issues, rule: incorrect, elementContaining: "Rating")
    }

    /// `.selected` unioned onto every row of a single-choice group, so all three shipping
    /// options announce themselves as chosen at once.
    func testStateFail_radioGroup_everyRowClaimsToBeSelected() throws {
        let issues = try runScan(screen: "AccessibleStateFailViewController")
        for option in ["Standard (5-7 days)", "Express (2-3 days)", "Overnight"] {
            assertFires(issues, rule: incorrect, elementContaining: option)
            assertOnlyRule(issues, rule: incorrect, elementContaining: option)
        }
    }

    /// Same defect in the segmented strip: `.selected` on all three buttons unconditionally.
    func testStateFail_segmentedStrip_everySegmentClaimsToBeSelected() throws {
        let issues = try runScan(screen: "AccessibleStateFailViewController")
        for segment in ["Red", "Green", "Blue"] {
            assertFires(issues, rule: incorrect, elementContaining: segment)
            assertOnlyRule(issues, rule: incorrect, elementContaining: segment)
        }
    }

    /// The multi-select rows are built with `isAccessibilityElement = false`, so they never
    /// become elements with a name — the selection state has nowhere to live and splinters
    /// into an unlabeled checkmark image. They report as "no name" for exactly that reason.
    func testStateFail_multiSelectRows_areExcludedFromTheTree() throws {
        let issues = try runScan(screen: "AccessibleStateFailViewController")
        let unnamed = issues.filter { stateRules.contains($0.rule) && $0.element.hasPrefix("no name") }
        XCTAssertEqual(unnamed.count, 3, "Expected all three multi-select rows to report, got: \(unnamed.map(\.element))")
        XCTAssertEqual(Set(unnamed.map(\.rule)), [missing], "Rows removed from the tree report missing state")
    }

    func testStateFail_stateRuleCoverage() throws {
        let issues = try runScan(screen: "AccessibleStateFailViewController")
        let rows = issues.filter { stateRules.contains($0.rule) }
        XCTAssertEqual(rows.count, 15, "Expected fifteen state rows, got: \(rows.map { "\($0.rule) — \($0.element)" })")
    }

    // MARK: - AccessibleStatePartial — state absent or stale

    func testStatePartial_customSwitch_valueSetOnceNeverRefreshed() throws {
        let issues = try runScan(screen: "AccessibleStatePartialViewController")
        assertFires(issues, rule: notUpdated, elementContaining: "Enable notifications")
        assertOnlyRule(issues, rule: notUpdated, elementContaining: "Enable notifications")
    }

    func testStatePartial_customCheckbox_hasNoValueAtAll() throws {
        let issues = try runScan(screen: "AccessibleStatePartialViewController")
        assertFires(issues, rule: missing, elementContaining: "I agree to the Terms of Service")
        assertOnlyRule(issues, rule: missing, elementContaining: "I agree to the Terms of Service")
    }

    /// The one Validate row on this screen: the chip's update really does happen, two levels
    /// of helper calls deep (toggle → applyState → refreshAccessibility), one level past what
    /// the scan follows — so it asks for a human instead of asserting a defect.
    func testStatePartial_filterChip_asksForManualVerification() throws {
        let issues = try runScan(screen: "AccessibleStatePartialViewController")
        let rows = issues.filter { $0.rule == verifyUpdates && $0.element.contains("Wi-Fi Only") }
        XCTAssertFalse(rows.isEmpty, "Expected a Validate row for the filter chip, got: \(issues.filter { stateRules.contains($0.rule) }.map(\.element))")
        XCTAssertTrue(
            rows.allSatisfy { $0.status.lowercased() == "validate" },
            "The chip's finding must be Validate, not Fail — its update path is unverifiable, not absent"
        )
        assertDoesNotFire(issues, rule: missing, elementContaining: "Wi-Fi Only")
        assertDoesNotFire(issues, rule: incorrect, elementContaining: "Wi-Fi Only")
        assertDoesNotFire(issues, rule: notUpdated, elementContaining: "Wi-Fi Only")
    }

    func testStatePartial_favoriteToggle_hasNoValueOrSelectedTrait() throws {
        let issues = try runScan(screen: "AccessibleStatePartialViewController")
        assertFires(issues, rule: missing, elementContaining: "Favorite")
        assertOnlyRule(issues, rule: missing, elementContaining: "Favorite")
    }

    func testStatePartial_disclosureRow_neverReportsExpandedOrCollapsed() throws {
        let issues = try runScan(screen: "AccessibleStatePartialViewController")
        assertFires(issues, rule: missing, elementContaining: "Shipping details")
        assertOnlyRule(issues, rule: missing, elementContaining: "Shipping details")
    }

    /// `.adjustable` trait with no value at all: the swipe gesture is advertised and the
    /// current rating is never announced.
    func testStatePartial_starRating_adjustableWithNoValue() throws {
        let issues = try runScan(screen: "AccessibleStatePartialViewController")
        assertFires(issues, rule: missing, elementContaining: "Rating")
        assertOnlyRule(issues, rule: missing, elementContaining: "Rating")
    }

    func testStatePartial_selectionGroups_neverCarrySelected() throws {
        let issues = try runScan(screen: "AccessibleStatePartialViewController")
        let groups = [
            ["Standard (5-7 days)", "Express (2-3 days)", "Overnight"],  // radio rows
            ["Red", "Green", "Blue"],                                    // segmented strip
            ["Work", "Personal", "Urgent"],                              // multi-select rows
        ]
        for group in groups {
            for option in group {
                assertFires(issues, rule: missing, elementContaining: option)
                assertOnlyRule(issues, rule: missing, elementContaining: option)
            }
        }
    }

    func testStatePartial_stateRuleCoverage() throws {
        let issues = try runScan(screen: "AccessibleStatePartialViewController")
        let rows = issues.filter { stateRules.contains($0.rule) }
        XCTAssertEqual(rows.count, 15, "Expected fifteen state rows, got: \(rows.map { "\($0.rule) — \($0.element)" })")
        XCTAssertEqual(rows.filter { $0.status.lowercased() == "validate" }.count, 1,
                       "Exactly one control (the filter chip) should be Validate rather than Fail")
    }

    // MARK: - AccessibleStatePass

    /// The reference tier: each control updates its accessibility state in the same code path
    /// that changes its appearance, so none of the four rules has anything to say.
    func testStatePass_reportsNoStateRuleAtAll() throws {
        let issues = try runScan(screen: "AccessibleStatePassViewController")
        let rows = issues.filter { stateRules.contains($0.rule) }
        XCTAssertTrue(
            rows.isEmpty,
            "State Pass must report none of the four state rules, Fail or Validate, got: \(rows.map { "[\($0.status)] \($0.rule) — \($0.element)" })"
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

    /// Asserts `rule` is the ONLY one of the four state rules reported for this element. The
    /// four outcomes are mutually exclusive per control, so a control reported as both
    /// "missing" and "not updated" is a routing bug even though each row looks plausible.
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
