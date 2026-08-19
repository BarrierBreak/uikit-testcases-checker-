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

    /// Every screen in one run — the combined report, as before.
    func testAllScreens() throws {
        try runScan(screen: nil)
    }
}
