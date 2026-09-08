//
//  KeyboardElementScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  Scan coverage for the two keyboard screen families added alongside the original
//  AccessibleKeyboard{Pass,Fail,Partial} trio:
//
//    • AccessibleKeyboardExtras{Pass,Fail,Partial} — the keyboard concerns that belong to
//      the SCREEN rather than to any one control: focus order, focus grouping, modal focus
//      traps, the focus ring, Return/Escape behaviour, scroll-into-view, keyboard avoidance,
//      alert dialogs and popovers.
//    • AccessibleNativeKeyboard{Pass,Fail,Partial} — the same concerns exercised through
//      real UIKit controls, plus the presented ones (menu, date picker, colour well, share
//      sheet, navigation push) where the question is whether focus comes back afterwards.
//
//  WHAT THIS FILE CAN AND CANNOT ASSERT TODAY
//
//  The framework has four keyboard-focus rules (BB60046-49, KeyboardFocusableWorkflow,
//  which reads each view's live `canBecomeFocused`). None of them currently produces a row
//  on ANY keyboard screen in this app — including the pre-existing
//  AccessibleKeyboardFailViewController, which reports no failures at all. That is a
//  framework-side gap, not a property of these six screens, and it is why the per-screen
//  tests below assert that the screens scan and produce findings rather than asserting
//  specific keyboard verdicts.
//
//  `testNoKeyboardFocusRuleFiresYet` pins that gap deliberately, in the same style as
//  RoleElementScanTests' own "this tier should have no Fails today" assertion: when the
//  keyboard rules start reporting, this test fails, and turning it into real per-element
//  expectations becomes a visible, intentional change rather than something nobody notices.
//
import XCTest

final class KeyboardElementScanTests: XCTestCase {

    private let cannotFocus = "Interactive control cannot receive keyboard focus"
    private let canFocus = "Interactive control can receive keyboard focus"
    private let mayNotRespond = "Focusable control may not respond to a keyboard Select press"
    private let unverifiable = "SwiftUI control's keyboard-focus reachability cannot be verified automatically"

    private var keyboardRules: [String] { [cannotFocus, canFocus, mayNotRespond, unverifiable] }

    private let extrasScreens = [
        "AccessibleKeyboardExtrasPassViewController",
        "AccessibleKeyboardExtrasFailViewController",
        "AccessibleKeyboardExtrasPartialViewController",
    ]

    private let nativeScreens = [
        "AccessibleNativeKeyboardPassViewController",
        "AccessibleNativeKeyboardFailViewController",
        "AccessibleNativeKeyboardPartialViewController",
    ]

    // MARK: - Every screen is reachable and scannable

    /// The registration test: each screen has to be listed in UIKitA11yScanRunner's
    /// `allUIKitScreenEntries()` for `--a11y-screen=<ClassName>` to find it. A screen that
    /// was added to the project but never registered scans nothing and fails here.
    func testKeyboardExtrasScreens_scanAndReportFindings() throws {
        for screen in extrasScreens {
            let issues = try runScan(screen: screen)
            XCTAssertFalse(issues.isEmpty, "\(screen) produced no findings at all — check it is registered in allUIKitScreenEntries()")
        }
    }

    func testNativeKeyboardScreens_scanAndReportFindings() throws {
        for screen in nativeScreens {
            let issues = try runScan(screen: screen)
            XCTAssertFalse(issues.isEmpty, "\(screen) produced no findings at all — check it is registered in allUIKitScreenEntries()")
        }
    }

    /// Every control these screens declare is `.srcLine()`-tagged, so findings should be
    /// traceable back to the line that built the control.
    ///
    /// Asserted as "some rows carry a line" rather than "all rows do", because a scan also
    /// reaches views the app never created: the internals of a compact UIDatePicker and a
    /// UIColorWell, and the accessory a UITableViewCell builds around a supplied view. Those
    /// are system-provided subviews with no app source line to record, so demanding a tag on
    /// every row would fail for reasons no source edit could fix.
    func testKeyboardScreens_findingsCarrySourceLines() throws {
        for screen in extrasScreens + nativeScreens {
            let issues = try runScan(screen: screen)
            let tagged = issues.filter { $0.element.contains(".swift:") }
            XCTAssertFalse(
                tagged.isEmpty,
                "\(screen) reported \(issues.count) rows and not one carried a source line — .srcLine() tagging is not reaching this screen at all"
            )
        }
    }

    // MARK: - The keyboard ruleset's current reach

    /// Pins the gap described in this file's header: no keyboard-focus rule reports on any
    /// of these six screens yet, even on the Fail tier, which is built entirely out of
    /// controls that cannot be reached or operated by keyboard. When
    /// KeyboardFocusableWorkflow starts producing rows here, this test fails on purpose —
    /// replace it with per-element expectations at that point.
    func testNoKeyboardFocusRuleFiresYet() throws {
        var seen: [String] = []
        for screen in extrasScreens + nativeScreens {
            let issues = try runScan(screen: screen)
            seen += issues.filter { keyboardRules.contains($0.rule) }
                .map { "\(screen): [\($0.status)] \($0.rule) — \($0.element)" }
        }
        XCTAssertTrue(
            seen.isEmpty,
            """
            A keyboard-focus rule now reports on these screens. That is an improvement, not a \
            regression — replace this test with real per-element assertions for: \(seen)
            """
        )
    }

    // MARK: - Fail tiers are meaningfully worse than Pass tiers

    /// Whatever the ruleset is currently able to see, the deliberately-broken screens should
    /// not come out cleaner than the reference ones. This holds the tiers in the right order
    /// without depending on which specific rules happen to be firing.
    func testFailTiersReportAtLeastAsManyFailuresAsPassTiers() throws {
        func failureCount(_ screen: String) throws -> Int {
            try runScan(screen: screen).filter { $0.status.lowercased() == "fail" }.count
        }

        let extrasPass = try failureCount("AccessibleKeyboardExtrasPassViewController")
        let extrasFail = try failureCount("AccessibleKeyboardExtrasFailViewController")
        XCTAssertGreaterThanOrEqual(extrasFail, extrasPass,
                                    "Keyboard Extras Fail (\(extrasFail)) should not report fewer failures than Pass (\(extrasPass))")

        let nativePass = try failureCount("AccessibleNativeKeyboardPassViewController")
        let nativeFail = try failureCount("AccessibleNativeKeyboardFailViewController")
        XCTAssertGreaterThanOrEqual(nativeFail, nativePass,
                                    "Native Keyboard Fail (\(nativeFail)) should not report fewer failures than Pass (\(nativePass))")
    }
}
