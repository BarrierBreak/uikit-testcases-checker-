import UIKit

/// LINKS — Partial tier.
///
/// Some links are set apart by more than colour and some are not.
///
/// Elements covered (3):
///   1. "terms of service"   — underlined                    → nothing
///   2. "privacy policy"     — colour only                   → BB40306 Validate
///   3. "help centre"        — bold                          → nothing
final class AccessibleLinkPartialViewController: LinkDemoViewController {

    override var screenTitle: String { "Links (Partial)" }

    override var sentences: [Sentence] {
        [
            Sentence(before: "Before you continue, please read our ", link: "terms of service", after: " and accept them.", style: .underlined),
            Sentence(before: "We look after your data as described in our ", link: "privacy policy", after: " at all times.", style: .colourOnly),
            Sentence(before: "If something goes wrong, visit the ", link: "help centre", after: " for step by step guidance.", style: .bold),
        ]
    }
}
