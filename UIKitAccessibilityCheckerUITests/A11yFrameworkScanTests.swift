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

    /// Every screen in one run — the combined report, as before.
    func testAllScreens() throws {
        try runScan(screen: nil)
    }
}
