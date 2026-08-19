//
//  RoleElementScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  Element-level regression coverage for the two "Role" example screen families
//  (AccessibleRolePass/Fail/Partial and AccessibleNativeRolePass/Fail/Partial) — the
//  UIKit counterpart to the SwiftUI demo app's screens of the same names. Unlike
//  A11yFrameworkScanTests (which only checks that a scan completes), these assert the
//  SPECIFIC rule/element pairing the framework reports for each control on each tier.
//
//  UIKit gesture recognizers are directly introspectable at runtime (no SwiftUI-tree
//  limitation), so AccessibilityTraitsWorkflow now recognizes a hand-built UIView with a
//  live UITapGestureRecognizer/UIPanGestureRecognizer and no (or a mismatched) role,
//  independent of its concrete type — the UIKit equivalent of the SwiftUI app's BB60038/
//  BB60039 findings, without needing a source-level linter:
//    - tap-driven, no role at all           → "Text functions as a button..." (BB40043)
//    - drag-driven, no role at all          → "Missing role for interactive control" (BB60038)
//    - drag-driven, marked with the wrong (discrete) role → "Wrong role for interactive
//      control" (BB60039)
//  Framework/system chrome (UIScrollView's own scroll gesture, a UISwitch's private
//  rendering internals, a compact UIDatePicker's internal view, ...) is excluded via
//  AccessibilityTraitsWorkflow.isAppDefinedOrPlainView / isInsideKnownNativeControl, so
//  only a plain UIView or an app-defined UIView subclass can trigger these.
//
//  Two real gaps remain, called out inline below: no check catches a UILabel/UIImageView
//  wrongly marked .button when it should be .link or hidden entirely (linkLabel,
//  sparkleImageView in AccessibleRoleFailViewController), and Partial-tier's tap-driven
//  controls (Refresh, the filter chip, the shipping rows) don't fire despite looking
//  structurally identical to Fail's — verified directly, root cause not yet understood.
//

import XCTest

final class RoleElementScanTests: XCTestCase {

    // MARK: - AccessibleRolePass — every custom control has the correct role

    func testAccessibleRolePass_noFailures() throws {
        let issues = try runScan(screen: "AccessibleRolePassViewController")
        let fails = issues.filter { $0.status.lowercased() == "fail" }
        XCTAssertTrue(fails.isEmpty, "Role Pass should have zero Fail rows, got: \(fails.map(\.rule))")
    }

    // MARK: - AccessibleRoleFail

    func testAccessibleRoleFail_customButton_missingRole() throws {
        let issues = try runScan(screen: "AccessibleRoleFailViewController")
        // refreshLabel is explicitly marked .staticText despite a real tap gesture.
        assertFires(issues, rule: "Text functions as a button but is missing role button", elementContaining: "Refresh")
    }

    func testAccessibleRoleFail_filterChipAndRadioRows_missingRole() throws {
        let issues = try runScan(screen: "AccessibleRoleFailViewController")
        // filterChipView and the three shippingRowViews are all plain UIViews with a tap
        // gesture, isAccessibilityElement left false, and no traits at all — four distinct
        // controls, all reported the same way since none of them carry an accessible name.
        let fails = issues.filter {
            $0.rule == "Text functions as a button but is missing role button"
                && $0.status.lowercased() == "fail"
                && $0.class == "UIView"
        }
        XCTAssertEqual(fails.count, 4, "Expected the filter chip and 3 shipping rows to each report a missing role, got: \(fails.count)")
    }

    func testAccessibleRoleFail_adjustableDial_wrongRole() throws {
        let issues = try runScan(screen: "AccessibleRoleFailViewController")
        // dialView (PlainDialControl) responds to a UIPanGestureRecognizer (a continuous
        // value) but is marked .button (a discrete action) with no accessibilityIncrement/
        // accessibilityDecrement override — an actively wrong role, not a missing one.
        assertFires(issues, rule: "Wrong role for interactive control", elementContaining: "Brightness")
        assertDoesNotFire(issues, rule: "Missing role for interactive control", elementContaining: "Brightness")
    }

