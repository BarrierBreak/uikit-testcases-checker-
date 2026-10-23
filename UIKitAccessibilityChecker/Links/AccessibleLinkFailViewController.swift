import UIKit

/// LINKS — Fail tier.
///
/// Every link sits inside a sentence and is told apart from the words around it by colour
/// alone: no underline, no heavier weight. Each reports BB40306 "Link color differentiation
/// check" — a Validate row with the measured colour ratio, for a person to judge.
///
/// Elements covered (3) — every one is reported:
///   1. "terms of service"   — colour only
///   2. "privacy policy"     — colour only
///   3. "help centre"        — colour only
final class AccessibleLinkFailViewController: LinkDemoViewController {

    override var screenTitle: String { "Links (Fail)" }

    override var sentences: [Sentence] {
        [
            Sentence(before: "Before you continue, please read our ", link: "terms of service", after: " and accept them.", style: .colourOnly),
            Sentence(before: "We look after your data as described in our ", link: "privacy policy", after: " at all times.", style: .colourOnly),
            Sentence(before: "If something goes wrong, visit the ", link: "help centre", after: " for step by step guidance.", style: .colourOnly),
        ]
    }
}
