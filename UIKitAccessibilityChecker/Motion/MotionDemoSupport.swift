import UIKit

/// A card that handles the shake gesture. Overriding the shake methods is what makes it a
/// motion-based action; the scan judges each such card on whether an accessible control
/// inside it performs the same action.
final class ShakeCardView: UIView {

    var onShake: (() -> Void)?

    override var canBecomeFirstResponder: Bool { true }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        onShake?()
    }
}

/// Builds the cards the three Motion screens share. `alternative` is the control title inside
/// the card, or nil for a card whose only way in is the gesture; `exposed` says whether that
/// control is reachable with VoiceOver.
class MotionDemoViewController: UIViewController {

    struct Card {
        let prompt: String
        let alternative: String?
        var exposed = true
    }

    var screenTitle: String { "" }
    var cards: [Card] { [] }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = .systemBackground
        var y: CGFloat = 24
        for (index, card) in cards.enumerated() {
            let container = ShakeCardView().srcLine()
            // Cards are built in one loop, so they share a source line; the tag is what keeps
            // one card's finding from being merged into the other's.
            container.tag = index
            container.backgroundColor = .secondarySystemBackground
            container.layer.cornerRadius = 12
            container.frame = CGRect(x: 24, y: y, width: view.bounds.width - 48, height: 130)
            container.autoresizingMask = [.flexibleWidth]

            let label = UILabel()
            label.text = card.prompt
            label.numberOfLines = 0
            label.frame = CGRect(x: 16, y: 12, width: container.bounds.width - 32, height: 44)
            label.autoresizingMask = [.flexibleWidth]
            container.addSubview(label)

            if let title = card.alternative {
                let button = UIButton(type: .system).srcLine()
                button.setTitle(title, for: .normal)
                button.isAccessibilityElement = card.exposed
                button.frame = CGRect(x: 16, y: 70, width: 220, height: 44)
                container.addSubview(button)
            }
            view.addSubview(container)
            y += 154
        }
    }
}
