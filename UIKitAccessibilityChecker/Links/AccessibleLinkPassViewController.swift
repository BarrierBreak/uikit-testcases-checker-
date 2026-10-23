import UIKit

/// LINKS — Pass tier.
///
/// Every link sits inside a sentence and is set apart from the words around it by more than its
/// colour: an underline, or a heavier weight. Nothing is reported.
///
/// Elements covered (3) — none is a defect:
///   1. "terms of service"   — underlined
///   2. "privacy policy"     — underlined
///   3. "help centre"        — bold
final class AccessibleLinkPassViewController: LinkDemoViewController {

    override var screenTitle: String { "Links (Pass)" }

    override var sentences: [Sentence] {
        [
            Sentence(before: "Before you continue, please read our ", link: "terms of service", after: " and accept them.", style: .underlined),
            Sentence(before: "We look after your data as described in our ", link: "privacy policy", after: " at all times.", style: .underlined),
            Sentence(before: "If something goes wrong, visit the ", link: "help centre", after: " for step by step guidance.", style: .bold),
        ]
    }
}
