//
//  UIKitA11yScanRunner.swift
//  UIKitAccessibilityChecker
//
//  Runs the A11yInspect framework against every example screen and prints the same
//  structured report as the SwiftUI checker (SwiftUIA11yScanRunner). The reporter
//  section below is kept identical on purpose so both apps produce directly
//  comparable output.
//
//  Trigger: launch the app with the argument  --a11y-scan
//  Results: printed to the Xcode console AND written to
//           ~/Documents/a11y-demo-report.txt
//

import UIKit
import A11yInspect_Accessibility_Framework

private extension String {
    func leftPad(_ width: Int) -> String {
        let pad = width - count
        return pad > 0 ? String(repeating: " ", count: pad) + self : self
    }
}

// MARK: - Summary Reporter

public final class UIKitDemoA11ySummaryReporter {

    public static let shared = UIKitDemoA11ySummaryReporter()
    private init() {}

    private struct ScanRecord {
        let index: Int
        let screenName: String
        let screenClass: String
        let elementCount: Int
        let results: [AccessibilityTechniqueAnnotated]
        /// Element positions captured during the scan, keyed by record id. `elementInfo.view`
        /// is a weak reference, so by the time the report is formatted the screen has been
        /// swapped out and the view is gone — reading the frame then yields nothing. These
        /// are recorded while the view is still alive.
        let locations: [String: String]
    }

    private var scans: [ScanRecord] = []
    private let lock = NSLock()

    public func addScan(
        screenName: String,
        screenClass: String = "",
        elementCount: Int = 0,
        results: [AccessibilityTechniqueAnnotated],
        locations: [String: String] = [:]
    ) {
        lock.lock(); defer { lock.unlock() }
        scans.append(ScanRecord(
            index: scans.count + 1,
            screenName: screenName,
            screenClass: screenClass,
            elementCount: elementCount,
            results: results,
            locations: locations
        ))
    }

    /// Real class of the flagged element for the report — "UIButton" etc. for UIKit
    /// views, and a trait-derived name for SwiftUI elements (whose UIKit-level class
    /// is always the opaque "SwiftUI.Element" proxy). Replaces record.element, which
    /// is the rule's database *category* column ("Keyboard", "Forms") — misleading
    /// when read as the element's class.
    private func displayClass(_ info: AccessibilityElementInfo) -> String {
        guard info.className == "SwiftUI.Element" else { return info.className }
        let traits = UIAccessibilityTraits(rawValue: info.accessibilityTraits)
        // Toggles carry .button too, so this has to be tested first or every switch
        // displays as "SwiftUIButton". 1 << 53 is the toggle-button trait, which UIKit
        // does not expose to Swift.
        if info.accessibilityTraits & (1 << 53) != 0 { return "SwiftUIToggle" }
        if traits.contains(.button) { return "SwiftUIButton" }
        if traits.contains(.link) { return "SwiftUILink" }
        if traits.contains(.adjustable) { return "SwiftUIAdjustable" }
        if traits.contains(.header) { return "SwiftUIHeading" }
        if traits.contains(.image) { return "SwiftUIImage" }
        if traits.contains(.staticText) { return "SwiftUIText" }
        return "SwiftUIElement"
    }

    /// Source line of the control that produced this finding.
    ///
    /// There is no runtime link from a live view back to the code that declared it, so the
    /// screens record it themselves: each control carries `accessibilityIdentifier`
    /// "src:<line>", written with `#line` at its declaration. This reads that back.
    private func elementLocation(_ info: AccessibilityElementInfo, captured: String? = nil) -> String {
        if let captured, !captured.isEmpty { return captured }
        guard let id = info.accessibilityIdentifier, id.hasPrefix("src:") else { return "" }
        return String(id.dropFirst(4))
    }

    private func elementName(_ info: AccessibilityElementInfo) -> String {
        let label = info.accessibilityLabel?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return (label.isEmpty || label == "None") ? "no name" : label
    }

    public func reset() {
        lock.lock(); defer { lock.unlock() }
        scans = []
    }

    private func severity(for rule: String) -> String {
        let r = rule.lowercased()
        let high = ["target size", "missing accessib", "adjustable element missing", "ambiguous"]
        let medium = ["image", "heading", "orientation", "generic and does not convey", "restates the element role", "anti-pattern"]
        if high.contains(where: { r.contains($0) }) { return "High" }
        if medium.contains(where: { r.contains($0) }) { return "Medium" }
        return "Low"
    }

    private func category(for rule: String) -> String {
        let r = rule.lowercased()
        if r.contains("hint") { return "Hint Issues" }
        if r.contains("value") { return "Value Issues" }
        if r.contains("label") || r.contains("name") || r.contains("description") || r.contains("heading") { return "Label Issues" }
        if r.contains("target") || r.contains("size") || r.contains("spacing") { return "Touch Target Issues" }
        if r.contains("trait") || r.contains("role") || r.contains("ambiguous") { return "Trait Issues" }
        if r.contains("orientation") { return "Orientation Issues" }
        if r.contains("link") { return "Link Issues" }
        return "Other Issues"
    }

