//
//  KeyboardElementScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  Scan coverage for the keyboard screens:
//
//    • AccessibleKeyboard{Pass,Fail,Partial} — custom chip controls, where the question is
//      whether a Space/Return press has anything to trigger.
//    • AccessibleKeyboardExtras{Pass,Fail,Partial} — the keyboard concerns that belong to
//      the SCREEN rather than to any one control: focus order, focus grouping, modal focus
//      traps, the focus ring, Return/Escape behaviour, scroll-into-view, keyboard avoidance,
//      alert dialogs and popovers.
//    • AccessibleNativeKeyboard{Pass,Fail,Partial} — the same concerns exercised through
//      real UIKit controls.
//
//  WHAT THESE TESTS ASSERT
//
//  The framework's keyboard surface is six rules (KeyboardFocusableWorkflow), and this file
//  asserts against their report titles rather than their BB IDs, because the title is what a
//  reader of the report sees.
//
//  The earlier version of this file pinned a gap instead: "no keyboard-focus rule fires on
//  any of these screens yet". That gap is closed — the rules now report, so the pin is
//  replaced by the real per-tier expectations below.
//
//  The central assertion is `testReferenceScreensHaveNoUnreachableOrInoperableControl`: the
//  Pass tiers are built out of correctly-wired native controls, so not one of the four
//  reachability/operability rules may name them. That is the assertion that would catch the
//  scan regressing into false positives — which is exactly how the UISegment and scrolled-
//  out-UISlider defects were found.
//
import XCTest

final class KeyboardElementScanTests: XCTestCase {

    // The six keyboard rules, by the title the report prints.
    private let buttonInoperable = "Button not operable with keyboard"
    private let linkInoperable = "Link not keyboard operable"
    private let controlUnreachable = "Interactive control cannot receive keyboard focus"
    private let controlInoperable = "Interactive control not operable with keyboard"
    private let nonInteractiveFocusable = "Non-interactive element receives keyboard focus"
    private let hiddenFocusable = "Hidden content receives keyboard focus"

    /// The four rules that name a control a keyboard user cannot reach or cannot operate.
    /// Deliberately excludes `hiddenFocusable`, which fires on any control scrolled below the
    /// fold of a tall screen and so says nothing about whether the screen is well built.
    private var reachabilityRules: [String] {
        [buttonInoperable, linkInoperable, controlUnreachable, controlInoperable]
    }

    private var allKeyboardRules: [String] {
        reachabilityRules + [nonInteractiveFocusable, hiddenFocusable]
    }

    /// Titles from the retired BB60046-49 set. They must never appear again: the rows were
    /// deleted from the database, so a scan that still prints one means a stale framework
    /// binary is linked.
    private let retiredRules = [
        "Interactive control can receive keyboard focus",
        "Focusable control may not respond to a keyboard Select press",
        "SwiftUI control's keyboard-focus reachability cannot be verified automatically",
        "Interactive view uses gesture-only interaction with no accessibility alternative",
        "Interactive view has an accessibility alternative for gesture interaction",
    ]

    private let chipScreens = [
        "AccessibleKeyboardPassViewController",
        "AccessibleKeyboardFailViewController",
        "AccessibleKeyboardPartialViewController",
    ]

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

    private var allScreens: [String] { chipScreens + extrasScreens + nativeScreens }

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

    // MARK: - The reference tiers must come out clean

    /// The Pass screens are built entirely out of correctly-wired native controls — a
    /// UISwitch, a UISlider, a UITextField, a UISegmentedControl, real UIButtons. Not one of
    /// them may be named as unreachable or inoperable.
    ///
    /// This is the false-positive guard for the whole keyboard ruleset. Two real defects were
    /// caught by exactly this assertion: every segment of a working UISegmentedControl being
    /// reported as an unoperable button (the scan was walking into UIKit's private UISegment
    /// views), and a working UISlider being reported as unreachable because it happened to be
    /// scrolled out of view when the scan paused.
    func testReferenceScreensHaveNoUnreachableOrInoperableControl() throws {
        for screen in ["AccessibleKeyboardPassViewController",
                       "AccessibleKeyboardExtrasPassViewController",
                       "AccessibleNativeKeyboardPassViewController"] {
            let offenders = try runScan(screen: screen)
                .filter { reachabilityRules.contains($0.rule) }
                .map { "[\($0.rule)] \($0.class) — \($0.element)" }

            XCTAssertTrue(
                offenders.isEmpty,
                """
                \(screen) is a reference screen of correctly-wired controls, so no keyboard \
                reachability or operability rule should name anything on it. Reported: \(offenders)
                """
            )
        }
    }

    // MARK: - The Fail tiers must actually report

    /// The custom chips on the Fail tier carry a `.button` trait and a tap gesture, and
    /// nothing a keyboard Select press can call — the textbook BB41035 shape.
    func testChipFailScreen_reportsInoperableButtons() throws {
        let rows = try runScan(screen: "AccessibleKeyboardFailViewController")
            .filter { $0.rule == buttonInoperable }

        XCTAssertFalse(
            rows.isEmpty,
            "The Fail chips are tap-gesture-only with a button trait — that is 'Button not operable with keyboard'."
        )
    }

    /// The native Fail screen breaks real controls, so both halves of the rule set should
    /// show up: a control the focus engine will not take, and a control-shaped thing whose
    /// Select press has nothing to trigger.
    func testNativeFailScreen_reportsUnreachableControls() throws {
        let rules = Set(try runScan(screen: "AccessibleNativeKeyboardFailViewController").map(\.rule))

        XCTAssertTrue(
            rules.contains(controlUnreachable) || rules.contains(controlInoperable),
            "The native Fail screen should name at least one control as unreachable or inoperable. Saw: \(rules.sorted())"
        )
    }

    /// Ordering rather than absolute counts: the deliberately-broken tiers must not come out
    /// cleaner than the reference ones on the rules that describe a real keyboard barrier.
    func testFailTiersOutrankPassTiersOnReachability() throws {
        func barrierCount(_ screen: String) throws -> Int {
            try runScan(screen: screen).filter { reachabilityRules.contains($0.rule) }.count
        }

        for (pass, fail) in [("AccessibleKeyboardPassViewController",
                              "AccessibleKeyboardFailViewController"),
                             ("AccessibleNativeKeyboardPassViewController",
                              "AccessibleNativeKeyboardFailViewController")] {
            let passCount = try barrierCount(pass)
            let failCount = try barrierCount(fail)
            XCTAssertGreaterThan(
                failCount, passCount,
                "\(fail) (\(failCount)) should report more keyboard barriers than \(pass) (\(passCount))"
            )
        }
    }

    // MARK: - The ruleset is exactly the six rules

    /// No keyboard row may carry a title outside the six, and none of the retired titles may
    /// come back. A retired title reappearing means the app is linked against a stale
    /// framework binary rather than a rebuilt one.
    func testOnlyTheSixKeyboardRulesAreReported() throws {
        for screen in allScreens {
            for issue in try runScan(screen: screen, includePasses: true) {
                XCTAssertFalse(
                    retiredRules.contains(issue.rule),
                    "\(screen) reported retired keyboard rule '\(issue.rule)' — the linked framework binary is stale"
                )
                if issue.rule.lowercased().contains("keyboard focus")
                    || issue.rule.lowercased().contains("operable with keyboard") {
                    XCTAssertTrue(
                        allKeyboardRules.contains(issue.rule),
                        "\(screen) reported an unexpected keyboard rule: '\(issue.rule)'"
                    )
                }
            }
        }
    }
}
