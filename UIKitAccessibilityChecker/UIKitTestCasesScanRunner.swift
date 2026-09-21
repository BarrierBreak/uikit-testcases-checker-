//
//  UIKitTestCasesScanRunner.swift
//  UIKitAccessibilityChecker
//
//  Drives a scan through A11yInspectTestCases — the standalone test framework — alongside the
//  the app.
//
//  This is the app's only scan runner: A11yInspect_Accessibility_Framework has been removed
//  from the project, and A11yInspectTestCases replaces it wholesale. It carries the same
//  rules, the same scan engine and the same reporter, plus the per-family narrowing below.
//

import UIKit
import A11yInspectTestCases

enum UIKitTestCasesScan {

    /// Narrows the scan to one rule family, via `--a11y-testcases-family=<name>`.
    ///
    /// This is what makes a per-family XCTest readable: a keyboard test asks for the keyboard
    /// family and gets a report with nothing else in it, instead of filtering forty rules'
    /// worth of rows down to six in the assertion. Omitting the argument scans everything,
    /// which is the default a plain run wants.
    static let familyArgument = "--a11y-testcases-family="

    static var requestedFamily: String? {
        guard let arg = CommandLine.arguments.first(where: { $0.hasPrefix(familyArgument) }) else {
            return nil
        }
        return String(arg.dropFirst(familyArgument.count))
    }

    /// Every example screen, in report order — the same catalogue the original runner scans,
    /// so the two frameworks can be compared on identical input.
    static let screens: [A11yScreen] = [
        // Accessible name
        A11yScreen("Pass", AccessibleNamePassViewController()),
        A11yScreen("Fail", AccessibleNameFailViewController()),
        A11yScreen("Partial", AccessibleNamePartialViewController()),
        A11yScreen("Extras Pass", AccessibleNameExtrasPassViewController()),
        A11yScreen("Extras Fail", AccessibleNameExtrasFailViewController()),
        A11yScreen("Extras Partial", AccessibleNameExtrasPartialViewController()),

        // Role
        A11yScreen("Native Role Pass", AccessibleNativeRolePassViewController()),
        A11yScreen("Native Role Fail", AccessibleNativeRoleFailViewController()),
        A11yScreen("Native Role Partial", AccessibleNativeRolePartialViewController()),
        A11yScreen("Role Pass", AccessibleRolePassViewController()),
        A11yScreen("Role Fail", AccessibleRoleFailViewController()),
        A11yScreen("Role Partial", AccessibleRolePartialViewController()),

        // State
        A11yScreen("State Pass", AccessibleStatePassViewController()),
        A11yScreen("State Fail", AccessibleStateFailViewController()),
        A11yScreen("State Partial", AccessibleStatePartialViewController()),
        A11yScreen("Native State Pass", AccessibleNativeStatePassViewController()),
        A11yScreen("Native State Fail", AccessibleNativeStateFailViewController()),
        A11yScreen("Native State Partial", AccessibleNativeStatePartialViewController()),

        // Keyboard
        A11yScreen("Keyboard Pass", AccessibleKeyboardPassViewController()),
        A11yScreen("Keyboard Fail", AccessibleKeyboardFailViewController()),
        A11yScreen("Keyboard Partial", AccessibleKeyboardPartialViewController()),
        A11yScreen("Keyboard Extras Pass", AccessibleKeyboardExtrasPassViewController()),
        A11yScreen("Keyboard Extras Fail", AccessibleKeyboardExtrasFailViewController()),
        A11yScreen("Keyboard Extras Partial", AccessibleKeyboardExtrasPartialViewController()),
        A11yScreen("Native Keyboard Pass", AccessibleNativeKeyboardPassViewController()),
        A11yScreen("Native Keyboard Fail", AccessibleNativeKeyboardFailViewController()),
        A11yScreen("Native Keyboard Partial", AccessibleNativeKeyboardPartialViewController()),

        // Target size
        A11yScreen("Target Size Pass", AccessibleTargetSizePassViewController()),
        A11yScreen("Target Size Fail", AccessibleTargetSizeFailViewController()),
        A11yScreen("Target Size Partial", AccessibleTargetSizePartialViewController()),

        // Resize text and text clipping — WCAG 1.4.4, the two halves of "can this be read
        // at the reader's chosen size": whether the label opts into Dynamic Type at all, and
        // whether what it draws still fits once it has.
        A11yScreen("Text Resize Pass", AccessibleTextResizePassViewController()),
        A11yScreen("Text Resize Fail", AccessibleTextResizeFailViewController()),
        A11yScreen("Text Resize Partial", AccessibleTextResizePartialViewController()),
        A11yScreen("Text Clipping Pass", AccessibleTextClippingPassViewController()),
        A11yScreen("Text Clipping Fail", AccessibleTextClippingFailViewController()),
        A11yScreen("Text Clipping Partial", AccessibleTextClippingPartialViewController()),

        // Colour contrast
        A11yScreen("Text Contrast Pass", AccessibleTextContrastPassViewController()),
        A11yScreen("Text Contrast Fail", AccessibleTextContrastFailViewController()),
        A11yScreen("Text Contrast Partial", AccessibleTextContrastPartialViewController()),
        A11yScreen("Composited Contrast Pass", AccessibleTextContrastCompositedPassViewController()),
        A11yScreen("Composited Contrast Fail", AccessibleTextContrastCompositedFailViewController()),
        A11yScreen("Composited Contrast Partial", AccessibleTextContrastCompositedPartialViewController()),
    ]

    static func runIfRequested() {
        guard A11yInspectScan.isScanRequested else { return }

        // An unknown family name falls back to the full set rather than scanning nothing: a
        // report of zero rows and a report the argument never reached look identical from a
        // test, and the first is the one that wastes an afternoon.
        var rules: Set<String>?
        if let family = requestedFamily {
            rules = A11yRuleSet.rules(for: family, platform: .uiKit)
            if rules == nil {
                print("[A11yInspectTestCases] ⚠️ \(familyArgument)\(family) matched no family; scanning all rules instead.")
            }
        }

        Task { @MainActor in
            await A11yInspectScan.shared.run(platform: .uiKit, rules: rules, screens: screens)
        }
    }
}