    private func perScanSection() -> String {
        var lines: [String] = []
        lines.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        lines.append("  PER-SCREEN SCAN RESULTS")
        lines.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        for scan in scans {
            let failures = scan.results.filter { $0.record.status.lowercased() == "fail" }
            lines.append("\nScan \(scan.index):")
            lines.append("  Screen          : \(scan.screenName)")
            lines.append("  Screen Class    : \(scan.screenClass)")
            lines.append("  Elements Tested : \(scan.elementCount)")
            let failsByRule = Dictionary(grouping: failures) { $0.record.issueVariable }
            // Element count per issue, so a screen can be checked against what is actually
            // on it without reading the whole list: "13 across 3 rules — 8, 4, 1 elements".
            let perRuleCounts = failsByRule.keys.sorted().map { failsByRule[$0]!.count }
            let ruleWord = failsByRule.count == 1 ? "rule" : "rules"
            lines.append("  Issues          : \(failures.count)"
                + (failsByRule.isEmpty ? "" : " across \(failsByRule.count) \(ruleWord) — "
                    + perRuleCounts.map(String.init).joined(separator: ", ") + " elements"))
            if !failsByRule.isEmpty {
                lines.append("  Issues by rule:")
                for rule in failsByRule.keys.sorted() {
                    let group = failsByRule[rule]!
                    lines.append("    - \(rule) — \(group.count) element\(group.count == 1 ? "" : "s")")
                    lines.append("      Affected Elements:")
                    for result in group {
                        let cls = displayClass(result.elementInfo)
                        let name = elementName(result.elementInfo)
                        let where_ = elementLocation(result.elementInfo, captured: scan.locations[result.id])
                        lines.append("        • \(cls) [\(name)]\(where_.isEmpty ? "" : " — \(where_)") — Screen: \(scan.screenClass)")
                    }
                }
            }
        }
        return lines.joined(separator: "\n")
    }

