//
//  ColorContrastFailElementScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  Element-level coverage for the two Colour Contrast FAIL screens — the solid-background
//  tier and the composited tier — using the shared vocabulary in ColorContrastScanAssertions.
//
//  The two screens fail for different reasons, and that difference is the whole point of
//  splitting them:
//
//    • AccessibleTextContrastFailViewController pairs two OPAQUE colours. The ratio is
//      arithmetic on two known values, so every row here is a statement about whether the
//      rule can do the arithmetic and pick the right threshold.
//    • AccessibleTextContrastCompositedFailViewController pairs colours that are not the
//      ones written in the source — alpha, stacked translucent layers, materials and
//      appearance-dependent colours all mean the EFFECTIVE colour has to be resolved first.
//      Three of its rows read as the highest-contrast pairings on the screen if the assigned
//      colour is used instead of the composited one, so a checker that skips compositing
//      does not merely lose precision here, it reports the three worst rows as the three
//      best.
//
//  Both screens are built so every ratio is below 3:1 — the LARGE-text floor — so no row
//  depends on getting the large-vs-normal classification right in order to be a failure.
//  That is deliberate: it keeps "did the rule catch it" separate from "did the rule pick the
//  right threshold", and the latter is what the Partial suite is for.
//
import XCTest

final class ColorContrastFailElementScanTests: XCTestCase {

    private let solidScreen = "AccessibleTextContrastFailViewController"
    private let compositedScreen = "AccessibleTextContrastCompositedFailViewController"

    // MARK: - Solid backgrounds

