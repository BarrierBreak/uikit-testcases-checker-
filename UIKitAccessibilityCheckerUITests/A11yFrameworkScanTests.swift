//
//  A11yFrameworkScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  One test function per example screen, each named after that screen's class, so a
//  single screen can be scanned on its own — put the caret in the function and press
//  ⌃⌘U, or click the diamond next to it in the Test navigator. Running the whole class
//  runs each screen as its own test, plus testAllScreens() for the combined report.
//
//  Each function launches the app with --a11y-scan and --a11y-screen=<ClassName>, waits
//  for the framework to finish, then attaches the report to the test result (Report
//  Navigator → the test → "A11y Demo Scan Report"). The report is also written to
//  ~/Documents/a11y-demo-report.txt in the simulator container.
//
//  XCTest only discovers methods whose name begins with "test", so each function is the
//  screen's class name with that prefix.
//

import XCTest

final class A11yDemoScanTests: XCTestCase {

    // MARK: - One function per screen

    func testAccessibleNamePassViewController() throws {
        try runScan(screen: "AccessibleNamePassViewController")
    }

    func testAccessibleNameFailViewController() throws {
        try runScan(screen: "AccessibleNameFailViewController")
    }

    func testAccessibleNamePartialViewController() throws {
        try runScan(screen: "AccessibleNamePartialViewController")
    }

    func testAccessibleNameExtrasPassViewController() throws {
        try runScan(screen: "AccessibleNameExtrasPassViewController")
    }

    func testAccessibleNameExtrasFailViewController() throws {
        try runScan(screen: "AccessibleNameExtrasFailViewController")
    }

    func testAccessibleNameExtrasPartialViewController() throws {
        try runScan(screen: "AccessibleNameExtrasPartialViewController")
    }

    // MARK: - Role screens

    func testAccessibleNativeRolePassViewController() throws {
        try runScan(screen: "AccessibleNativeRolePassViewController")
    }

    func testAccessibleNativeRoleFailViewController() throws {
        try runScan(screen: "AccessibleNativeRoleFailViewController")
    }

    func testAccessibleNativeRolePartialViewController() throws {
        try runScan(screen: "AccessibleNativeRolePartialViewController")
    }

    func testAccessibleRolePassViewController() throws {
        try runScan(screen: "AccessibleRolePassViewController")
    }

    func testAccessibleRoleFailViewController() throws {
        try runScan(screen: "AccessibleRoleFailViewController")
    }

    func testAccessibleRolePartialViewController() throws {
        try runScan(screen: "AccessibleRolePartialViewController")
    }

    // MARK: - State screens

    func testAccessibleStatePassViewController() throws {
        try runScan(screen: "AccessibleStatePassViewController")
    }

    func testAccessibleStateFailViewController() throws {
        try runScan(screen: "AccessibleStateFailViewController")
    }

    func testAccessibleStatePartialViewController() throws {
        try runScan(screen: "AccessibleStatePartialViewController")
    }

    // MARK: - Native State screens

    func testAccessibleNativeStatePassViewController() throws {
        try runScan(screen: "AccessibleNativeStatePassViewController")
    }

    func testAccessibleNativeStateFailViewController() throws {
        try runScan(screen: "AccessibleNativeStateFailViewController")
    }

    func testAccessibleNativeStatePartialViewController() throws {
        try runScan(screen: "AccessibleNativeStatePartialViewController")
    }

    // MARK: - Keyboard screens

    func testAccessibleKeyboardPassViewController() throws {
        try runScan(screen: "AccessibleKeyboardPassViewController")
    }

    func testAccessibleKeyboardFailViewController() throws {
        try runScan(screen: "AccessibleKeyboardFailViewController")
    }

    func testAccessibleKeyboardPartialViewController() throws {
        try runScan(screen: "AccessibleKeyboardPartialViewController")
    }

    // MARK: - Keyboard Extras screens

    func testAccessibleKeyboardExtrasPassViewController() throws {
        try runScan(screen: "AccessibleKeyboardExtrasPassViewController")
    }

    func testAccessibleKeyboardExtrasFailViewController() throws {
        try runScan(screen: "AccessibleKeyboardExtrasFailViewController")
    }

