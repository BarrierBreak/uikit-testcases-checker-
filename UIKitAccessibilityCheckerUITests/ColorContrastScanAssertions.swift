//
//  ColorContrastScanAssertions.swift
//  UIKitAccessibilityCheckerUITests
//
//  Shared vocabulary for the three Colour Contrast scan suites — one class per tier
//  (ColorContrastFailElementScanTests, ColorContrastPartialElementScanTests,
//  ColorContrastPassElementScanTests), so a tier can be run on its own and a failure names the
//  tier it came from. The rule strings and assertions live here rather than being copied into
//  each class, because all three assert against the same five database records and a string
//  that drifts in one copy fails silently by matching nothing.
//

import XCTest

/// The five outcomes ColorContrastValidator can reach, by the exact `issueVariable` text the
/// report prints — matching is on this string, so it has to be the database's wording.
///
/// Which of the two thresholds applies is decided by WCAG's definition of large text — 18pt or
/// bigger, OR bold at 14pt or bigger — and that classification happens BEFORE any comparison.
/// The same colour pair can therefore be a `normalFail` on one control and a `largePass` on
/// the next, which is what the demo screens are built to demonstrate.
enum ColorContrastRule {
    /// Under 4.5:1, and the text is not large. WCAG 1.4.3, BB40518.
    static let normalFail = "Insufficient color contrast for standard text"
    /// Under 3:1, and the text is large. WCAG 1.4.3, BB40520.
    static let largeFail = "Insufficient color contrast for large text"
    /// Text over an image or gradient: no single ratio exists, so the rule declines to
    /// compute one and asks for a human check instead. BB40514.
    static let validate = "Check if the contrast ratio of large text between the foreground and background image is 3:1"
    /// At or above 4.5:1, normal text. BB40524.
    static let normalPass = "Standard text meets the required 4.5:1 contrast ratio between the foreground and background color"
    /// At or above 3:1, large text. BB40522.
    static let largePass = "Large text meets the required 3:1 contrast ratio between the foreground and background color"

    static let failures = [normalFail, largeFail]
    static let passes = [normalPass, largePass]
    static let all = [normalFail, largeFail, validate, normalPass, largePass]
}

extension XCTestCase {

    /// Every contrast row the scan produced for the control whose accessible name contains
    /// `substring`.
    func contrastRows(_ issues: [A11yIssue], forElementContaining substring: String) -> [A11yIssue] {
        issues.filter { ColorContrastRule.all.contains($0.rule) && $0.element.contains(substring) }
    }

    /// Asserts the named control produced exactly this contrast rule.
    ///
    /// Deliberately stricter than "a row of this rule exists somewhere": a contrast verdict is
    /// one row per control, so finding the right rule while ALSO finding a second, contradictory
    /// one for the same control is not a pass. The failure message prints every contrast row for
    /// that control, since the interesting mistakes here are a right answer under the wrong
    /// threshold — a `largeFail` where a `normalFail` belongs means the size classification is
    /// wrong even though the arithmetic was right.
    func assertContrast(
        _ issues: [A11yIssue],
        is rule: String,
        forElementContaining substring: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let rows = contrastRows(issues, forElementContaining: substring)
        guard !rows.isEmpty else {
            XCTFail(
                "No contrast row at all for a control named '\(substring)' — the scan never "
                + "measured it. All contrast rows: \(describe(issues.filter { ColorContrastRule.all.contains($0.rule) }))",
                file: file, line: line
            )
            return
        }
        XCTAssertTrue(
            rows.allSatisfy { $0.rule == rule },
            "Expected '\(substring)' to be reported as '\(rule)', got: \(describe(rows))",
            file: file, line: line
        )
    }

    /// Asserts the named control was measured and did NOT come out as a failure.
    ///
    /// Needs `includePasses: true` on the scan: without the pass rows, "no failure" and "never
    /// reached" are the same empty result, and this assertion has to tell them apart — its whole
    /// purpose is proving the rule looked and was satisfied.
    func assertContrastPasses(
        _ issues: [A11yIssue],
        forElementContaining substring: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let rows = contrastRows(issues, forElementContaining: substring)
        guard !rows.isEmpty else {
            XCTFail(
                "No contrast row at all for a control named '\(substring)' — the scan never "
                + "measured it, so 'it passes' is not something this report can support.",
                file: file, line: line
            )
            return
        }
        XCTAssertTrue(
            rows.allSatisfy { ColorContrastRule.passes.contains($0.rule) },
            "Expected '\(substring)' to pass, got: \(describe(rows))",
            file: file, line: line
        )
    }

    /// Asserts the named control was measured and came out as a failure, without saying which
    /// of the two failure rules it is.
    ///
    /// This is the SwiftUI-side counterpart to `assertContrast(is:)`. On UIKit the font is
    /// readable, so large-vs-normal is a fact and the exact rule can be pinned. On SwiftUI it
    /// is inferred from the element's frame height — padding moves it — so pinning the rule
    /// would be pinning a layout detail rather than an accessibility one. The SwiftUI screens
    /// are built so every control is unambiguous under BOTH thresholds, and this assertion is
    /// what that design buys.
    func assertContrastFails(
        _ issues: [A11yIssue],
        forElementContaining substring: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let rows = contrastRows(issues, forElementContaining: substring)
        guard !rows.isEmpty else {
            XCTFail(
                "No contrast row at all for a control named '\(substring)' — the scan never "
                + "measured it, so it cannot have failed either.",
                file: file, line: line
            )
            return
        }
        XCTAssertTrue(
            rows.allSatisfy { ColorContrastRule.failures.contains($0.rule) },
            "Expected '\(substring)' to be reported as a contrast failure, got: \(describe(rows))",
            file: file, line: line
        )
    }

    /// Asserts only that the control was measured — some contrast verdict exists for it.
    ///
    /// For screens where the verdict itself is not a fact worth asserting: text over a gradient
    /// has a different ratio over every pixel, so whichever way the sampling lands is an
    /// artefact of where the crop fell, not a statement about the screen. What can honestly be
    /// asserted is that the control was not skipped.
    func assertContrastIsReported(
        _ issues: [A11yIssue],
        forElementContaining substring: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertFalse(
            contrastRows(issues, forElementContaining: substring).isEmpty,
            "Expected some contrast verdict for a control named '\(substring)', but it was "
            + "never measured. All contrast rows: "
            + "\(describe(issues.filter { ColorContrastRule.all.contains($0.rule) }))",
            file: file, line: line
        )
    }

    /// The contrast rows belonging to controls this screen tagged with `.srcLine()`.
    ///
    /// A screen's own captions and the odd system-supplied inner label get measured too — every
    /// visible piece of text does — and they carry no source tag, so counting raw rows counts
    /// scenery. This narrows to the controls the screen actually declares.
    func taggedContrastRows(_ issues: [A11yIssue], sourceFile: String) -> [A11yIssue] {
        issues.filter { ColorContrastRule.all.contains($0.rule) && $0.element.contains("\(sourceFile):") }
    }

    private func describe(_ issues: [A11yIssue]) -> String {
        issues.isEmpty ? "(none)" : issues.map { "[\($0.status)] \($0.rule) — \($0.element)" }.joined(separator: " | ")
    }
}
