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
        A11yScreen("Keyboard Link Pass", AccessibleKeyboardLinkPassViewController()),
        A11yScreen("Keyboard Link Fail", AccessibleKeyboardLinkFailViewController()),
        A11yScreen("Keyboard Link Partial", AccessibleKeyboardLinkPartialViewController()),
        A11yScreen("Native Keyboard Pass", AccessibleNativeKeyboardPassViewController()),
        A11yScreen("Native Keyboard Fail", AccessibleNativeKeyboardFailViewController()),
        A11yScreen("Native Keyboard Partial", AccessibleNativeKeyboardPartialViewController()),

        // Target size
        A11yScreen("Target Size Pass", AccessibleTargetSizePassViewController()),
        A11yScreen("Target Size Fail", AccessibleTargetSizeFailViewController()),
        A11yScreen("Target Size Partial", AccessibleTargetSizePartialViewController()),

        // Hidden from screen reader — controls VoiceOver cannot reach (Fail) and content it
        // skips that a person should confirm is meant to be skipped (Validate).
        A11yScreen("Hidden Pass", AccessibleHiddenPassViewController()),
        A11yScreen("Hidden Fail", AccessibleHiddenFailViewController()),
        A11yScreen("Hidden Partial", AccessibleHiddenPartialViewController()),

        // Language — whether the app has one, and whether each piece of text declares a
        // language that agrees with the text and the app.
        A11yScreen("Language Pass", AccessibleLanguagePassViewController()),
        A11yScreen("Language Fail", AccessibleLanguageFailViewController()),
        A11yScreen("Language Partial", AccessibleLanguagePartialViewController()),

        // Motion — a shake-handled action needs an on-screen alternative control.
        A11yScreen("Motion Pass", AccessibleMotionPassViewController()),
        A11yScreen("Motion Fail", AccessibleMotionFailViewController()),
        A11yScreen("Motion Partial", AccessibleMotionPartialViewController()),

        // Images — the text alternative of each picture exposed to VoiceOver.
        A11yScreen("Images Pass", AccessibleImagesPassViewController()),
        A11yScreen("Images Fail", AccessibleImagesFailViewController()),
        A11yScreen("Images Partial", AccessibleImagesPartialViewController()),

        // Reading order — whether the order VoiceOver is told to follow matches the layout.
        A11yScreen("Reading Order Pass", AccessibleReadingOrderPassViewController()),
        A11yScreen("Reading Order Fail", AccessibleReadingOrderFailViewController()),
        A11yScreen("Reading Order Partial", AccessibleReadingOrderPartialViewController()),

        // Focus indicator — the ring a control draws: its contrast, and whether it is more than
        // a colour.
        A11yScreen("Focus Pass", AccessibleFocusPassViewController()),
        A11yScreen("Focus Fail", AccessibleFocusFailViewController()),
        A11yScreen("Focus Partial", AccessibleFocusPartialViewController()),

        // Links — an inline link set apart from its text by more than colour.
        A11yScreen("Link Pass", AccessibleLinkPassViewController()),
        A11yScreen("Link Fail", AccessibleLinkFailViewController()),
        A11yScreen("Link Partial", AccessibleLinkPartialViewController()),

        // Role trait — a native control keeps the role UIKit gives it (BB40274 / BB40275).
        A11yScreen("Role Trait Pass", AccessibleRoleTraitPassViewController()),
        A11yScreen("Role Trait Partial", AccessibleRoleTraitPartialViewController()),
        A11yScreen("Role Trait Fail", AccessibleRoleTraitFailViewController()),

        // State trait — the state a control announces matches its real state (BB40277).
        A11yScreen("State Trait Pass", AccessibleStateTraitPassViewController()),
        A11yScreen("State Trait Partial", AccessibleStateTraitPartialViewController()),
        A11yScreen("State Trait Fail", AccessibleStateTraitFailViewController()),

        // Button — pressable, reachable, and says when it is disabled (BB40001 / BB40079).
        A11yScreen("Button Pass", AccessibleButtonPassViewController()),
        A11yScreen("Button Partial", AccessibleButtonPartialViewController()),
        A11yScreen("Button Fail", AccessibleButtonFailViewController()),

        // Form label — a field is not named by its placeholder alone (BB40034).
        A11yScreen("Form Label Pass", AccessibleFormLabelPassViewController()),
        A11yScreen("Form Label Partial", AccessibleFormLabelPartialViewController()),
        A11yScreen("Form Label Fail", AccessibleFormLabelFailViewController()),

        // Custom action — a complex gesture has an accessible alternative (BB40190 / BB40191).
        A11yScreen("Custom Action Pass", AccessibleCustomActionPassViewController()),
        A11yScreen("Custom Action Partial", AccessibleCustomActionPartialViewController()),
        A11yScreen("Custom Action Fail", AccessibleCustomActionFailViewController()),

        // Touch event — an action fires on release, not on touch down (BB40136 / BB40137).
        A11yScreen("Touch Event Pass", AccessibleTouchEventPassViewController()),
        A11yScreen("Touch Event Partial", AccessibleTouchEventPartialViewController()),
        A11yScreen("Touch Event Fail", AccessibleTouchEventFailViewController()),

        // Error message — an error under a field reaches VoiceOver (BB40095).
        A11yScreen("Error message Pass", AccessibleErrorMessagePassViewController()),
        A11yScreen("Error message Partial", AccessibleErrorMessagePartialViewController()),
        A11yScreen("Error message Fail", AccessibleErrorMessageFailViewController()),

        // Non-text contrast — borders, indicators and control colours reach 3:1 (BB40060 / BB40062 / BB40064).
        A11yScreen("Non-text contrast Pass", AccessibleNonTextContrastPassViewController()),
        A11yScreen("Non-text contrast Partial", AccessibleNonTextContrastPartialViewController()),
        A11yScreen("Non-text contrast Fail", AccessibleNonTextContrastFailViewController()),

        // Focus obscured — a banner does not hide a focusable control (BB40075).
        A11yScreen("Focus obscured Pass", AccessibleFocusObscuredPassViewController()),
        A11yScreen("Focus obscured Partial", AccessibleFocusObscuredPartialViewController()),
        A11yScreen("Focus obscured Fail", AccessibleFocusObscuredFailViewController()),

        // Modal — a dialog has controls and a way out (BB40244 / BB40115).
        A11yScreen("Modal Pass", AccessibleModalPassViewController()),
        A11yScreen("Modal Partial", AccessibleModalPartialViewController()),
        A11yScreen("Modal Fail", AccessibleModalFailViewController()),

        // Tab control — a tab bar stays reachable (BB40036).
        A11yScreen("Tab control Pass", AccessibleTabControlPassViewController()),
        A11yScreen("Tab control Partial", AccessibleTabControlPartialViewController()),
        A11yScreen("Tab control Fail", AccessibleTabControlFailViewController()),

        // Screen title — a screen declares a title (BB40099).
        A11yScreen("Screen title Pass", AccessibleScreenTitlePassViewController()),
        A11yScreen("Screen title Partial", AccessibleScreenTitlePartialViewController()),
        A11yScreen("Screen title Fail", AccessibleScreenTitleFailViewController()),

        // Gesture keyboard — (BB40071 / BB40072).
        A11yScreen("Orientation Pass", AccessibleOrientationPassViewController()),
        A11yScreen("Orientation Fail", AccessibleOrientationFailViewController()),
        A11yScreen("Orientation Partial", AccessibleOrientationPartialViewController()),
        A11yScreen("Gesture keyboard Pass", AccessibleGestureKeyboardPassViewController()),
        A11yScreen("Gesture keyboard Partial", AccessibleGestureKeyboardPartialViewController()),
        A11yScreen("Gesture keyboard Fail", AccessibleGestureKeyboardFailViewController()),

        // Autocomplete — (BB40091 / BB40092).
        A11yScreen("Autocomplete Pass", AccessibleAutocompletePassViewController()),
        A11yScreen("Autocomplete Partial", AccessibleAutocompletePartialViewController()),
        A11yScreen("Autocomplete Fail", AccessibleAutocompleteFailViewController()),

        // Modal close — (BB40114 / BB40115).
        A11yScreen("Modal close Pass", AccessibleModalClosePassViewController()),
        A11yScreen("Modal close Partial", AccessibleModalClosePartialViewController()),
        A11yScreen("Modal close Fail", AccessibleModalCloseFailViewController()),

        // Language change — (BB40107).
        A11yScreen("Language change Pass", AccessibleLanguageChangePassViewController()),
        A11yScreen("Language change Partial", AccessibleLanguageChangePartialViewController()),
        A11yScreen("Language change Fail", AccessibleLanguageChangeFailViewController()),

        // Focus order — (BB40053 / BB40054).
        A11yScreen("Focus order Pass", AccessibleFocusOrderPassViewController()),
        A11yScreen("Focus order Partial", AccessibleFocusOrderPartialViewController()),
        A11yScreen("Focus order Fail", AccessibleFocusOrderFailViewController()),

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
