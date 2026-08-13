//
//  A11yFrameworkScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  Launches the app with --a11y-scan, waits for the framework to scan the
//  Pass / Fail / Partial example screens, then reads the saved report and
//  attaches it to the test result (visible in Xcode's Report Navigator
//  under the test run).
//
//  Run:  Product → Test  (or ⌘U)
//  Find the report in the test results panel under "A11yDemoScanTests"
//  or on ~/Documents/a11y-demo-report.txt in the simulator.
//

import XCTest

final class A11yDemoScanTests: XCTestCase {

    func testRunFrameworkAgainstAllScreens() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--a11y-scan"]
        app.launch()

        // Wait for the app to signal it finished scanning all screens.
        // The app adds a hidden label with this identifier when writeSummary() completes.
        let scanDoneSignal = app.staticTexts["a11yScanDone"]
        let finished = scanDoneSignal.waitForExistence(timeout: 60)

        guard finished else {
            XCTFail("Scan did not complete within the timeout — check Xcode console for [A11yDemo] errors.")
            return
        }

        // The report text is stored in the signal element's accessibilityValue.
        // This avoids UIPasteboard which is blocked in UITest runners on device.
        guard let reportText = scanDoneSignal.value as? String, !reportText.isEmpty else {
            XCTFail("Report was empty — check Xcode console for [A11yDemo] errors.")
            return
        }

        let attachment = XCTAttachment(string: reportText)
        attachment.name = "A11y Demo Scan Report"
        attachment.lifetime = .keepAlways
        add(attachment)

        print("\n\(reportText)\n")
    }
}
