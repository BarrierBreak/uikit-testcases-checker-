//
//  ColorContrastPassElementScanTests.swift
//  UIKitAccessibilityCheckerUITests
//
//  Element-level coverage for the two Colour Contrast PASS screens.
//
//  This tier asserts the opposite of the other two, and it needs a different kind of care.
//  A rule that reports nothing passes every "does not fire" assertion trivially, so silence
//  cannot be the evidence: "this control has no failure" and "the scan never reached this
//  control" are the same empty result once passes are omitted.
//
//  Every assertion here therefore runs with `includePasses: true` and asserts that a control
//  was MEASURED and came out clean, via `assertContrastPasses`. That is the only form in
//  which a pass is worth asserting — and it is why the scan's `all_passes` rows exist.
//
//  The two screens divide the problem the same way as the other tiers: the solid screen
//  proves the arithmetic on two known colours, and the composited screen proves that the
//  colours fed into that arithmetic are the effective ones rather than the assigned ones.
//
import XCTest

final class ColorContrastPassElementScanTests: XCTestCase {

    private let solidScreen = "AccessibleTextContrastPassViewController"
    private let compositedScreen = "AccessibleTextContrastCompositedPassViewController"

    // MARK: - Solid backgrounds

    /// Rows 1, 5 and 7 — 7.00:1, which clears AA and AAA both.
    ///
    /// Body text, a 13pt caption and a 13pt semibold section header. The caption and header
    /// are the useful half: small text gets no relaxation, and "secondary" is not a licence to
    /// lighten, so these being clean is a statement about the colour rather than the size.
    func testContrastPass_bodyCaptionAndHeader_areMeasuredAndPass() throws {
        let issues = try runScan(screen: solidScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "The quick brown fox")
        assertContrastPasses(issues, forElementContaining: "Last updated 3 minutes ago")
        assertContrastPasses(issues, forElementContaining: "CONNECTIVITY")
    }

    /// Rows 2 and 3 — 4.54:1 on 18pt regular and on 14pt bold.
    ///
    /// 14pt bold is the smallest size that counts as large text under WCAG. One point smaller
    /// or one weight lighter and the bar moves to 4.5:1 — which this colour still clears, so
    /// the row is a boundary case that is safe in both directions. Its counterpart on the
    /// Partial screen, 13pt bold at 3.44:1, is the one that is not.
    func testContrastPass_largeTextBoundary_isMeasuredAndPasses() throws {
        let issues = try runScan(screen: solidScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "Large headline text")
        assertContrastPasses(issues, forElementContaining: "Bold 14pt counts as large text")
    }

    /// Rows 4 and 8 — white on a dark blue button fill at 6.57:1, and an 11pt badge on dark
    /// green at 6.54:1.
    ///
    /// Both measure the title against the CONTROL's fill rather than the screen background.
    /// Taking the white page instead would compute a ratio near 1:1 and report a failure, so
    /// these rows guard against the background being resolved one level too far out.
    func testContrastPass_titlesOnTintedFills_areMeasuredAgainstTheirOwnFill() throws {
        let issues = try runScan(screen: solidScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "Continue")
        assertContrastPasses(issues, forElementContaining: "3 NEW")
    }

    /// Row 9 — a darkened red at 6.54:1 rather than the system red, which reaches only 3.55:1.
    ///
    /// The direct counterpart to the Partial screen's row 9: same role, same size, same
    /// background, and the only difference is the colour. Together they pin that the rule is
    /// reading the colour rather than the semantics of "this is an error message".
    func testContrastPass_darkenedErrorRed_passes() throws {
        let issues = try runScan(screen: solidScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "Enter a valid email address")
    }

    /// Row 10 — a DISABLED button title.
    ///
    /// WCAG 1.4.3 exempts text that is part of an inactive control, so a disabled title has no
    /// minimum ratio at all. This one is legible anyway, which is good practice — but the
    /// point of the row is that flagging it would be a false positive, and this asserts the
    /// rule knows the difference.
    func testContrastPass_disabledControlTitle_isNotReportedAsAFailure() throws {
        let issues = try runScan(screen: solidScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "Save Draft")
    }

    /// The whole screen, counted — no tagged control on it is a contrast failure.
    ///
    /// Counting only the tagged rows keeps this stable: the row captions above each sample are
    /// text too and get measured alongside the samples, so a raw count would count the
    /// fixture's scaffolding. Asserting the count AND the verdict together is what makes it
    /// meaningful — a screen where the rule stopped running would satisfy "no failures" on its
    /// own.
    func testContrastPass_everyTaggedControlIsMeasuredAndClean() throws {
        let issues = try runScan(screen: solidScreen, includePasses: true)
        let tagged = taggedContrastRows(issues, sourceFile: "\(solidScreen).swift")
        XCTAssertEqual(tagged.count, 10,
                       "Expected all ten tagged controls to be measured, got: \(tagged.map(\.element))")
        XCTAssertTrue(tagged.allSatisfy { ColorContrastRule.passes.contains($0.rule) },
                      "No control on the Pass screen should be a contrast failure, got: "
                      + "\(tagged.filter { !ColorContrastRule.passes.contains($0.rule) }.map(\.element))")
    }

