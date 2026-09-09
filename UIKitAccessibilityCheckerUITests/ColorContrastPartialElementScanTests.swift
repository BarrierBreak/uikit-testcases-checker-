//
//  ColorContrastPartialElementScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  Element-level coverage for the two Colour Contrast PARTIAL screens.
//
//  This is the tier that decides whether the ruleset is worth having. Nothing on either
//  screen is glaringly low contrast — every sample is readable to most sighted users in good
//  light, which is why this kind of defect survives design review and ships. They fail on the
//  arithmetic, and most fail by a margin small enough that a checker with sloppy rounding or
//  a wrong size threshold reports them as passing.
//
//  Three kinds of near-miss are represented, and they ask different things of the rule:
//
//    • ROUNDING — 4.478:1 and 2.995:1 are below their thresholds. Round to one decimal
//      before comparing and both become 4.5 and 3.0 and pass. Compare at full precision;
//      round for display only.
//    • THRESHOLD — whether text is "large" decides which bar applies, and the rule is easy
//      to get wrong. Bold alone does not make text large: it must be 14pt AND bold.
//    • EXEMPTION — placeholder text looks like a hint and is frequently treated as exempt.
//      It is not: it is real text in an active field and carries the full 4.5:1.
//
//  The solid screen is where the thresholds can be pinned exactly, because UIKit exposes the
//  font and large-vs-normal is therefore a fact rather than an inference. That is what makes
//  `assertContrast(is:)` usable here at all, and why a wrong-threshold regression shows up as
//  a specific rule mismatch rather than as a missing row.
//
import XCTest

final class ColorContrastPartialElementScanTests: XCTestCase {

    private let solidScreen = "AccessibleTextContrastPartialViewController"
    private let compositedScreen = "AccessibleTextContrastCompositedPartialViewController"

    // MARK: - Rounding

