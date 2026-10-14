import UIKit

/// Shared layout for the three Reading Order screens. A screen is a list of cards; each card is
/// a group of labels laid out in a column or a row, plus the order the app TELLS VoiceOver to
/// read them in (`accessibilityElements`). The order is given as indexes into the laid-out
/// labels, so a card can be read in the order it is drawn, or not.
class ReadingOrderDemoViewController: UIViewController {

    enum Layout { case column, row }

    struct Card {
        let layout: Layout
        let texts: [String]
        /// Indexes into `texts`, in the order VoiceOver is told to read them.
        let readingOrder: [Int]
    }

    var screenTitle: String { "" }
    var cards: [Card] { [] }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = .systemBackground
        var y: CGFloat = 24
        for (cardIndex, card) in cards.enumerated() {
            let container = UIView().srcLine()
            // Cards are built in one loop, so they share a source line; the tag is what keeps
            // one card's finding from being merged into another's.
            container.tag = cardIndex
            container.backgroundColor = .secondarySystemBackground
            container.layer.cornerRadius = 12
            let height: CGFloat = card.layout == .column ? CGFloat(card.texts.count) * 40 + 24 : 72
            container.frame = CGRect(x: 24, y: y, width: view.bounds.width - 48, height: height)
            container.autoresizingMask = [.flexibleWidth]

            var labels: [UILabel] = []
            for (index, text) in card.texts.enumerated() {
                let label = UILabel().srcLine()
                label.text = text
                label.tag = cardIndex * 10 + index
                switch card.layout {
                case .column:
                    label.frame = CGRect(x: 16, y: 12 + CGFloat(index) * 40, width: 280, height: 32)
                case .row:
                    label.frame = CGRect(x: 16 + CGFloat(index) * 150, y: 20, width: 130, height: 32)
                }
                container.addSubview(label)
                labels.append(label)
            }
            container.accessibilityElements = card.readingOrder.map { labels[$0] }
            view.addSubview(container)
            y += height + 24
        }
    }
}