    func testAccessibleKeyboardExtrasPartialViewController() throws {
        try runScan(screen: "AccessibleKeyboardExtrasPartialViewController")
    }

    // MARK: - Native Keyboard screens

    func testAccessibleNativeKeyboardPassViewController() throws {
        try runScan(screen: "AccessibleNativeKeyboardPassViewController")
    }

    func testAccessibleNativeKeyboardFailViewController() throws {
        try runScan(screen: "AccessibleNativeKeyboardFailViewController")
    }

    func testAccessibleNativeKeyboardPartialViewController() throws {
        try runScan(screen: "AccessibleNativeKeyboardPartialViewController")
    }

    // MARK: - Target Size screens

    func testAccessibleTargetSizePassViewController() throws {
        try runScan(screen: "AccessibleTargetSizePassViewController")
    }

    func testAccessibleTargetSizeFailViewController() throws {
        try runScan(screen: "AccessibleTargetSizeFailViewController")
    }

    func testAccessibleTargetSizePartialViewController() throws {
        try runScan(screen: "AccessibleTargetSizePartialViewController")
    }

    // MARK: - Text Contrast screens (solid backgrounds)

    func testAccessibleTextContrastPassViewController() throws {
        try runScan(screen: "AccessibleTextContrastPassViewController")
    }

    func testAccessibleTextContrastFailViewController() throws {
        try runScan(screen: "AccessibleTextContrastFailViewController")
    }

    func testAccessibleTextContrastPartialViewController() throws {
        try runScan(screen: "AccessibleTextContrastPartialViewController")
    }

    // MARK: - Composited Contrast screens (alpha, layers, materials, adaptation)

    func testAccessibleTextContrastCompositedPassViewController() throws {
        try runScan(screen: "AccessibleTextContrastCompositedPassViewController")
    }

    func testAccessibleTextContrastCompositedFailViewController() throws {
        try runScan(screen: "AccessibleTextContrastCompositedFailViewController")
    }

    func testAccessibleTextContrastCompositedPartialViewController() throws {
        try runScan(screen: "AccessibleTextContrastCompositedPartialViewController")
    }

    // MARK: - Focus screens

    func testAccessibleFocusPassViewController() throws {
        try runScan(screen: "AccessibleFocusPassViewController")
    }

    func testAccessibleFocusFailViewController() throws {
        try runScan(screen: "AccessibleFocusFailViewController")
    }

    func testAccessibleFocusPartialViewController() throws {
        try runScan(screen: "AccessibleFocusPartialViewController")
    }

    // MARK: - Link screens

    func testAccessibleLinkPassViewController() throws {
        try runScan(screen: "AccessibleLinkPassViewController")
    }

    func testAccessibleLinkFailViewController() throws {
        try runScan(screen: "AccessibleLinkFailViewController")
    }

    func testAccessibleLinkPartialViewController() throws {
        try runScan(screen: "AccessibleLinkPartialViewController")
    }

    // MARK: - Reading Order screens

    func testAccessibleReadingOrderPassViewController() throws {
        try runScan(screen: "AccessibleReadingOrderPassViewController")
    }

    func testAccessibleReadingOrderFailViewController() throws {
        try runScan(screen: "AccessibleReadingOrderFailViewController")
    }

    func testAccessibleReadingOrderPartialViewController() throws {
        try runScan(screen: "AccessibleReadingOrderPartialViewController")
    }

    // MARK: - Image screens

    func testAccessibleImagesPassViewController() throws {
        try runScan(screen: "AccessibleImagesPassViewController")
    }

    func testAccessibleImagesFailViewController() throws {
        try runScan(screen: "AccessibleImagesFailViewController")
    }

    func testAccessibleImagesPartialViewController() throws {
        try runScan(screen: "AccessibleImagesPartialViewController")
    }

    // MARK: - Motion screens

    func testAccessibleMotionPassViewController() throws {
        try runScan(screen: "AccessibleMotionPassViewController")
    }

    func testAccessibleMotionFailViewController() throws {
        try runScan(screen: "AccessibleMotionFailViewController")
    }

    func testAccessibleMotionPartialViewController() throws {
        try runScan(screen: "AccessibleMotionPartialViewController")
    }