    public func formatted() -> String {
        lock.lock(); defer { lock.unlock() }

        // Screen shown as "Name (ScreenClass)" so every issue carries the full class
        // of the screen it was found on, e.g. "Pass (AccessibleNamePass)".
        let allWithScreen: [(screen: String, result: AccessibilityTechniqueAnnotated)] =
            scans.flatMap { scan in
                let label = scan.screenClass.isEmpty ? scan.screenName : "\(scan.screenName) (\(scan.screenClass))"
                return scan.results.map { (label, $0) }
            }
        let allResults = allWithScreen.map { $0.result }
        let locationsByID = scans.reduce(into: [String: String]()) { $0.merge($1.locations) { a, _ in a } }
        let totalElements = scans.reduce(0) { $0 + $1.elementCount }

        let allByRule  = Dictionary(grouping: allWithScreen) { $0.result.record.issueVariable }
        let allRuleIDs = allByRule.keys.sorted()

        let allFails    = allResults.filter { $0.record.status.lowercased() == "fail" }
        let allPasses   = allResults.filter { $0.record.status.lowercased() == "pass" }
        let allWarnings = allResults.filter {
            let s = $0.record.status.lowercased()
            return s == "validate" || s == "suggestion"
        }

        var out: [String] = []

        // ── Section 1: Global Summary ───────────────────────────────
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        out.append("  1. GLOBAL SUMMARY")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        out.append("  Total Screens Scanned  : \(scans.count)")
        out.append("  Total Elements Tested  : \(totalElements)")
        out.append("  Total Rules Executed   : \(allRuleIDs.count)")
        out.append("  Total Failures         : \(allFails.count)")
        out.append("  Total Warnings         : \(allWarnings.count)")
        out.append("  Total Passes           : \(allPasses.count)")
        out.append("  UIKit Failures         : \(allFails.count)")
        out.append("  SwiftUI Failures       : 0")
        let emoji = allFails.isEmpty ? "✅" : "❌"
        out.append("  \(emoji) Overall Status        : \(allFails.isEmpty ? "PASS" : "FAIL")")

        // ── Section 2: Per-Screen Results ───────────────────────────
        out.append("")
        out.append(perScanSection())

        // ── Section 2: Ruleset-Wise Failure Report ──────────────────
        out.append("")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        out.append("  2. RULESET-WISE FAILURE REPORT")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        for rule in allRuleIDs {
            let entries = allByRule[rule] ?? []
            let fails   = entries.filter { $0.result.record.status.lowercased() == "fail" }
            let passes  = entries.filter { $0.result.record.status.lowercased() == "pass" }
            let warns   = entries.filter {
                let s = $0.result.record.status.lowercased(); return s == "validate" || s == "suggestion"
            }

            out.append("")
            out.append("Rule: \(rule)")
            out.append("  UIKit Failures   : \(fails.count)")
            out.append("  SwiftUI Failures : 0")
            out.append("  Total Failures   : \(fails.count)")
            out.append("  Warnings         : \(warns.count)")
            out.append("  Passes           : \(passes.count)")
            out.append("  Severity         : \(severity(for: rule))")
            if !fails.isEmpty {
                let byClass = Dictionary(grouping: fails) { displayClass($0.result.elementInfo) }
                out.append("  Issue Breakdown:")
                for cls in byClass.keys.sorted() {
                    out.append("    - \(cls): \(byClass[cls]!.count)")
                }
                out.append("  Affected Elements ( \(fails.count)):")
                for entry in fails {
                    let cls = displayClass(entry.result.elementInfo)
                    let name = elementName(entry.result.elementInfo)
                    let where_ = elementLocation(entry.result.elementInfo, captured: locationsByID[entry.result.id])
                    out.append("    • \(cls) [\(name)]\(where_.isEmpty ? "" : " — \(where_)") — Screen: \(entry.screen)")
                }
                if let fix = fails.first?.result.record.recommendation, !fix.isEmpty {
                    out.append("  Suggested Fix    : \(fix)")
                }
            }
            out.append("  ──────────────────────────────────────────────")
        }

        // ── Section 3: Complete Issue List ──────────────────────────
        out.append("")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        out.append("  3. COMPLETE ISSUE LIST")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        let allIssues = allWithScreen.filter {
            let s = $0.result.record.status.lowercased()
            return s == "fail" || s == "validate" || s == "suggestion"
        }
        if allIssues.isEmpty {
            out.append("  ✅ No issues found.")
        } else {
            for (i, entry) in allIssues.enumerated() {
                let r = entry.result
                out.append("")
                out.append("  \(i + 1). [\(r.record.status.uppercased())] \(r.record.issueVariable)")
                out.append("       Screen     : \(entry.screen)")
                out.append("       Class      : \(displayClass(r.elementInfo))")
                let loc = elementLocation(r.elementInfo, captured: locationsByID[r.id])
                out.append("       Element    : \(elementName(r.elementInfo))\(loc.isEmpty ? "" : " — \(loc)")")
                out.append("       Detail     : \(r.record.attribute)")
            }
        }

        // ── Section 4: Rule Failure Summary Table ───────────────────
        out.append("")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        out.append("  4. RULE FAILURE SUMMARY TABLE")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        let colW = 34
        let header = "  " + "Rule Name".padding(toLength: colW, withPad: " ", startingAt: 0)
                   + " UIKit Fail SwiftUI Fail      Total  Severity"
        out.append(header)
        out.append("  " + String(repeating: "-", count: 78))
        for rule in allRuleIDs {
            let entries = allByRule[rule] ?? []
            let fails   = entries.filter { $0.result.record.status.lowercased() == "fail" }
            let name    = rule.count > colW ? String(rule.prefix(colW - 1)) + "…" : rule
            let paddedName = name.padding(toLength: colW, withPad: " ", startingAt: 0)
            let sev = severity(for: rule)
            out.append("  \(paddedName) \(String(fails.count).leftPad(10)) \(String(0).leftPad(12)) \(String(fails.count).leftPad(10)) \(sev.leftPad(9))")
        }

        // ── Section 5: Top Failure Rulesets ─────────────────────────
        out.append("")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        out.append("  5. TOP FAILURE RULESETS")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        let ranked = allRuleIDs
            .map { rule -> (String, Int) in
                let f = (allByRule[rule] ?? []).filter { $0.result.record.status.lowercased() == "fail" }.count
                return (rule, f)
            }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .prefix(5)
        if ranked.isEmpty {
            out.append("  ✅ No failures detected across any ruleset.")
        } else {
            for (i, entry) in ranked.enumerated() {
                out.append("  \(i + 1). \(entry.0) → \(entry.1) failure\(entry.1 == 1 ? "" : "s")")
            }
        }

        // ── Section 6: Issue Category Summary ───────────────────────
        out.append("")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        out.append("  6. ISSUE CATEGORY SUMMARY")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        var cats: [String: Int] = [:]
        for fail in allFails {
            let cat = category(for: fail.record.issueVariable)
            cats[cat, default: 0] += 1
        }
        if cats.isEmpty {
            out.append("  ✅ No failures to categorise.")
        } else {
            for cat in cats.keys.sorted() {
                out.append("  \(cat) → \(cats[cat]!)")
            }
        }

        // ── Section 7: JSON Output ───────────────────────────────────
        out.append("")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        out.append("  7. JSON SUMMARY")
        out.append("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        var jsonRules: [[String: Any]] = []
        for rule in allRuleIDs {
            let entries = allByRule[rule] ?? []
            let fails   = entries.filter { $0.result.record.status.lowercased() == "fail" }
            let byClass = Dictionary(grouping: fails) { displayClass($0.result.elementInfo) }.mapValues { $0.count }
            let affectedElements = fails.map { entry -> [String: String] in
                [
                    "screen": entry.screen,
                    "class": displayClass(entry.result.elementInfo),
                    "element": elementName(entry.result.elementInfo),
                    "detail": entry.result.record.attribute
                ]
            }
            jsonRules.append([
                "rule": rule,
                "uikit_failures": fails.count,
                "swiftui_failures": 0,
                "total": fails.count,
                "severity": severity(for: rule),
                "issues": byClass,
                "affected_elements": affectedElements
            ])
        }
        let allIssuesJSON = allWithScreen
            .filter {
                let s = $0.result.record.status.lowercased()
                return s == "fail" || s == "validate" || s == "suggestion"
            }
            .map { entry -> [String: String] in
                [
                    "screen": entry.screen,
                    "rule": entry.result.record.issueVariable,
                    "status": entry.result.record.status,
                    "class": displayClass(entry.result.elementInfo),
                    "element": elementName(entry.result.elementInfo),
                    "detail": entry.result.record.attribute
                ]
            }
        let jsonObj: [String: Any] = [
            "total_screens": scans.count,
            "total_elements": totalElements,
            "all_issues": allIssuesJSON,
            "total_rules": allRuleIDs.count,
            "total_failures": allFails.count,
            "total_warnings": allWarnings.count,
            "total_passes": allPasses.count,
            "uikit_failures": allFails.count,
            "swiftui_failures": 0,
            "rules": jsonRules
        ]
        if let data = try? JSONSerialization.data(withJSONObject: jsonObj, options: [.prettyPrinted, .sortedKeys]),
           let jsonStr = String(data: data, encoding: .utf8) {
            out.append(jsonStr)
        }

        return out.joined(separator: "\n")
    }

    public func writeSummary() {
        guard !scans.isEmpty else { return }
        let output = formatted()
        print("\n\(output)\n")

        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let url = docsDir?.appendingPathComponent("a11y-demo-report.txt") {
            try? output.write(to: url, atomically: true, encoding: .utf8)
            print("[A11yDemo] Report saved → \(url.path)")
        }

        // Signal completion via a hidden accessibility element so a UI test can
        // wait for and read the report without needing pasteboard access.
        let reportForTest = output
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else { return }

            let signal = UILabel()
            signal.text = "ScanDone"
            signal.accessibilityIdentifier = "a11yScanDone"
            signal.accessibilityValue = reportForTest
            signal.isAccessibilityElement = true
            signal.alpha = 0.01
            signal.frame = CGRect(x: -1, y: -1, width: 1, height: 1)
            window.addSubview(signal)
        }
    }
}

