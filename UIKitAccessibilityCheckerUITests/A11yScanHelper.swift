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

/// The report as a person wants to read it in the console: everything up to the JSON SUMMARY
/// section, minus the heading and rule lines that introduced it. That section is machine
/// output for `runScan` to decode — printing a few hundred lines of it buries the readable
/// report, and printing its heading with nothing underneath reads like the report was
/// truncated by an error. The full text, JSON included, is still attached to the test result.
private func readableReport(_ reportText: String) -> String {
    let head = reportText.range(of: "JSON SUMMARY")
        .map { String(reportText[..<$0.lowerBound]) } ?? reportText
    var lines = head.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    while let last = lines.last {
        let trimmed = last.trimmingCharacters(in: .whitespaces)
        let isDecoration = trimmed.isEmpty
            || trimmed.allSatisfy { $0 == "━" }
            || trimmed.range(of: "^[0-9]+\\.$", options: .regularExpression) != nil
        guard isDecoration else { break }
        lines.removeLast()
    }
    return lines.joined(separator: "\n")
}

extension XCTestCase {

    /// Launches the app, scans `screen` (or all screens when nil), attaches the report, and
    /// returns the decoded `all_issues` list so callers can assert against specific findings.
    ///
    /// `includePasses` folds the report's `all_passes` rows in alongside them. The report omits
    /// passes by default because its job is to surface what needs attention, but a test cannot
    /// see around that omission: "this control has no failure" and "the scan never reached this
    /// control" are the same empty result. Ask for the passes when the assertion is that a
    /// control was measured AND came out clean — colour contrast's Pass tier is the case that
    /// needs it, since a passing ratio has no Validate row standing in for it.
    /// `family` narrows the scan to one rule family — "name", "role", "state", "targetSize",
    /// "keyboard" or "colourContrast". Omitting it scans every rule, which is what the
    /// per-screen suites want; a per-family suite passes one and gets a report with nothing
    /// else in it, instead of filtering forty rules' worth of rows down to six per assertion.
    @discardableResult
    func runScan(
        screen: String?,
        family: String? = nil,
        includePasses: Bool = false,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> [A11yIssue] {
        let app = XCUIApplication()
        app.launchArguments = ["--a11y-testcases-scan"]
        if let screen {
            app.launchArguments.append("--a11y-testcases-screen=\(screen)")
        }
        if let family {
            app.launchArguments.append("--a11y-testcases-family=\(family)")
        }
        app.launch()

        // Wait for the app to signal it finished scanning. The app adds a hidden label
        // with this identifier when writeSummary() completes.
        let scanDoneSignal = app.staticTexts["a11yTestCasesScanDone"]
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

        // xcodebuild echoes a STRING attachment's entire content into the console log, so this
        // one carries the readable report only. Attaching the full text here is what kept
        // putting a few hundred lines of JSON in the console after every test, even though
        // both this helper and the app already trim it before their own print().
        let attachment = XCTAttachment(string: readableReport(reportText))
        attachment.name = screen.map { "A11y Scan Report — \($0)" } ?? "A11y Demo Scan Report"
        attachment.lifetime = .keepAlways
        add(attachment)

        // The machine-readable half is kept as DATA rather than a string: it stays in the
        // .xcresult for anyone who needs to see exactly what the scan returned, without being
        // echoed. (The app also writes the whole report, JSON included, to
        // a11y-demo-report.txt in its Documents directory.)
        if let reportData = reportText.data(using: .utf8) {
            let jsonAttachment = XCTAttachment(data: reportData, uniformTypeIdentifier: "public.plain-text")
            jsonAttachment.name = screen.map { "A11y Scan JSON — \($0)" } ?? "A11y Demo Scan JSON"
            jsonAttachment.lifetime = .keepAlways
            add(jsonAttachment)
        }

        print("\n\(readableReport(reportText))\n")

        // The JSON summary is always the last section of the report — everything from the
        // first "{" after its heading to the end of the string is the JSON blob itself.
        guard let headingRange = reportText.range(of: "JSON SUMMARY"),
              let braceRange = reportText.range(of: "{", range: headingRange.upperBound..<reportText.endIndex) else {
            XCTFail("Report had no JSON SUMMARY section to decode.", file: file, line: line)
            return []
        }
        let jsonText = String(reportText[braceRange.lowerBound...])
        guard let jsonData = jsonText.data(using: .utf8) else { return [] }
        // all_passes is optional so this helper still decodes a report written by an older
        // build of the app, which has no such key — the tests that do not ask for passes keep
        // working rather than failing to decode.
        struct Summary: Decodable {
            let all_issues: [A11yIssue]
            let all_passes: [A11yIssue]?
        }
        let summary = try JSONDecoder().decode(Summary.self, from: jsonData)
        guard includePasses else { return summary.all_issues }
        return summary.all_issues + (summary.all_passes ?? [])
    }
}
