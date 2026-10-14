import UIKit

/// READING ORDER — Partial tier.
///
/// Two cards tell VoiceOver the order to read them in. One is right and one is not.
///
/// Elements covered (2):
///   1. Summary card   — read in the order drawn                       → BB40135 Pass
///   2. Details card   — drawn top to bottom, read bottom to top       → BB40134 Fail
final class AccessibleReadingOrderPartialViewController: ReadingOrderDemoViewController {

    override var screenTitle: String { "Reading Order (Partial)" }

    override var cards: [Card] {
        [
            Card(layout: .column,
                 texts: ["Order summary", "Two items, 42 dollars", "Estimated delivery on Friday"],
                 readingOrder: [0, 1, 2]),
            Card(layout: .column,
                 texts: ["Shipping address", "12 Garden Road", "Springfield"],
                 readingOrder: [2, 1, 0]),
        ]
    }
}