// MARK: - Screen Catalogue

private struct UIKitScreenEntry {
    let name: String
    let className: String
    let make: () -> UIViewController
}

private func entry<VC: UIViewController>(_ name: String, _ makeVC: @autoclosure @escaping () -> VC) -> UIKitScreenEntry {
    UIKitScreenEntry(name: name, className: String(describing: VC.self)) { makeVC() }
}

private func allUIKitScreenEntries() -> [UIKitScreenEntry] {
    [
        entry("Pass", AccessibleNamePassViewController()),
        entry("Fail", AccessibleNameFailViewController()),
        entry("Partial", AccessibleNamePartialViewController()),
        entry("Extras Pass", AccessibleNameExtrasPassViewController()),
        entry("Extras Fail", AccessibleNameExtrasFailViewController()),
        entry("Extras Partial", AccessibleNameExtrasPartialViewController()),
    ]
}

/// Screens to scan on this launch.
///
/// The UI test has one function per screen so a single screen can be run on its own
/// (⌃⌘U on that function, or Test navigator → run just that row). Each function passes
/// `--a11y-screen=<ClassName>`; without it every screen is scanned, which is what the
/// all-screens function and a manual scheme launch do.
private func requestedScreenEntries() -> [UIKitScreenEntry] {
    let all = allUIKitScreenEntries()
    guard let arg = CommandLine.arguments.first(where: { $0.hasPrefix("--a11y-screen=") }) else {
        return all
    }
    let wanted = String(arg.dropFirst("--a11y-screen=".count))
    let matches = all.filter { $0.className == wanted }
    if matches.isEmpty {
        print("[A11yDemo] ⚠️ --a11y-screen=\(wanted) matched no screen; scanning all instead.")
        return all
    }
    return matches
}

// MARK: - Runner

@MainActor
public final class UIKitA11yScanRunner {

    public static let shared = UIKitA11yScanRunner()
    private init() {}

    private var hasRun = false