    /// Row 1 — 4.478:1, twenty-two thousandths under the 4.5:1 bar for normal text.
    ///
    /// Visually indistinguishable from the Pass screen's 4.54:1 sample, and the single most
    /// common false negative in contrast tooling: rounding to one decimal turns it into 4.5
    /// and passes it.
    func testContrastPartial_bodyTextJustUnderAA_fails() throws {
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "The quick brown fox")
    }

    /// Row 2 — 2.995:1 at 18pt, five thousandths under the 3:1 bar for large text.
    ///
    /// The same rounding trap at the other threshold, and it also pins the classification:
    /// this has to come back as the LARGE-text rule. Getting `normalFail` here would be the
    /// right verdict reached by the wrong route, and would mean an 18pt sample sitting between
    /// 3:1 and 4.5:1 gets reported when it should pass.
    func testContrastPartial_largeTextJustUnderTheLargeBar_failsAsLargeText() throws {
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.largeFail,
                       forElementContaining: "Large headline text")
    }

    // MARK: - Threshold classification

    /// Row 3 — the bold trap. 13pt bold is NOT large text: WCAG requires 14pt or larger when
    /// bold, and bold alone does not qualify.
    ///
    /// This is the most valuable assertion on the screen. A rule that treats any bold text as
    /// large applies 3:1, sees 3.44:1, and passes it — while passing every other test in this
    /// file. The correct threshold is 4.5:1, which it fails, so the assertion is on the rule
    /// and not merely on the presence of a failure.
    func testContrastPartial_boldButUnder14pt_isNotTreatedAsLargeText() throws {
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Bold, but only 13pt")
    }

    /// Rows 5 and 9 — a greyed-out caption at 3.44:1 and the stock system red at 3.55:1.
    ///
    /// Both are normal text, both are under 4.5:1, and both are shapes designers reach for
    /// deliberately: "secondary" as licence to lighten, and the platform's own error colour
    /// taken on trust because it ships with the system.
    func testContrastPartial_secondaryCaptionAndSystemRed_failAsNormalText() throws {
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Last updated 3 minutes ago")
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Enter a valid email address")
    }

    /// Row 8 — an 11pt badge on a mid-tone brand blue, 3.87:1.
    ///
    /// Small text has no relaxation, so 4.5:1 applies and this misses it. The same colour
    /// pair is used by the button in row 4, which is the point: identical colours, different
    /// verdicts, decided entirely by the text's size and weight.
    func testContrastPartial_badgeAt11pt_failsAsNormalText() throws {
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail, forElementContaining: "3 NEW")
    }

    // MARK: - Exemptions that do not apply

    /// Row 10 — placeholder text at 3.44:1.
    ///
    /// The counterpart to the Pass screen's disabled control. A disabled control IS exempt
    /// under 1.4.3; a placeholder is NOT — it is real text in an active field and carries the
    /// full 4.5:1. It is frequently mistaken for exempt because it reads as a hint, and
    /// UIKit's own default placeholder colour does not meet AA. A ruleset that exempts
    /// placeholders is under-reporting, and this is the row that proves it does not.
    func testContrastPartial_placeholderText_isNotExempt() throws {
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Email address")
    }

    // MARK: - Ratios that are correct at AA

    /// Rows 6 and 7 — 4.95:1 and 5.33:1. Both clear 1.4.3 AA and both fall short of 1.4.6
    /// AAA at 7:1.
    ///
    /// The scan reports against AA, so these must NOT be failures. They are the screen's
    /// false-positive guard: a rule that quietly applied the AAA bar would flag them, and
    /// every other assertion in this file would still pass.
    func testContrastPartial_ratiosThatPassAAButNotAAA_areNotReportedAsFailures() throws {
        let issues = try runScan(screen: solidScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "Arriving Thursday")
        assertContrastPasses(issues, forElementContaining: "CONNECTIVITY")
    }

    // MARK: - Composited

    /// Row 2 — a panel at 0.6 alpha composites #1C1C1E over white to about #777778, leaving
    /// white text at 4.47:1: three hundredths under AA.
    ///
    /// The panel looks solidly dark and is not. Reading the assigned colour gives 17:1.
    func testCompositedPartial_backgroundAlpha_failsByAHairOnceComposited() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "White text on a translucent panel")
    }

    /// Row 3 — two 0.4-alpha dark layers over white.
    ///
    /// Each layer is individually plausible and the pair does not compose to a dark
    /// background: they resolve to a mid grey, and white text on it falls short. Resolving
    /// only the immediate parent gives a passing answer, which is the specific mistake this
    /// row exists to catch.
    func testCompositedPartial_twoStackedLayers_areFullyResolved() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Text over two translucent layers")
    }

    /// Row 9 — a label that never consults `accessibilityContrast`, sitting at 3.44:1 in both
    /// states.
    ///
    /// A user who turns Increase Contrast on to cope gets no change at all. The scan runs with
    /// the setting off, so what is asserted is the ratio itself — already a failure before the
    /// unresponsiveness is considered.
    func testCompositedPartial_ignoresIncreaseContrast_failsOnItsRatioAlone() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Ignores Increase Contrast")
    }

    /// Row 7 — a photo with a 30% scrim, 3.11:1 at its worst point.
    ///
    /// A scrim that exists is easily mistaken for a scrim that is sufficient. As with the Fail
    /// screen's image row, the verdict is not pinned: the ratio varies across the image, so
    /// what is assertable is that the caption was measured rather than skipped for sitting on
    /// something with no background colour to read.
    func testCompositedPartial_weakScrimOverImage_isNotSkipped() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrastIsReported(issues, forElementContaining: "Caption over a photo")
    }

    // MARK: - Known gaps

    /// Row 4 — white on #2F80ED at 3.87:1, on a 17pt SEMIBOLD button title.
    ///
    /// WCAG's large-text relaxation is 18pt or larger, or 14pt or larger when BOLD. 17pt
    /// semibold is neither, so the bar is 4.5:1 and 3.87:1 fails it. The rule reads
    /// `symbolicTraits.contains(.traitBold)`, and UIKit sets that trait for semibold as well
    /// as bold — so the title is classified as large text, measured against 3:1, and passes.
    ///
    /// The consequence is not cosmetic. On the Fail screen the same misclassification only
    /// changes which failure is reported, because 2.22:1 is under both bars. Here it changes
    /// the verdict outright, which is why this row is the one the fixture calls "large-only"
    /// and why it belongs in the Partial tier rather than the Fail one.
    func testCompositedPartial_semiboldButtonTitle_shouldNotCountAsLargeText() throws {
        XCTExpectFailure("17pt semibold is classified as large text because UIKit reports "
                         + ".traitBold for semibold, so 3.87:1 is measured against 3:1 and "
                         + "passes instead of failing the 4.5:1 normal-text bar.")
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail, forElementContaining: "Continue")
    }
}
