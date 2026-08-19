//
//  A11yScanHelper.swift
//  UIKitAccessibilityCheckerUITests
//
//  Shared scan-and-decode helper used by every test class in this target
//  (A11yDemoScanTests, RoleElementScanTests, …), so each screen scan is driven
//  and parsed the exact same way regardless of which test suite calls it.
//

import XCTest

/// One entry from the report's "JSON SUMMARY" `all_issues` array — every Fail/Validate/
/// Suggestion row the scan produced, in the exact form assertions can match against.
struct A11yIssue: Decodable {
    let screen: String
    let rule: String
    let status: String
    let `class`: String
    let element: String
    let detail: String
}

extension XCTestCase {

    /// Launches the app, scans `screen` (or all screens when nil), attaches the report, and
    /// returns the decoded `all_issues` list so callers can assert against specific findings.
    @discardableResult
    func runScan(screen: String?, file: StaticString = #filePath, line: UInt = #line) throws -> [A11yIssue] {
        let app = XCUIApplication()
        app.launchArguments = ["--a11y-scan"]
        if let screen {
            app.launchArguments.append("--a11y-screen=\(screen)")
        }
        app.launch()

        // Wait for the app to signal it finished scanning. The app adds a hidden label
        // with this identifier when writeSummary() completes.
        let scanDoneSignal = app.staticTexts["a11yScanDone"]
        guard scanDoneSignal.waitForExistence(timeout: 60) else {
            XCTFail("Scan did not complete within the timeout — check Xcode console for [A11yDemo] errors.",
                    file: file, line: line)
            return []
        }

        // The report text is stored in the signal element's accessibilityValue.
        // This avoids UIPasteboard which is blocked in UITest runners on device.
        guard let reportText = scanDoneSignal.value as? String, !reportText.isEmpty else {
            XCTFail("Report was empty — check Xcode console for [A11yDemo] errors.",
                    file: file, line: line)
            return []
        }

        let attachment = XCTAttachment(string: reportText)
        attachment.name = screen.map { "A11y Scan Report — \($0)" } ?? "A11y Demo Scan Report"
        attachment.lifetime = .keepAlways
        add(attachment)

        print("\n\(reportText)\n")

        // The JSON summary is always the last section of the report — everything from the
        // first "{" after its heading to the end of the string is the JSON blob itself.
        guard let headingRange = reportText.range(of: "JSON SUMMARY"),
              let braceRange = reportText.range(of: "{", range: headingRange.upperBound..<reportText.endIndex) else {
            XCTFail("Report had no JSON SUMMARY section to decode.", file: file, line: line)
            return []
        }
        let jsonText = String(reportText[braceRange.lowerBound...])
        guard let jsonData = jsonText.data(using: .utf8) else { return [] }
        struct Summary: Decodable { let all_issues: [A11yIssue] }
        let summary = try JSONDecoder().decode(Summary.self, from: jsonData)
        return summary.all_issues
    }
}
