import UIKit

/// READING ORDER — Fail tier.
///
/// Two cards tell VoiceOver an order that is not the order they are drawn. Each reports
/// BB40134 "Inaccurate reading order".
///
/// Elements covered (2) — both fail:
///   1. Summary card   — drawn title → detail → note, read note → title → detail
///   2. Actions card   — drawn Cancel | Save, read Save then Cancel
final class AccessibleReadingOrderFailViewController: ReadingOrderDemoViewController {

    override var screenTitle: String { "Reading Order (Fail)" }

    override var cards: [Card] {
        [
            Card(layout: .column,
                 texts: ["Order summary", "Two items, 42 dollars", "Estimated delivery on Friday"],
                 readingOrder: [2, 0, 1]),
            Card(layout: .row, texts: ["Cancel", "Save"], readingOrder: [1, 0]),
        ]
    }
}