    /// SwiftUI backs several of its controls with real UIKit views — a `Menu`, `ShareLink`
    /// or a plain `Button` inside a Form row resolves to a `UIButton` underneath. That one
    /// control is therefore visible to both scan paths and gets reported twice for the same
    /// rule: once as the SwiftUI element and once as the backing view. (On the Pass screen
    /// "Save Draft" appeared as both `SwiftUIButton` and `UIButton`; on Fail an unnamed
    /// button did the same.) Where a UIKit-path finding sits on top of a SwiftUI-path
    /// finding for the same rule, the SwiftUI record is the one describing the control the
    /// developer actually wrote, so the backing-view record is dropped.
    private func removingBackingViewDuplicates(
        _ results: [AccessibilityTechniqueAnnotated],
        scrollView: UIScrollView?
    ) -> [AccessibilityTechniqueAnnotated] {
        var swiftUIRectsByRule: [String: [CGRect]] = [:]
        var swiftUINamesByRule: [String: Set<String>] = [:]
        for item in results {
            guard let cf = item.elementInfo.swiftUIContentFrame, cf != .zero else { continue }
            swiftUIRectsByRule[item.record.techniqueID, default: []].append(cf)
            let name = (item.elementInfo.accessibilityLabel ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            swiftUINamesByRule[item.record.techniqueID, default: []].insert(name)
        }
        guard !swiftUIRectsByRule.isEmpty else { return results }

        return results.filter { item in
            // SwiftUI-path records are always kept.
            if let cf = item.elementInfo.swiftUIContentFrame, cf != .zero { return true }

            let ruleID = item.record.techniqueID
            // No SwiftUI record for this rule means the UIKit path is the only thing that
            // detected it — keep it. That is how the image-button and hint-instead-of-label
            // findings survive: the SwiftUI path cannot produce them at all.
            guard let candidates = swiftUIRectsByRule[ruleID] else { return true }

            if let view = item.elementInfo.view {
                let frame = scrollView.map { $0.convert(view.bounds, from: view) } ?? view.frame
                let area = frame.width * frame.height
                if area > 0 {
                    // Majority overlap only — a screen-sized container that merely
                    // *contains* a flagged SwiftUI element must not be mistaken for it.
                    let overlapsSwiftUIElement = candidates.contains { candidate in
                        let overlap = candidate.intersection(frame)
                        guard !overlap.isNull else { return false }
                        return overlap.width * overlap.height >= area * 0.5
                    }
                    if overlapsSwiftUIElement { return false }
                }
            }

            // Geometry does not always line up — SwiftUI's backing view can be laid out at
            // a different size than the accessibility element it feeds. Fall back to the
            // name: same rule plus same accessible name on the same screen is the same
            // finding, already reported by the SwiftUI record.
            let name = (item.elementInfo.accessibilityLabel ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return !(swiftUINamesByRule[ruleID]?.contains(name) ?? false)
        }
    }

    /// Drops the "verify the name is descriptive" record from any control whose accessible
    /// name is reported as a duplicate somewhere on the same screen.
    ///
    /// The framework evaluates the duplicate check against whatever is rendered in the
    /// *current viewport*. A Form renders lazily, so when two controls sharing a name are
    /// far apart only one is laid out at a time: in that capture the control looks unique
    /// and gets BB40002 ("verify if the accessible name is descriptive"), and in a later
    /// capture — once both are laid out — it correctly gets the BB40090 duplicate Fail.
    /// The same element therefore ends up under two rules. Observed on the Fail screen:
    /// "Bin" at content frame (16, 514) carried a BB40002 row from the first capture and a
    /// BB40090 row from the capture at offset 1367. The duplicate Fail is the accurate
    /// finding, so the descriptiveness row for that name is removed.
    private func droppingDescriptivenessForDuplicateNames(
        _ results: [AccessibilityTechniqueAnnotated]
    ) -> [AccessibilityTechniqueAnnotated] {
        func name(_ item: AccessibilityTechniqueAnnotated) -> String {
            (item.elementInfo.accessibilityLabel ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let duplicatedNames = Set(
            results.filter { $0.record.techniqueID == "BB40090" }.map(name)
        ).subtracting([""])

        // Same idea for the label-in-name Fail: a button whose accessible name does not
        // match its visible label has already been judged on its name, so the "verify the
        // name is descriptive" Validate is a second row for one problem. Keyed on source
        // line, since it is the same control both times — "Submit form" on the UIKit Fail
        // screen carried both.
        let linesWithNameFail = Set(
            results.filter { $0.record.techniqueID == "BB40088" }
                   .compactMap { sourceLine($0.elementInfo) }
        )

        guard !duplicatedNames.isEmpty || !linesWithNameFail.isEmpty else { return results }

        return results.filter { item in
            guard item.record.techniqueID == "BB40002" || item.record.techniqueID == "BB40540" else { return true }
            if duplicatedNames.contains(name(item)) { return false }
            if let line = sourceLine(item.elementInfo), linesWithNameFail.contains(line) { return false }
            return true
        }
    }

    /// Drops the general "Missing accessible name for button" record when a more specific
    /// rule already describes the same control.
    ///
    /// The two findings come from different workflows — the SwiftUI path reports the
    /// generic missing name, while the UIKit path recognises *why* it is missing (an image
    /// with no description, or a hint used instead of a label). Both fired on one control,
    /// which read as a duplicate: line 51 appeared under both "Missing accessible name for
    /// button" and "Missing accessible name for image button", and line 56 under both that
    /// and "Incorrect method used to provide accessible name for Button". The specific
    /// diagnosis is the more useful one, so the general row is removed.
    private func droppingGeneralWhenSpecificExists(
        _ results: [AccessibilityTechniqueAnnotated]
    ) -> [AccessibilityTechniqueAnnotated] {
        let specificRules: Set<String> = ["BB40004", "BB40049"]
        let linesWithSpecificFinding = Set(
            results.filter { specificRules.contains($0.record.techniqueID) }
                   .compactMap { sourceLine($0.elementInfo) }
        )
        guard !linesWithSpecificFinding.isEmpty else { return results }

        return results.filter { item in
            guard item.record.techniqueID == "BB40003" else { return true }
            guard let line = sourceLine(item.elementInfo) else { return true }
            return !linesWithSpecificFinding.contains(line)
        }
    }

    /// Keeps one control in one rule family. If a source line is reported by a Button rule,
    /// any interactive-control rule row for that same line is dropped.
    ///
    /// One control can legitimately look like both to the two scan paths. On the Fail
    /// screen line 69 is `UIKitButton(title: "Archive", clearButtonTrait: true)`: the
    /// SwiftUI path sees the stripped .button trait and files it under the control rule,
    /// while the UIKit path sees a real UIButton and files it under the Button rule. Both
    /// readings are defensible on their own, but the element is a button — so the Button
    /// row is the one that stays.
    private func keepingButtonFamilyForButtons(
        _ results: [AccessibilityTechniqueAnnotated]
    ) -> [AccessibilityTechniqueAnnotated] {
        let buttonRules: Set<String> = ["BB40002", "BB40540", "BB40003", "BB40004", "BB40049", "BB40088"]
        let controlRules: Set<String> = ["BB30548", "BB30549", "BB40051", "BB40124", "BB40125"]

        let linesReportedAsButton = Set(
            results.filter { buttonRules.contains($0.record.techniqueID) }
                   .compactMap { sourceLine($0.elementInfo) }
        )
        guard !linesReportedAsButton.isEmpty else { return results }

        return results.filter { item in
            guard controlRules.contains(item.record.techniqueID),
                  let line = sourceLine(item.elementInfo) else { return true }
            return !linesReportedAsButton.contains(line)
        }
    }

    /// "Headings not defined" is a statement about the SCREEN, not about one element, so
    /// it belongs in the report once. The workflow has to attach it to some element to be
    /// reportable, and each capture picks a different one — the Fail screen produced four
    /// rows pointing at four unrelated controls. Keep the first and drop the rest.
    private func collapsingScreenLevelFindings(
        _ results: [AccessibilityTechniqueAnnotated]
    ) -> [AccessibilityTechniqueAnnotated] {
        let screenLevelRules: Set<String> = ["BB41008"]
        var alreadyReported = Set<String>()
        return results.filter { item in
            guard screenLevelRules.contains(item.record.techniqueID) else { return true }
            return alreadyReported.insert(item.record.techniqueID).inserted
        }
    }

    /// Collapses repeated VALIDATE / SUGGESTION rows that print identically in the report.
    ///
    /// A screen is scanned once per scroll position, and a SwiftUI Form re-lays-out as it
    /// scrolls, so one control can be measured at two different content-space positions and
    /// survive the position-based dedup twice — the same "Verify if accessible name for
    /// button is descriptive / Open settings" line appearing twice.
    ///
    /// Only manual-review rows are collapsed, on the exact fields the report prints (rule,
    /// class, element name, detail). If two of those rows are identical there is nothing to
    /// tell them apart on screen, so keeping both only adds noise. FAIL and PASS rows are
    /// left untouched: repeats there are real and countable — three unnamed buttons should
    /// stay three findings even though all three print as "no name".

    private func collapsingRepeatedValidateRows(
        _ results: [AccessibilityTechniqueAnnotated]
    ) -> [AccessibilityTechniqueAnnotated] {
        var seenValidateRows = Set<String>()
        return results.filter { item in
            let status = item.record.status.lowercased()
            guard status == "validate" || status == "suggestion" else { return true }

            let info = item.elementInfo
            let row = [
                item.record.techniqueID,
                item.record.issueVariable,
                info.className,
                String(info.accessibilityTraits),
                info.accessibilityLabel ?? "",
                item.record.attribute
            ].joined(separator: "|")
            return seenValidateRows.insert(row).inserted
        }
    }

    /// The same 12 accessible-name rules the SwiftUI checker reports. Everything else the
    /// workflows emit (heading checks, image-label checks, trait checks, …) is filtered out
    /// so both apps produce comparable output.
    private let allowedTechniqueIDs: Set<String> = [
        "BB40002", "BB40540",   // Verify if accessible name for button is descriptive
        "BB40003",              // Missing accessible name for button (UIButton only)
        "BB40004",              // Missing accessible name for image button
        "BB40049",              // Incorrect method used to provide accessible name for Button
        "BB40088",              // Accessible name for button and its visual label don't match
        "BB40090",              // Interactive elements have identical accessible name
        "BB30548",              // Missing accessible name for interactive control
        "BB30549",              // Incorrect method used to provide accessible name for interactive control
        "BB40124",              // Non-descriptive accessible name for interactive control
        "BB40042",              // Text functions as a link but is missing role link

        // For role — Heading
        // "BB40040" — heading role check, disabled at the user's request. SwiftUI gives
        // every Section header the heading trait, so this asked for manual confirmation
        // of ~55 section titles per run. Re-enable together with the emission in
        // HeadingQualityWorkflow.validateSwiftUIHeadingRoles.
        "BB40041",              // Check whether the text should be a heading
//        "BB41008",              // Headings not defined — disabled, see HeadingQualityWorkflow

        "BB40125",              // Accessible name for interactive element is descriptive

        // For role — Button
        "BB40001",              // Verify if button does not require interaction
        "BB40043",              // Text functions as a button but is missing role button
        "BB41004",              // Missing role for button
        "BB40051",              // Check if interactive control name is descriptive
        // Composite controls whose children are the accessibility elements — a compact
        // DatePicker is the case that matters here. SwiftUI builds their inner elements
        // only when an assistive client focuses them, so an in-process scan sees nothing
        // to check and the control would drop out of the report entirely. The framework
        // does still see the backing view and raises this manual-check row against it,
        // carrying the control's name and source line, so nothing goes unreported.
        "BB40546",              // Check if interactive controls needs to be hidden from screen reader user
    ]

    /// Finds the nearest scrollable view so content below the fold can be scrolled into
    /// view and scanned — the UIKit screens use a UIScrollView for their long forms.
    private func findScrollView(in view: UIView) -> UIScrollView? {
        var queue = view.subviews
        while !queue.isEmpty {
            let current = queue.removeFirst()
            if let sv = current as? UIScrollView, sv.isScrollEnabled { return sv }
            queue.append(contentsOf: current.subviews)
        }
        return nil
    }

    /// `Int(_:)` traps on a non-finite or out-of-range Double, and a frame is not
    /// guaranteed finite — a view that has not been laid out can report `CGRect.null`,
    /// whose origin is infinity. Collapse those to a placeholder instead of crashing.
    private func component(_ value: CGFloat) -> String {
        guard value.isFinite, value > -1_000_000_000, value < 1_000_000_000 else { return "~" }
        return String(Int(value.rounded()))
    }

    private func rectKey(_ rect: CGRect) -> String {
        "\(component(rect.origin.x))|\(component(rect.origin.y))|\(component(rect.size.width))|\(component(rect.size.height))"
    }

    /// Distinct findings must survive de-duplication across scroll positions. Keying on
    /// the view's position in the scroll view's content space is scroll-invariant, so two
    /// identical unnamed controls stay two findings rather than collapsing into one.
    /// Source line of the control, if it tagged itself — a stronger identity than position.
    private func sourceLine(_ info: AccessibilityElementInfo) -> String? {
        if let id = info.accessibilityIdentifier, id.hasPrefix("src:") { return String(id.dropFirst(4)) }
        if let id = info.view?.accessibilityIdentifier, id.hasPrefix("src:") { return String(id.dropFirst(4)) }
        return nil
    }

    private func dedupKey(for item: AccessibilityTechniqueAnnotated, scrollView: UIScrollView?) -> String {
        let info = item.elementInfo

        // Prefer the source line, keeping x/width/height but not y — y is the component
        // that drifts when a scroll view re-lays-out, and controls built in a loop (the
        // five rating stars, all one line) sit side by side so their x keeps them apart.
        if let line = sourceLine(info) {
            // Only x is kept from the frame. y drifts when the scroll view re-lays-out,
            // and width/height drift too — the TextEditor on the Fail screen reported a
            // 338×100 frame in one capture and 338×5 in another, so including size split
            // one control into two findings. x is stable and is what separates controls
            // built side by side in a loop (the rating stars share a line but not an x).
            // x is bucketed rather than exact. It is here only to separate controls built
            // side by side in a loop (the rating stars share a source line but sit ~30pt
            // apart); an exact value also split ONE control across captures when its x
            // drifted by a few points during layout — the TextEditor on the Partial screen
            // reported line 108 twice. A 20pt bucket keeps loop siblings apart while
            // absorbing that drift.
            let rect = info.swiftUIContentFrame ?? info.swiftUIFrame ?? info.view?.frame
            let column = rect.map { r -> String in
                guard r.origin.x.isFinite else { return "~" }
                return String(Int((r.origin.x / 20).rounded()))
            } ?? ""
            return "\(item.record.techniqueID)|src:\(line)|\(info.accessibilityLabel ?? "")|\(column)"
        }
        if let view = info.view {
            let frame = scrollView.map { $0.convert(view.bounds, from: view) } ?? view.frame
            return "\(item.record.techniqueID)|\(info.className)|\(rectKey(frame))"
        }
        return "\(item.record.techniqueID)|\(info.className)|\(info.accessibilityLabel ?? "")"
    }

    /// "Elements Tested" counts interactive controls only — the same basis the SwiftUI
    /// checker uses, so the two reports' counts mean the same thing. Labels, images and
    /// other presentational views are VoiceOver stops but not controls.
    private func interactiveControls(in root: UIView) -> [UIView] {
        var result: [UIView] = []

        func walk(_ view: UIView) {
            if view.isHidden || view.alpha < 0.01 { return }
            if String(describing: type(of: view)).hasPrefix("_") { return }

            let isControl = view is UIControl
                || view is UITextView
                || view is UISearchBar
                || view is UIPickerView
            let isTappableView = view.isUserInteractionEnabled
                && (view.gestureRecognizers?.contains { $0 is UITapGestureRecognizer } ?? false)

            // Plain scroll views are containers, not controls — but UITextView is a
            // UIScrollView subclass, so a bare `view is UIScrollView` test silently
            // dropped every text editor from the count (the Pass screen reported 21
            // controls instead of 22, with notesTextView missing).
            let isPlainScrollContainer = (view is UIScrollView) && !(view is UITextView)
            if (isControl || isTappableView), !isPlainScrollContainer {
                result.append(view)
            }

            for subview in view.subviews { walk(subview) }
        }

        walk(root)
        return result
    }

    private func elementKey(_ view: UIView, scrollView: UIScrollView?) -> String {
        let frame = scrollView.map { $0.convert(view.bounds, from: view) } ?? view.frame
        return "\(String(describing: type(of: view)))|\(rectKey(frame))"
    }

    /// Reads the source line an element recorded on itself, at scan time. Captured here
    /// rather than in the reporter because `elementInfo.view` is weak — by the time the
    /// summary is written the screen has been torn down and the view is gone.
    private func capturedLocation(for item: AccessibilityTechniqueAnnotated, scrollView: UIScrollView?) -> String {
        var own: String? = nil
        if let id = item.elementInfo.accessibilityIdentifier, id.hasPrefix("src:") {
            own = String(id.dropFirst(4))
        } else if let id = item.elementInfo.view?.accessibilityIdentifier, id.hasPrefix("src:") {
            own = String(id.dropFirst(4))
        }
        guard let own else { return "" }

        // A control built inside a shared component reports that component's internals —
        // the five rating stars all come from one loop in PlainRatingControl, which lives
        // in the Partial view controller even when the Fail screen renders it. That line is
        // accurate but useless here: it is not on the screen being scanned. Report the
        // nearest enclosing tagged view instead — the property that placed the component
        // on THIS screen, which is the line you would actually edit.
        var ancestor = item.elementInfo.view?.superview
        while let view = ancestor {
            if let id = view.accessibilityIdentifier, id.hasPrefix("src:") {
                return String(id.dropFirst(4))
            }
            ancestor = view.superview
        }
        return own
    }

    private func runWorkflows(on view: UIView) -> [AccessibilityTechniqueAnnotated] {
        let nameQualityWorkflow = ElementNameQualityWorkflow()
        nameQualityWorkflow.validateAllElements(in: view)

        let sufficientDescriptionWorkflow = SufficientElementDescriptionWorkFlow()
        sufficientDescriptionWorkflow.validateAllElements(in: view)

        let buttonWorkflow = UIButtonAccessibilityWorkflow()
        buttonWorkflow.validateAllButtons(in: view)

        let labelInNameWorkflow = LabelInNameWorkflow()
        labelInNameWorkflow.validateAllElements(in: view)

        let traitsWorkflow = AccessibilityTraitsWorkflow()
        traitsWorkflow.validateAllElements(in: view)

        // Heading role rules live in their own workflow — driven here so the UIKit report
        // covers the same rulesets as the SwiftUI one.
        let headingWorkflow = HeadingQualityWorkflow()
        headingWorkflow.validateAllElements(in: view)

        let combined = nameQualityWorkflow.matchedTechniqueRecords
            + sufficientDescriptionWorkflow.matchedTechniqueRecords
            + buttonWorkflow.matchedTechniqueRecords
            + labelInNameWorkflow.matchedTechniqueRecords
            + traitsWorkflow.matchedTechniqueRecords
            + headingWorkflow.matchedTechniqueRecords

        return combined.filter { allowedTechniqueIDs.contains($0.record.techniqueID) }
    }

    /// Swaps the key window's root view controller through every example screen, scans
    /// each, then restores the original root and writes the combined summary.
    /// Idempotent — later calls are no-ops.
    public func runAllScreens() async {
        guard !hasRun else { return }
        hasRun = true

        print("[A11yDemo] Starting full UIKit accessible-name example scan…")

        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            print("[A11yDemo] ⚠️ No key window found — aborting scan.")
            return
        }

        let originalRootVC = window.rootViewController
        let reporter = UIKitDemoA11ySummaryReporter.shared
        reporter.reset()

        for entry in requestedScreenEntries() {
            let viewController = entry.make()
            viewController.view.frame = window.bounds
            window.rootViewController = viewController
            window.layoutIfNeeded()

            // Let the layout pass settle before walking the hierarchy.
            try? await Task.sleep(nanoseconds: 300_000_000)
            window.layoutIfNeeded()

            var combinedResults: [AccessibilityTechniqueAnnotated] = []
            var seenResultKeys = Set<String>()
            var seenElementKeys = Set<String>()
            var capturedLocations: [String: String] = [:]

            let scrollView = findScrollView(in: viewController.view)

            func captureCurrentViewport() async {
                window.layoutIfNeeded()
                try? await Task.sleep(nanoseconds: 200_000_000)
                window.layoutIfNeeded()

                for item in runWorkflows(on: viewController.view) {
                    let key = dedupKey(for: item, scrollView: scrollView)
                    if seenResultKeys.insert(key).inserted {
                        combinedResults.append(item)
                        capturedLocations[item.id] = capturedLocation(for: item, scrollView: scrollView)
                    }
                }

                for control in interactiveControls(in: viewController.view) {
                    seenElementKeys.insert(elementKey(control, scrollView: scrollView))
                }
            }

            await captureCurrentViewport()

            // Step through the scrollable range so controls below the fold are scanned
            // too. UIKit keeps its views alive off-screen, but scrolling also lets any
            // lazily-configured content lay out before it is inspected.
            if let scrollView {
                let viewportHeight = scrollView.bounds.height
                if viewportHeight > 0 {
                    let step = viewportHeight * 0.7
                    var offset: CGFloat = step
                    var lastReachedOffset: CGFloat = scrollView.contentOffset.y

                    // contentSize is re-read every iteration rather than captured once, so
                    // content that only lays out as it scrolls into view is still swept to
                    // the end instead of stopping at the height known at the top.
                    while offset < scrollView.contentSize.height {
                        let maxOffset = max(0, scrollView.contentSize.height - viewportHeight)
                        let clamped = min(offset, maxOffset)
                        scrollView.setContentOffset(CGPoint(x: 0, y: clamped), animated: false)
                        await captureCurrentViewport()
                        if clamped <= lastReachedOffset { break }
                        lastReachedOffset = clamped
                        offset += step
                    }

                    let finalBottom = max(0, scrollView.contentSize.height - viewportHeight)
                    if finalBottom > lastReachedOffset {
                        scrollView.setContentOffset(CGPoint(x: 0, y: finalBottom), animated: false)
                        await captureCurrentViewport()
                    }
                    scrollView.setContentOffset(.zero, animated: false)
                }
            }

            let elementCount = seenElementKeys.count

            // Same post-processing chain as the SwiftUI runner, in the same order, so both
            // reports are shaped by identical rules.
            let deduped = removingBackingViewDuplicates(combinedResults, scrollView: scrollView)
            let screenLevel = collapsingScreenLevelFindings(deduped)
            let oneFamily = keepingButtonFamilyForButtons(screenLevel)
            let specificOnly = droppingGeneralWhenSpecificExists(oneFamily)
            let singleRuled = droppingDescriptivenessForDuplicateNames(specificOnly)
            let screenResults = collapsingRepeatedValidateRows(singleRuled)

            reporter.addScan(
                screenName: entry.name,
                screenClass: entry.className,
                elementCount: elementCount,
                results: screenResults,
                locations: capturedLocations
            )

            let failCount = screenResults.filter { $0.record.status.lowercased() == "fail" }.count
            let ruleCount = Set(screenResults.map { $0.record.issueVariable }).count
            print("[A11yDemo] ✓ \(entry.name) — \(elementCount) elements, \(ruleCount) rules, \(failCount) failures")
        }

        window.rootViewController = originalRootVC
        window.layoutIfNeeded()

        reporter.writeSummary()
    }
}