    // MARK: - Language screens

    func testAccessibleLanguagePassViewController() throws {
        try runScan(screen: "AccessibleLanguagePassViewController")
    }

    func testAccessibleLanguageFailViewController() throws {
        try runScan(screen: "AccessibleLanguageFailViewController")
    }

    func testAccessibleLanguagePartialViewController() throws {
        try runScan(screen: "AccessibleLanguagePartialViewController")
    }

    // MARK: - Hidden from Screen Reader screens

    func testAccessibleHiddenPassViewController() throws {
        try runScan(screen: "AccessibleHiddenPassViewController")
    }

    func testAccessibleHiddenFailViewController() throws {
        try runScan(screen: "AccessibleHiddenFailViewController")
    }

    func testAccessibleHiddenPartialViewController() throws {
        try runScan(screen: "AccessibleHiddenPartialViewController")
    }


    // MARK: - New rules: role trait, state trait, button, form label, custom action, touch event
    //
    // These scan their screen and assert the rows its doc comment promises (only the eleven
    // rules' own titles are counted; other families judge the same screens).


    private enum Title {
        static let roleFail = "Accessibility role trait does not match element type"
        static let rolePass = "Accessibility role trait correctly matches element type"
        static let statePass = "Accessibility state trait correctly reflects element's actual state"
        static let notInteractive = "Verify if button does not require interaction"
        static let disabledUndefined = "Disabled state of button not defined"
        static let hiddenButton = "Button hidden from screen reader users"
        static let placeholderOnly = "Placeholder text used as the only accessible name — no visible label present"
        static let gestureNoAlternative = "Complex gesture has no accessibility alternative"
        static let gestureAlternative = "Custom action present for gesture"
        static let touchDown = "Action fires on touch down instead of touch up"
        static let touchUp = "Action fires on touch up, allowing cancellation"
        static let errorNotAnnounced = "Error message not announced by screen reader"
        static let borderContrast = "Insufficient color contrast for border of form controls"
        static let nonTextContrast = "Insufficient color contrast for non-text element"
        static let loadingContrast = "Insufficient color contrast for loading indicator"
        static let focusObscured = "Check if focus indicator is obscured by another element"
        static let modalNoControls = "Modal has no keyboard-focusable interactive controls"
        static let modalInaccessible = "Modal dialog inaccessible for screen reader users"
        static let tabHidden = "Check if tab control needs to be hidden for screen reader user"
        static let titleSpecified = "Title is specified for screen"
        static let gestureOperable = "Gesture-only control is operable with keyboard"
        static let gestureNotOperable = "Gesture-only control not operable with keyboard"
        static let autocompleteSpecified = "Autocomplete information is specified for form field"
        static let autocompleteMissing = "Missing autocomplete information for form field"
        static let modalCloseable = "Modal dialog can be closed"
        static let languageChange = "Change in language not defined correctly"
        static let focusOrderOk = "Screen has correct focus order"
        static let focusOrderCheck = "Check if focus order is correct on the screen"
    }

    private let allTitles: Set<String> = [
        Title.roleFail, Title.rolePass, Title.statePass, Title.notInteractive, Title.disabledUndefined,
        Title.hiddenButton, Title.placeholderOnly, Title.gestureNoAlternative, Title.gestureAlternative,
        Title.touchDown, Title.touchUp, Title.errorNotAnnounced, Title.borderContrast, Title.nonTextContrast,
        Title.loadingContrast, Title.focusObscured, Title.modalNoControls, Title.modalInaccessible,
        Title.tabHidden, Title.titleSpecified, Title.gestureOperable, Title.gestureNotOperable,
        Title.autocompleteSpecified, Title.autocompleteMissing, Title.modalCloseable, Title.languageChange,
        Title.focusOrderOk, Title.focusOrderCheck,
    ]