    func testAccessibleRoleFail_knownGaps_notYetDetected() throws {
        let issues = try runScan(screen: "AccessibleRoleFailViewController")
        let fails = issues.filter { $0.status.lowercased() == "fail" }
        // Refresh + filter chip + 3 shipping rows + dial = 6 Fails today. The other two
        // deliberately-broken controls on this screen still produce no Fail at all:
        //   - linkLabel: marked .button instead of .link — no wrong-role check exists for
        //     a discrete-trait mismatch that isn't drag-gesture-based (elementHasLink only
        //     fires for text that literally contains a URL, and "View documentation" doesn't).
        //   - sparkleImageView: explicitly opted into the tree and marked .button despite
        //     being purely decorative, with a real (non-empty) tap action — no check flags
        //     an image wrongly promoted to interactive the way SwiftUI's BB41004 does.
        // This pins the current count so a future fix to either shows up here as a
        // deliberate, visible change rather than silently going unnoticed.
        XCTAssertEqual(fails.count, 6, "Expected exactly 6 currently-detected Fails; got: \(fails.map { "\($0.rule) — \($0.element)" })")
    }

    // MARK: - AccessibleRolePartial

    func testAccessibleRolePartial_adjustableDial_missingRoleIsGeneric() throws {
        let issues = try runScan(screen: "AccessibleRolePartialViewController")
        // No trait at all here (unlike Fail's wrongly-.button dial) — a plain missing role,
        // not an actively wrong one, so this is the generic finding, not "wrong role".
        assertFires(issues, rule: "Missing role for interactive control", elementContaining: "Brightness")
        assertDoesNotFire(issues, rule: "Wrong role for interactive control", elementContaining: "Brightness")
    }

    func testAccessibleRolePartial_tapDrivenControls_knownGap() throws {
        let issues = try runScan(screen: "AccessibleRolePartialViewController")
        let fails = issues.filter { $0.status.lowercased() == "fail" }
        // Surprising: refreshLabel here is set up almost identically to Fail's version
        // (isAccessibilityElement = true, isUserInteractionEnabled = true, a real
        // UITapGestureRecognizer attached) with the ONLY difference being that Fail
        // explicitly sets .staticText while Partial sets no trait at all — yet Fail's
        // Refresh fires "Text functions as a button but is missing role button" and
        // Partial's does not, verified directly (not inferred) across multiple scan runs.
        // Same for the filter chip and shipping rows. Confirmed the framework never even
        // prints/emits the finding for any of Partial's tap-driven controls (not a
        // report-pipeline filtering issue) — the root cause inside AccessibilityTraits-
        // Workflow.validate(element:) is not yet understood. The dial (pan-gesture-driven,
        // above) is unaffected and correctly fires. Pinning this down as exactly 1 (the
        // dial) so a fix is a visible, deliberate change here rather than a silent one.
        XCTAssertEqual(fails.count, 1, "Expected only the dial's Fail today (see comment above); got: \(fails.map { "\($0.rule) — \($0.element)" })")
    }

    // MARK: - AccessibleNativeRolePass — native controls, but missing accessibility labels

    func testAccessibleNativeRolePass_missingNamesOnEveryControl() throws {
        let issues = try runScan(screen: "AccessibleNativeRolePassViewController")
        // Unlike the SwiftUI app's equivalent screen (which gives every control an
        // explicit accessibilityLabel and reports zero Fails), this UIKit screen sets no
        // label on any of its five native controls (notificationsSwitch, volumeSlider,
        // quantityStepper, colorSegmentedControl, agreeSwitch) — its own comment says this
        // is deliberate, since accessible NAMING is a separate concern covered by the
        // AccessibleName* screens. But AccessibilityTraitsWorkflow's missing-name check
        // runs on every screen regardless, so this "Role" screen still reports five real
        // Fails (one per control — there are two distinct UISwitch instances on this
        // screen, notificationsSwitch and agreeSwitch, each missing its own name) as a
        // side effect. Not a role-detection bug — pinned here so the count is a deliberate
        // baseline, not a surprise.
        let missingName = issues.filter {
            $0.rule == "Missing accessible name for interactive control" && $0.status.lowercased() == "fail"
        }
        XCTAssertEqual(missingName.count, 5, "Expected UIStepper/UISegmentedControl/UISlider and both UISwitch controls to each report a missing name, got: \(missingName.map(\.class))")
        // A native UISwitch's own private rendering internals (UISwitchModernVisualElement
        // on newer iOS versions) must never be surfaced as a second, independently-broken
        // control — regression coverage for exactly that false positive.
        assertDoesNotFire(issues, rule: "Missing role for interactive control", elementContaining: "UISwitchModernVisualElement")
    }