    /// Rows 1–3: one colour at three sizes and weights. 2.07:1 is under the large-text floor,
    /// so none of the three is rescued by size — and the three together prove the rule is
    /// applying a floor rather than an exemption.
    ///
    /// The rules differ across them and that is correct, not an inconsistency: 17pt regular is
    /// normal text, while 18pt regular and 14pt bold are both large text. Same colour, same
    /// ratio, two different rules — which is exactly the classification this asserts.
    func testTextContrastFail_sameColourAtThreeSizes_allFail() throws {
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "The quick brown fox")
        assertContrast(issues, is: ColorContrastRule.largeFail,
                       forElementContaining: "Large headline text")
        assertContrast(issues, is: ColorContrastRule.largeFail,
                       forElementContaining: "Bold 14pt is large text and still fails")
    }

    /// Rows 5, 6 and 9 — caption, link and error text, all normal text under 4.5:1.
    ///
    /// Error text is the one that matters most in practice: it is what the user has to read
    /// to recover from a mistake, and a washed-out red that reads as pink is the most common
    /// place for a marginal ratio to do real damage.
    func testTextContrastFail_captionLinkAndError_failAsNormalText() throws {
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Last updated 3 minutes ago")
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "View documentation")
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Enter a valid email address")
    }

    /// Row 7 — dark text on a dark panel, 2.48:1.
    ///
    /// The inverted polarity is the test. A rule that samples the text colour and assumes a
    /// light background, or that hardcodes white as the comparison, passes this row while
    /// catching every other one on the screen.
    func testTextContrastFail_darkOnDark_isCaught() throws {
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Dark text on a dark panel")
    }

    /// Row 8 — an 11pt badge on a pale tint, 1.90:1, the worst ratio on the screen.
    ///
    /// The badge is a label inside a coloured container, so the ratio is against the
    /// CONTAINER's fill rather than the screen background. Getting the white page instead
    /// would compute 1.00:1 — still a failure, so the verdict alone cannot tell the two
    /// apart; what makes this row worth asserting is that it is measured at all, since a
    /// nested label is easy to miss in traversal.
    func testTextContrastFail_badgeOnTint_isCaught() throws {
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail, forElementContaining: "3 NEW")
    }

    /// Row 10 — white on white, 1.00:1.
    ///
    /// Invisible text is still in the accessibility tree and still announced by VoiceOver, so
    /// the element exists to be measured even though nothing is visible. This is the shape a
    /// real theme regression takes when one colour is updated and the other is not.
    func testTextContrastFail_invisibleText_isStillMeasuredAndFails() throws {
        let issues = try runScan(screen: solidScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "This paragraph is invisible")
    }

    /// The screen's own scenario controls, counted.
    ///
    /// Counting only the tagged rows is what makes this stable: the row captions above each
    /// sample are text too and get measured as well, so a raw count of contrast rows counts
    /// the fixture's scaffolding alongside its subjects. Every tagged control on this screen
    /// is meant to fail, so the count and the verdict are asserted together — a row that
    /// quietly turned into a pass would keep the count right and still be wrong.
    func testTextContrastFail_everyTaggedControlIsAFailure() throws {
        let issues = try runScan(screen: solidScreen)
        let tagged = taggedContrastRows(issues, sourceFile: "\(solidScreen).swift")
        XCTAssertEqual(tagged.count, 10,
                       "Expected all ten tagged controls to be reported, got: \(tagged.map(\.element))")
        XCTAssertTrue(tagged.allSatisfy { ColorContrastRule.failures.contains($0.rule) },
                      "Every control on the Fail screen should be a contrast failure, got: "
                      + "\(tagged.map { "\($0.rule) — \($0.element)" })")
    }

    // MARK: - Composited backgrounds

    /// Row 2 — white on a panel whose background is #1C1C1E at 0.4 alpha over white.
    ///
    /// The assigned pairing is white on near-black, which is 17:1 and one of the highest
    /// numbers on the screen. Composited, the panel resolves to about #A4A4A5 and the real
    /// ratio is 2.49:1. Reading the assigned colour does not give a slightly optimistic
    /// answer here; it gives the opposite answer.
    func testCompositedFail_backgroundAlpha_isResolvedNotTakenAsAssigned() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "White text on a translucent panel")
    }

    /// Row 3 — three stacked translucent layers over white.
    ///
    /// The effective background is the composite of all three plus the opaque view behind
    /// them. Resolving only the immediate parent — the innermost layer, at 0.1 alpha — reads
    /// as very nearly white and gives a wildly wrong answer for white text on it. The chain
    /// has to be walked to the first opaque ancestor.
    func testCompositedFail_stackedLayers_areResolvedToTheOpaqueAncestor() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Text over three translucent layers")
    }

    /// Row 4 — light grey on a light blur material, 2.38:1.
    ///
    /// A UIVisualEffectView has no backgroundColor to read, so the material has to be
    /// resolved to the colour it actually renders as rather than skipped for having no
    /// colour set.
    func testCompositedFail_blurMaterial_isMeasured() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Text over a blur material")
    }

    /// Row 8 — a dynamic colour whose light and dark branches are inverted, so dark mode gets
    /// 2.48:1 while light mode gets 4.54:1.
    ///
    /// The scan runs in light mode, where this label sits on an opaque near-black panel, so
    /// the light-mode branch is measured against a dark background and fails there too. That
    /// is what makes the row assertable at all: the inverted-branch defect itself only shows
    /// up in dark mode, which this scan does not enter.
    func testCompositedFail_appearanceDependentColour_isMeasured() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Darker in dark mode")
    }

    /// Row 9 — Increase Contrast handled backwards.
    ///
    /// The screen reads `traitCollection.accessibilityContrast` correctly and then moves the
    /// colour the WRONG way, taking the text from 3.44:1 to 2.07:1 when the setting is turned
    /// on. The scan runs with the setting off, so what is asserted here is the 3.44:1 state —
    /// already a normal-text failure before the accessibility setting makes it worse.
    func testCompositedFail_invertedHighContrast_failsEvenBeforeTheSettingIsOn() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Lightens when Increase Contrast is on")
    }

    /// Row 10 — 2.10:1, which fails at every content size.
    ///
    /// The font is built through UIFontMetrics, so its rendered size is not the 17pt in the
    /// source. Sized so that no content size rescues it, which keeps the row a statement
    /// about the colour rather than about the Dynamic Type setting the scan happened to run
    /// under.
    func testCompositedFail_dynamicTypeLabel_failsAtTheDefaultContentSize() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrast(issues, is: ColorContrastRule.normalFail,
                       forElementContaining: "Fails at every Dynamic Type size")
    }

    /// Row 7 — a white caption on a light image with no scrim at all, 1.53:1.
    ///
    /// The verdict is not pinned to a rule. Text over an image has a different ratio over
    /// every pixel, so which rule it lands on is a fact about where the sampling fell rather
    /// than about the screen. What is honestly assertable — and what actually matters — is
    /// that an image-backed caption is not silently skipped for having no background colour
    /// to read.
    func testCompositedFail_captionOverImage_isNotSkipped() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrastIsReported(issues, forElementContaining: "Caption over a photo")
    }

    /// Row 6 — white text on a pale gradient, 2.88:1 falling to 1.90:1 across the string.
    ///
    /// There is no single ratio to report, so the correct answer is to decline to compute one
    /// and ask for a human check rather than to pick a pixel and present it as the verdict.
    /// This asserts the rule takes that route, which is what separates "cannot be measured
    /// automatically" from "was not measured".
    func testCompositedFail_gradient_asksForAManualCheck() throws {
        let issues = try runScan(screen: compositedScreen)
        assertContrast(issues, is: ColorContrastRule.validate,
                       forElementContaining: "Unreadable across the whole gradient")
    }

    // MARK: - Known gaps
    //
    // Two rows on the composited Fail screen produce NO contrast verdict at all — not a pass,
    // not a failure, not a request for a manual check. They are recorded here as expected
    // failures rather than left out, because a scenario the fixture was built to exercise and
    // the scan silently drops is the one thing a suite of assertions cannot show by staying
    // green. XCTExpectFailure keeps the suite honest in both directions: it does not report a
    // gap as a pass, and it fails loudly once the gap closes, so the marker gets removed
    // instead of quietly outliving the bug.

    /// Row 1 — a label whose own `alpha` is 0.35, compositing pure black to about #A6A6A6 on
    /// white for a real ratio of 2.43:1.
    ///
    /// View alpha is the most common way for an effective colour to differ from the assigned
    /// one, and the assigned colour here is #000000 — so a checker that misses the alpha does
    /// not just lose accuracy, it reports the screen's least readable row as its most
    /// readable one at 21:1.
    func testCompositedFail_labelAlpha_shouldBeMeasured() throws {
        XCTExpectFailure("Contrast is not evaluated for a UILabel with alpha < 1 — the "
                         + "element produces no contrast row of any kind.")
        let issues = try runScan(screen: compositedScreen)
        assertContrastIsReported(issues, forElementContaining: "Label drawn at 35% alpha")
    }

    /// Row 5 — a label inside a UIVibrancyEffect view configured against a different blur
    /// style than the one hosting it.
    ///
    /// Vibrancy resolves its colour from the material at render time, so there is no assigned
    /// text colour to read and the value is not knowable from the source at all. That makes it
    /// the strongest case on the screen for a rendered-pixel check — and, failing that, for
    /// the manual-check verdict the gradient row gets, rather than silence.
    func testCompositedFail_vibrancyLabel_shouldBeMeasured() throws {
        XCTExpectFailure("Contrast is not evaluated for a label inside a UIVibrancyEffect "
                         + "view — no text colour is resolved, and no row is emitted.")
        let issues = try runScan(screen: compositedScreen)
        assertContrastIsReported(issues, forElementContaining: "Tertiary vibrancy")
    }
}