    /// "<status> <title>" for every row of the eleven rules, sorted, so a screen's whole
    /// verdict is one array comparison.
    /// The rule family a new-rule screen demonstrates. The scan is narrowed to it, so another
    /// group's rules (every button also earns a role-trait Pass) cannot change a count.
    private static func family(of screen: String) -> String? {
        let families = ["RoleTrait": "roleTrait", "StateTrait": "stateTrait", "Button": "button",
                        "FormLabel": "formLabel", "CustomAction": "customAction", "TouchEvent": "pointerCancellation",
                        "ErrorMessage": "errorMessage", "NonTextContrast": "nonTextContrast", "FocusObscured": "focusObscured",
                        "Modal": "modal", "TabControl": "tabControl", "ScreenTitle": "screenTitle",
                        "GestureKeyboard": "gestureKeyboard", "Autocomplete": "autocomplete", "ModalClose": "modalClose",
                        "LanguageChange": "languageChange", "FocusOrder": "focusOrder"]
        // Longest stem first: "AccessibleModalClose…" also contains "AccessibleModal".
        return families.filter { screen.contains("Accessible\($0.key)") }
            .max { $0.key.count < $1.key.count }?.value
    }

    private func rows(_ screen: String, family: String? = nil, file: StaticString = #filePath, line: UInt = #line) throws -> [String] {
        try runScan(screen: screen, family: family ?? Self.family(of: screen), includePasses: true, file: file, line: line)
            .filter { allTitles.contains($0.rule) }
            .map { "\($0.status) \($0.rule)" }
            .sorted()
    }

    private func expect(_ pairs: [(Int, String, String)], screen: String, family: String? = nil,
                        file: StaticString = #filePath, line: UInt = #line) throws {
        let expected = pairs.flatMap { Array(repeating: "\($0.1) \($0.2)", count: $0.0) }.sorted()
        XCTAssertEqual(try rows(screen, family: family, file: file, line: line), expected, file: file, line: line)
    }

    // MARK: - Role trait (BB40274 / BB40275)

    func testAccessibleRoleTraitPassViewController() throws {
        try expect([(5, "Pass", Title.rolePass)], screen: "AccessibleRoleTraitPassViewController")
    }

    func testAccessibleRoleTraitFailViewController() throws {
        try expect([(5, "Fail", Title.roleFail)], screen: "AccessibleRoleTraitFailViewController")
    }

    func testAccessibleRoleTraitPartialViewController() throws {
        try expect([(2, "Pass", Title.rolePass), (2, "Fail", Title.roleFail)],
                   screen: "AccessibleRoleTraitPartialViewController")
    }

    // MARK: - State trait (BB40277) — a Pass-only rule

    func testAccessibleStateTraitPassViewController() throws {
        try expect([(2, "Pass", Title.statePass)], screen: "AccessibleStateTraitPassViewController")
    }

    func testAccessibleStateTraitFailViewController() throws {
        // Wrong state is not a BB40277 row; the disabled button that dropped .notEnabled is the
        // Button group's finding (BB40079).
        try expect([], screen: "AccessibleStateTraitFailViewController")
    }

    func testAccessibleStateTraitPartialViewController() throws {
        try expect([(1, "Pass", Title.statePass)], screen: "AccessibleStateTraitPartialViewController")
    }

    // MARK: - Button (BB40001 / BB40079; BB40078 is suppressed in favour of BB40046)

    func testAccessibleButtonPassViewController() throws {
        try expect([], screen: "AccessibleButtonPassViewController")
    }

    func testAccessibleButtonFailViewController() throws {
        try expect([(2, "Validate", Title.notInteractive), (2, "Fail", Title.disabledUndefined)],
                   screen: "AccessibleButtonFailViewController")
    }

    func testAccessibleButtonPartialViewController() throws {
        try expect([(1, "Validate", Title.notInteractive), (1, "Fail", Title.disabledUndefined)],
                   screen: "AccessibleButtonPartialViewController")
    }

    // MARK: - Form label (BB40034) — no Pass id exists

    func testAccessibleFormLabelPassViewController() throws {
        try expect([], screen: "AccessibleFormLabelPassViewController")
    }

    func testAccessibleFormLabelFailViewController() throws {
        try expect([(2, "Fail", Title.placeholderOnly)], screen: "AccessibleFormLabelFailViewController")
    }

    func testAccessibleFormLabelPartialViewController() throws {
        try expect([(1, "Fail", Title.placeholderOnly)], screen: "AccessibleFormLabelPartialViewController")
    }