    // MARK: - Composited backgrounds

    /// Row 2 — white on a panel at 0.85 alpha, compositing to about #3E3E40 for 10.67:1.
    ///
    /// The mirror of the Partial screen's 0.6-alpha panel: same construction, same assigned
    /// colours, and only the alpha differs. A rule that ignored alpha would report both as
    /// 17:1 and get this one right by accident, which is why the pair has to be read together.
    func testCompositedPass_backgroundAlpha_isMeasuredAndPasses() throws {
        let issues = try runScan(screen: compositedScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "White text on a translucent panel")
    }

    /// Row 8 — a dynamic colour with genuinely separate light and dark values, 7.00:1 and
    /// 10.10:1 against their own backgrounds.
    ///
    /// The scan runs in light mode, so only the light branch is exercised here. That is worth
    /// stating plainly: this asserts the light value is correct, not that the label adapts —
    /// the Composited Fail screen's inverted-branch row is the one that shows what adaptation
    /// failing looks like, and it is equally invisible to a light-mode-only scan.
    func testCompositedPass_appearanceAwareColour_passesInLightMode() throws {
        let issues = try runScan(screen: compositedScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "Adapts to light and dark")
    }

    /// Row 9 — a label that reads `traitCollection.accessibilityContrast` and darkens when
    /// Increase Contrast is on: 7.00:1 normally, 10.86:1 with the setting enabled.
    ///
    /// The scan runs with the setting off, so the 7.00:1 state is what is asserted. Its
    /// counterpart on the Composited Fail screen moves the colour the wrong way and is a
    /// failure in both states, which is what makes that one assertable without toggling the
    /// setting either.
    func testCompositedPass_respondsToIncreaseContrast_passesInTheDefaultState() throws {
        let issues = try runScan(screen: compositedScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "Responds to Increase Contrast")
    }

    /// Row 10 — a Dynamic Type label held to the NORMAL-text threshold at 5.74:1.
    ///
    /// An 18pt label is large text and needs only 3:1 — but at the xSmall content size a
    /// scaled 18pt font renders under 18pt and becomes normal text needing 4.5:1. Meeting the
    /// stricter bar is what makes it compliant at every content size, and it is why this row
    /// can be asserted from a single scan at the default size.
    func testCompositedPass_dynamicTypeLabel_meetsTheNormalTextBar() throws {
        let issues = try runScan(screen: compositedScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "Scales with Dynamic Type")
    }

    /// Row 5 — primary text over a material with NO vibrancy applied.
    ///
    /// Vibrancy deliberately reduces contrast to blend text into its material, which is the
    /// opposite of what 1.4.3 asks of primary content. Vibrancy is fine for decorative chrome;
    /// text that must be read uses a plain opaque colour, and that choice is what makes this
    /// row measurable at all — the Composited Fail screen's vibrancy row is not.
    func testCompositedPass_primaryTextOverMaterial_isMeasuredAndPasses() throws {
        let issues = try runScan(screen: compositedScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "Primary text, no vibrancy applied")
    }

    // MARK: - Known gaps
    //
    // Two rows on the composited Pass screen are reported as failures when their real ratios
    // are 10.67:1 and 6.53:1. Both are false positives, and both come from the effective
    // background being resolved as white rather than as what is actually behind the text.

    /// Row 3 — white text over two stacked translucent layers, 0.5 and 0.7 alpha over white,
    /// compositing to about #3E3E40 for a real ratio of 10.67:1.
    ///
    /// The Partial screen's version of this row — two 0.4-alpha layers — IS resolved
    /// correctly, and is asserted as a failure there. So the layer walk is not simply absent;
    /// it produces the wrong background for this particular stack, which makes the row a
    /// sharper signal than a missing measurement would be.
    func testCompositedPass_stackedLayers_shouldNotBeReportedAsAFailure() throws {
        XCTExpectFailure("The two-layer stack resolves to a near-white background, so 10.67:1 "
                         + "is reported as a normal-text failure.")
        let issues = try runScan(screen: compositedScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "Text over two translucent layers")
    }

    /// Row 7 — a white caption over an image behind a 55% black scrim, 6.53:1 at its worst
    /// point.
    ///
    /// The scrim is what makes the ratio predictable, and it is the recommended fix for
    /// captions over photography — so reporting it as a failure penalises the correct
    /// construction. The equivalent row on the Fail screen has no scrim and is a genuine
    /// failure; both currently come back the same way, which means the scrim is not being
    /// composited into the background at all.
    func testCompositedPass_scrimmedCaptionOverImage_shouldNotBeReportedAsAFailure() throws {
        XCTExpectFailure("The 55% scrim is not composited into the effective background, so a "
                         + "correctly scrimmed caption is reported as a large-text failure.")
        let issues = try runScan(screen: compositedScreen, includePasses: true)
        assertContrastPasses(issues, forElementContaining: "Caption over a photo")
    }
}
