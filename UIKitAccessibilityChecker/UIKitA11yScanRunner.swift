//
//  UIKitA11yScanRunner.swift
//  UIKitAccessibilityChecker
//
//  The app's entire accessibility-scan integration: a list of screens, and one call.
//
//  Everything that used to be here — which workflows run, which technique IDs are
//  reported, how one control's findings are recognised as one control's across a dozen
//  scroll positions, which of two overlapping rules wins, how source lines are resolved,
//  and the whole report format — now lives in the framework, where it can be maintained
//  and fixed once for every app that embeds it. This file names screens. That's all.
//
//  Trigger: launch the app with  --a11y-scan
//           add --a11y-screen=<ClassName> to scan a single screen.
//  Results: printed to the Xcode console AND written to
//           ~/Documents/a11y-demo-report.txt
//

import UIKit
import A11yInspect_Accessibility_Framework

enum UIKitA11yScan {

    /// Every example screen, in report order.
    static let screens: [A11yScreen] = [
        // Accessible name
        A11yScreen("Pass", AccessibleNamePassViewController()),
        A11yScreen("Fail", AccessibleNameFailViewController()),
        A11yScreen("Partial", AccessibleNamePartialViewController()),
        A11yScreen("Extras Pass", AccessibleNameExtrasPassViewController()),
        A11yScreen("Extras Fail", AccessibleNameExtrasFailViewController()),
        A11yScreen("Extras Partial", AccessibleNameExtrasPartialViewController()),

        // Role — native controls, then hand-built ones.
        A11yScreen("Native Role Pass", AccessibleNativeRolePassViewController()),
        A11yScreen("Native Role Fail", AccessibleNativeRoleFailViewController()),
        A11yScreen("Native Role Partial", AccessibleNativeRolePartialViewController()),
        A11yScreen("Role Pass", AccessibleRolePassViewController()),
        A11yScreen("Role Fail", AccessibleRoleFailViewController()),
        A11yScreen("Role Partial", AccessibleRolePartialViewController()),

        // State — hand-built controls, then the same ruleset through real UIKit controls.
        A11yScreen("State Pass", AccessibleStatePassViewController()),
        A11yScreen("State Fail", AccessibleStateFailViewController()),
        A11yScreen("State Partial", AccessibleStatePartialViewController()),
        A11yScreen("Native State Pass", AccessibleNativeStatePassViewController()),
        A11yScreen("Native State Fail", AccessibleNativeStateFailViewController()),
        A11yScreen("Native State Partial", AccessibleNativeStatePartialViewController()),

        // Keyboard — per-control focus support, then the screen-level concerns (focus
        // order, grouping, modal traps, the focus ring, Return/Escape, scroll-into-view),
        // then the same ruleset through real UIKit controls.
        A11yScreen("Keyboard Pass", AccessibleKeyboardPassViewController()),
        A11yScreen("Keyboard Fail", AccessibleKeyboardFailViewController()),
        A11yScreen("Keyboard Partial", AccessibleKeyboardPartialViewController()),
        A11yScreen("Keyboard Extras Pass", AccessibleKeyboardExtrasPassViewController()),
        A11yScreen("Keyboard Extras Fail", AccessibleKeyboardExtrasFailViewController()),
        A11yScreen("Keyboard Extras Partial", AccessibleKeyboardExtrasPartialViewController()),
        A11yScreen("Native Keyboard Pass", AccessibleNativeKeyboardPassViewController()),
        A11yScreen("Native Keyboard Fail", AccessibleNativeKeyboardFailViewController()),
        A11yScreen("Native Keyboard Partial", AccessibleNativeKeyboardPartialViewController()),

        // Target size — WCAG 2.5.8: at least 24x24pt, and at least 24pt of clear space
        // from the nearest other interactive control. Either one can fail it.
        A11yScreen("Target Size Pass", AccessibleTargetSizePassViewController()),
        A11yScreen("Target Size Fail", AccessibleTargetSizeFailViewController()),
        A11yScreen("Target Size Partial", AccessibleTargetSizePartialViewController()),

        // Text contrast — WCAG 1.4.3 on SOLID backgrounds, where the ratio is arithmetic
        // on two known colours.
        A11yScreen("Text Contrast Pass", AccessibleTextContrastPassViewController()),
        A11yScreen("Text Contrast Fail", AccessibleTextContrastFailViewController()),
        A11yScreen("Text Contrast Partial", AccessibleTextContrastPartialViewController()),

        // Composited contrast — the harder half of 1.4.3, where neither colour in the
        // comparison is the one written in the source: alpha, stacked translucent layers,
        // blur materials and vibrancy, gradients and images, and the runtime settings
        // (dark mode, Increase Contrast, Dynamic Type) that change the inputs after
        // the fact.
        A11yScreen("Composited Contrast Pass", AccessibleTextContrastCompositedPassViewController()),
        A11yScreen("Composited Contrast Fail", AccessibleTextContrastCompositedFailViewController()),
        A11yScreen("Composited Contrast Partial", AccessibleTextContrastCompositedPartialViewController()),
    ]

    static func runIfRequested() {
        guard A11yInspectScan.isScanRequested else { return }
        Task { @MainActor in
            await A11yInspectScan.shared.run(platform: .uiKit, screens: screens)
        }
    }
}