    // MARK: - Custom action (BB40190 / BB40191)

    func testAccessibleCustomActionPassViewController() throws {
        try expect([(4, "Pass", Title.gestureAlternative)], screen: "AccessibleCustomActionPassViewController")
    }

    func testAccessibleCustomActionFailViewController() throws {
        try expect([(4, "Fail", Title.gestureNoAlternative)], screen: "AccessibleCustomActionFailViewController")
    }

    func testAccessibleCustomActionPartialViewController() throws {
        try expect([(2, "Pass", Title.gestureAlternative), (2, "Fail", Title.gestureNoAlternative)],
                   screen: "AccessibleCustomActionPartialViewController")
    }

    // MARK: - Touch event (BB40136 / BB40137)

    func testAccessibleTouchEventPassViewController() throws {
        try expect([(3, "Pass", Title.touchUp)], screen: "AccessibleTouchEventPassViewController")
    }

    func testAccessibleTouchEventFailViewController() throws {
        try expect([(3, "Fail", Title.touchDown)], screen: "AccessibleTouchEventFailViewController")
    }

    func testAccessibleTouchEventPartialViewController() throws {
        try expect([(2, "Pass", Title.touchUp), (2, "Fail", Title.touchDown)],
                   screen: "AccessibleTouchEventPartialViewController")
    }

    // MARK: - Batch 2: error message, non-text contrast, focus obscured, modal, tab control, screen title

    // Error message

    func testAccessibleErrorMessagePassViewController() throws {
        try expect([], screen: "AccessibleErrorMessagePassViewController")
    }

    func testAccessibleErrorMessagePartialViewController() throws {
        try expect([(2, "Fail", Title.errorNotAnnounced)], screen: "AccessibleErrorMessagePartialViewController")
    }

    func testAccessibleErrorMessageFailViewController() throws {
        try expect([(3, "Fail", Title.errorNotAnnounced)], screen: "AccessibleErrorMessageFailViewController")
    }

    // Non-text contrast

    func testAccessibleNonTextContrastPassViewController() throws {
        try expect([], screen: "AccessibleNonTextContrastPassViewController")
    }

    func testAccessibleNonTextContrastPartialViewController() throws {
        try expect([(1, "Fail", Title.loadingContrast), (1, "Fail", Title.nonTextContrast)], screen: "AccessibleNonTextContrastPartialViewController")
    }

    func testAccessibleNonTextContrastFailViewController() throws {
        try expect([(1, "Fail", Title.borderContrast), (2, "Fail", Title.loadingContrast), (2, "Fail", Title.nonTextContrast)], screen: "AccessibleNonTextContrastFailViewController")
    }

    // Focus obscured

    func testAccessibleFocusObscuredPassViewController() throws {
        try expect([], screen: "AccessibleFocusObscuredPassViewController")
    }

    func testAccessibleFocusObscuredPartialViewController() throws {
        try expect([(1, "Validate", Title.focusObscured)], screen: "AccessibleFocusObscuredPartialViewController")
    }

    func testAccessibleFocusObscuredFailViewController() throws {
        try expect([(3, "Validate", Title.focusObscured)], screen: "AccessibleFocusObscuredFailViewController")
    }

    // Modal

    func testAccessibleModalPassViewController() throws {
        try expect([], screen: "AccessibleModalPassViewController")
    }

    func testAccessibleModalPartialViewController() throws {
        try expect([(1, "Fail", Title.modalNoControls), (2, "Fail", Title.modalInaccessible)], screen: "AccessibleModalPartialViewController")
    }

    func testAccessibleModalFailViewController() throws {
        try expect([(2, "Fail", Title.modalNoControls), (2, "Fail", Title.modalInaccessible)], screen: "AccessibleModalFailViewController")
    }

    // Tab control

    func testAccessibleTabControlPassViewController() throws {
        try expect([], screen: "AccessibleTabControlPassViewController")
    }

    func testAccessibleTabControlPartialViewController() throws {
        try expect([(1, "Validate", Title.tabHidden)], screen: "AccessibleTabControlPartialViewController")
    }

    func testAccessibleTabControlFailViewController() throws {
        try expect([(2, "Validate", Title.tabHidden)], screen: "AccessibleTabControlFailViewController")
    }

