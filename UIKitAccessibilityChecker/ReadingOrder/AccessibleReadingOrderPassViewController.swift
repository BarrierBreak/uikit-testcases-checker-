import UIKit

/// READING ORDER — Pass tier.
///
/// Two cards tell VoiceOver the order to read them in, and in both it is the order they are
/// drawn: top to bottom in the column, left to right in the row. Each reports BB40135
/// "Reading order is accurate".
///
/// Elements covered (2) — neither is a defect:
///   1. Summary card   — three lines, read title → detail → note
///   2. Actions card   — Cancel then Save, left to right
final class AccessibleReadingOrderPassViewController: ReadingOrderDemoViewController {

    override var screenTitle: String { "Reading Order (Pass)" }

    override var cards: [Card] {
        [
            Card(layout: .column,
                 texts: ["Order summary", "Two items, 42 dollars", "Estimated delivery on Friday"],
                 readingOrder: [0, 1, 2]),
            Card(layout: .row, texts: ["Cancel", "Save"], readingOrder: [0, 1]),
        ]
    }
}
