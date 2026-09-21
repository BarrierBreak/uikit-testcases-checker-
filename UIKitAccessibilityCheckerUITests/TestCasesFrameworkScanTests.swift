//
//  TestCasesFrameworkScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  End-to-end coverage for A11yInspectTestCases embedded in this app: it builds, links
//  alongside the original framework, scans, and can be narrowed to one rule family at a time.
//
//  The framework's own unit tests (A11yInspectTestCasesTests) pin the rule set and the
//  database. What only a demo-app run can prove is the integration — that two frameworks
//  defining the same type names coexist in one binary, that this one is addressable on its
//  own, and that `--a11y-testcases-family=` actually narrows what comes back.
//
import XCTest

final class TestCasesFrameworkScanTests: XCTestCase {

    /// `A11yScanEngine` adds one manual-review row per tested element, using BB40051's
    /// record as the template, and adds it OUTSIDE the technique-ID filter — deliberately, so
    /// that an element no automated rule reported still appears in the report.
    ///
    /// It therefore shows up in every scan whatever family was asked for, and is not evidence
    /// that the narrowing failed. Every assertion below subtracts it first.
    private let manualReviewTitle = "Check if interactive control name is descriptive"

    /// A screen that reliably exercises each family.
    private let familyProbeScreen: [String: String] = [
        "role": "AccessibleRoleFailViewController",
        "keyboard": "AccessibleKeyboardFailViewController",
        "state": "AccessibleStateFailViewController",
        "targetSize": "AccessibleTargetSizeFailViewController",
        "colourContrast": "AccessibleTextContrastFailViewController",
        "name": "AccessibleNameFailViewController",
        // No demo screen is built to clip text, so this family reports only its pass rows
        // here. That still exercises the whole path — workflow, rule set, database row and
        // report — which is what these integration tests are for; the clipping failure
        // itself is covered by TextRuleBehaviourTests in the framework.
        "textClipping": "AccessibleNameFailViewController",
        "textResize": "AccessibleNameFailViewController",
    ]

    // MARK: - The framework runs at all

    /// The integration test. If the xcframework is not linked, not embedded, or its launch
    /// argument does not reach it, the scan never signals and this fails on the timeout.
    func testTestCasesFramework_scansAndReportsFindings() throws {
        let issues = try runScan(screen: "AccessibleRoleFailViewController", includePasses: true)
        XCTAssertFalse(
            issues.isEmpty,
            "A11yInspectTestCases produced no rows — check the xcframework is embedded and UIKitTestCasesScan is wired into SceneDelegate"
        )
    }

    // MARK: - Every family can be scanned on its own

    /// Each family, narrowed with `--a11y-testcases-family=`, has to produce rows on a screen
    /// built to fail it. A family that silently returns nothing would make its per-family test
    /// suite vacuous.
    func testEveryFamily_reportsOnItsOwnFailScreen() throws {
        var silent: [String] = []
        for (family, screen) in familyProbeScreen {
            let rows = try runScan(screen: screen, family: family, includePasses: true)
                .filter { $0.rule != manualReviewTitle }
            if rows.isEmpty { silent.append("\(family) on \(screen)") }
        }
        XCTAssertTrue(
            silent.isEmpty,
            "These families reported nothing of their own — only the universal manual-review row: \(silent)"
        )
    }

    /// The narrowing actually narrows.
    ///
    /// Asserted as pairwise disjointness rather than against a hardcoded list of titles:
    /// scanning one screen for two different families must return two sets of rules with
    /// nothing in common. That tests the real property without this file having to carry a
    /// copy of every rule's wording, which drifts the moment a row is reworded.
    ///
    /// Without it, `--a11y-testcases-family=` could be ignored entirely and every other
    /// assertion here would still pass.
    func testFamilyScans_returnDisjointRules() throws {
        let screen = "AccessibleRoleFailViewController"
        var byFamily: [String: Set<String>] = [:]
        for family in familyProbeScreen.keys {
            byFamily[family] = Set(
                try runScan(screen: screen, family: family, includePasses: true).map(\.rule)
            ).subtracting([manualReviewTitle])
        }

        let names = byFamily.keys.sorted()
        for i in names.indices {
            for j in names.indices where j > i {
                let overlap = byFamily[names[i]]!.intersection(byFamily[names[j]]!)
                XCTAssertTrue(
                    overlap.isEmpty,
                    "Scanning \(screen) for '\(names[i])' and for '\(names[j])' both returned: \(overlap.sorted())"
                )
            }
        }
    }

    /// The two text families, end to end. Both were dead before: BB40033 had no database row
    /// at all, so every clipping finding the workflow raised was dropped by `printBBRecord`,
    /// and neither TextClippingWorkflow nor DynamicTypeWorkflow was wired into the scan engine.
    func testTextFamilies_reportOnARealScreen() throws {
        let resize = Set(try runScan(screen: "AccessibleNameFailViewController",
                                     family: "textResize", includePasses: true).map(\.rule))
            .subtracting([manualReviewTitle])
        XCTAssertTrue(resize.contains("Text fails to resize"),
                      "Labels with a fixed font size should fail 1.4.4. Saw: \(resize.sorted())")

        let clipping = Set(try runScan(screen: "AccessibleNameFailViewController",
                                       family: "textClipping", includePasses: true).map(\.rule))
            .subtracting([manualReviewTitle])
        XCTAssertTrue(clipping.contains("Text is not getting clipped"),
                      "Text that fits should report the clipping pass. Saw: \(clipping.sorted())")
    }

    /// A full scan has to be a superset of a narrowed one — otherwise the family sets and the
    /// default set have drifted apart.
    func testFullScan_includesWhatAFamilyScanFinds() throws {
        let screen = "AccessibleKeyboardFailViewController"
        let keyboardOnly = Set(try runScan(screen: screen, family: "keyboard", includePasses: true).map(\.rule))
            .subtracting([manualReviewTitle])
        let everything = Set(try runScan(screen: screen, includePasses: true).map(\.rule))

        XCTAssertFalse(keyboardOnly.isEmpty, "The keyboard family found nothing to compare")
        XCTAssertTrue(
            keyboardOnly.isSubset(of: everything),
            "A keyboard-only scan found rules a full scan missed: \(keyboardOnly.subtracting(everything).sorted())"
        )
    }

    /// An unknown family name falls back to the full rule set rather than scanning nothing —
    /// a silent empty report and an argument that never arrived look identical from a test.
    func testUnknownFamilyName_fallsBackToTheFullRuleSet() throws {
        let rows = try runScan(screen: "AccessibleRoleFailViewController",
                                        family: "nonsense", includePasses: true)
        XCTAssertFalse(rows.isEmpty, "An unknown family should scan everything, not nothing")
    }
}