    // Screen title

    func testAccessibleScreenTitlePassViewController() throws {
        try expect([(1, "Pass", Title.titleSpecified)], screen: "AccessibleScreenTitlePassViewController")
    }

    func testAccessibleScreenTitlePartialViewController() throws {
        try expect([(1, "Pass", Title.titleSpecified)], screen: "AccessibleScreenTitlePartialViewController")
    }

    func testAccessibleScreenTitleFailViewController() throws {
        try expect([], screen: "AccessibleScreenTitleFailViewController")
    }

    // MARK: - Batch 3: gesture keyboard, autocomplete, modal close, language change, focus order

    // GestureKeyboard

    func testAccessibleGestureKeyboardPassViewController() throws {
        try expect([(2, "Pass", Title.gestureOperable)], screen: "AccessibleGestureKeyboardPassViewController")
    }

    func testAccessibleGestureKeyboardFailViewController() throws {
        try expect([(2, "Fail", Title.gestureNotOperable)], screen: "AccessibleGestureKeyboardFailViewController")
    }

    func testAccessibleGestureKeyboardPartialViewController() throws {
        try expect([(1, "Pass", Title.gestureOperable), (1, "Fail", Title.gestureNotOperable)], screen: "AccessibleGestureKeyboardPartialViewController")
    }

    // Autocomplete

    func testAccessibleAutocompletePassViewController() throws {
        try expect([(2, "Pass", Title.autocompleteSpecified)], screen: "AccessibleAutocompletePassViewController")
    }

    func testAccessibleAutocompleteFailViewController() throws {
        try expect([(2, "Fail", Title.autocompleteMissing)], screen: "AccessibleAutocompleteFailViewController")
    }

    func testAccessibleAutocompletePartialViewController() throws {
        try expect([(1, "Pass", Title.autocompleteSpecified), (1, "Fail", Title.autocompleteMissing)], screen: "AccessibleAutocompletePartialViewController")
    }

    // ModalClose

    func testAccessibleModalClosePassViewController() throws {
        try expect([(1, "Pass", Title.modalCloseable)], screen: "AccessibleModalClosePassViewController", family: "modalClose")
        try expect([], screen: "AccessibleModalClosePassViewController", family: "modal")
    }

    func testAccessibleModalCloseFailViewController() throws {
        try expect([], screen: "AccessibleModalCloseFailViewController", family: "modalClose")
        try expect([(1, "Fail", Title.modalInaccessible)], screen: "AccessibleModalCloseFailViewController", family: "modal")
    }

    func testAccessibleModalClosePartialViewController() throws {
        try expect([(1, "Pass", Title.modalCloseable)], screen: "AccessibleModalClosePartialViewController", family: "modalClose")
        try expect([(1, "Fail", Title.modalInaccessible)], screen: "AccessibleModalClosePartialViewController", family: "modal")
    }

    // LanguageChange

    func testAccessibleLanguageChangePassViewController() throws {
        try expect([], screen: "AccessibleLanguageChangePassViewController")
    }

    func testAccessibleLanguageChangeFailViewController() throws {
        try expect([(2, "Fail", Title.languageChange)], screen: "AccessibleLanguageChangeFailViewController")
    }

    func testAccessibleLanguageChangePartialViewController() throws {
        try expect([(1, "Fail", Title.languageChange)], screen: "AccessibleLanguageChangePartialViewController")
    }

    // FocusOrder

    func testAccessibleFocusOrderPassViewController() throws {
        try expect([(1, "Pass", Title.focusOrderOk)], screen: "AccessibleFocusOrderPassViewController")
    }

    func testAccessibleFocusOrderFailViewController() throws {
        try expect([(1, "Validate", Title.focusOrderCheck)], screen: "AccessibleFocusOrderFailViewController")
    }

    func testAccessibleFocusOrderPartialViewController() throws {
        try expect([(1, "Pass", Title.focusOrderOk), (1, "Validate", Title.focusOrderCheck)], screen: "AccessibleFocusOrderPartialViewController")
    }

    /// Every screen in one run — the combined report, as before.
    func testAllScreens() throws {
        try runScan(screen: nil)
    }
}