    // MARK: - AccessibleNativeRoleFail — hand-drawn clones, now fully caught

    func testAccessibleNativeRoleFail_tapDrivenClones_missingRole() throws {
        let issues = try runScan(screen: "AccessibleNativeRoleFailViewController")
        // SwitchClone and CheckboxClone both use a UITapGestureRecognizer with zero
        // accessibility wiring — the same generic tap-driven fallback that catches
        // AccessibleRoleFailViewController's Refresh label now also catches these.
        let fails = issues.filter {
            $0.rule == "Text functions as a button but is missing role button" && $0.status.lowercased() == "fail"
        }
        XCTAssertEqual(fails.count, 2, "Expected SwitchClone and CheckboxClone to each report a missing role, got: \(fails.map(\.class))")
    }

    func testAccessibleNativeRoleFail_dragDrivenClone_missingRoleIsGeneric() throws {
        let issues = try runScan(screen: "AccessibleNativeRoleFailViewController")
        // SliderClone uses a UIPanGestureRecognizer (continuous) with zero accessibility
        // wiring — "should be a button" would be a wrong guess, so this is the generic
        // finding instead, matching the SwiftUI app's equivalent BB60038 classification.
        // Keyed on class, not element: SliderClone has no accessibilityLabel, so its
        // element name reads as "no name" the same as SwitchClone/CheckboxClone.
        let summary = issues.map { "[\($0.status)] \($0.rule) — \($0.class)" }
        XCTAssertTrue(
            issues.contains { $0.rule == "Missing role for interactive control" && $0.status.lowercased() == "fail" && $0.class == "SliderClone" },
            "Expected SliderClone to report the generic missing-role Fail, got: \(summary)"
        )
        XCTAssertFalse(
            issues.contains { $0.rule == "Text functions as a button but is missing role button" && $0.class == "SliderClone" },
            "Did not expect SliderClone to report the button-specific finding"
        )
    }

    // MARK: - AccessibleNativeRolePartial — buttons/labels present, live-state wiring
    // missing (hardcoded value, no isSelected, no accessibilityValue) for the tap-driven
    // clones — matches the SwiftUI app's equivalent screen, which also reports zero Fails
    // for that class of state-only defect. The drag-driven clone is the one exception.

    func testAccessibleNativeRolePartial_dragDrivenClone_missingAdjustableRole() throws {
        let issues = try runScan(screen: "AccessibleNativeRolePartialViewController")
        // SliderClone has a label and a live accessibilityValue but no .adjustable trait
        // and no accessibilityIncrement/accessibilityDecrement override — unlike the
        // SwiftUI app's equivalent screen, which cannot catch this (its DRAG_WITHOUT_
        // ADJUSTABLE finding's .srcLine() sits on an outer GeometryReader wrapper, not the
        // inner drag-gesture view, so it never matches a live element). UIKit's flat
        // structure has no such disconnect, so this is a case where UIKit now detects more
        // than SwiftUI does.
        assertFires(issues, rule: "Missing role for interactive control", elementContaining: "Volume")
    }

    func testAccessibleNativeRolePartial_tapDrivenClones_stateOnlyDefectsUndetected() throws {
        let issues = try runScan(screen: "AccessibleNativeRolePartialViewController")
        let fails = issues.filter { $0.status.lowercased() == "fail" }
        XCTAssertEqual(fails.count, 1, "Expected only SliderClone's Fail today (state-only defects on SwitchClone/CheckboxClone are an undetected gap, same as the SwiftUI app's equivalent screen), got: \(fails.map { "\($0.rule) — \($0.element)" })")
    }

    // MARK: - Assertion helpers

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
