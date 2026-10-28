import UIKit

/// A card that handles the shake gesture. Overriding the shake methods is what makes it a
/// motion-based action; the scan judges each such card on whether an accessible control
/// inside it performs the same action.
final class ShakeCardView: UIView {

    var onShake: (() -> Void)?

    /// Every card on screen. A shake goes only to the first responder, so the card that holds
    /// it passes the shake on to the others — each card acts on it.
    private static let cards = NSHashTable<ShakeCardView>.weakObjects()

    override init(frame: CGRect) {
        super.init(frame: frame)
        Self.cards.add(self)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Self.cards.add(self)
    }

    override var canBecomeFirstResponder: Bool { true }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        for card in Self.cards.allObjects where card.window != nil { card.onShake?() }
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
        var cardViews: [ShakeCardView] = []
        for (index, card) in cards.enumerated() {
            let container = ShakeCardView().srcLine()
            // Cards are built in one loop, so they share a source line; the tag is what keeps
            // one card's finding from being merged into the other's.
            container.tag = index
            container.backgroundColor = .secondarySystemBackground
            container.layer.cornerRadius = 12
            container.frame = CGRect(x: 24, y: y, width: view.bounds.width - 48, height: 160)
            container.autoresizingMask = [.flexibleWidth]

            let label = UILabel()
            label.text = card.prompt
            label.numberOfLines = 0
            label.frame = CGRect(x: 16, y: 12, width: container.bounds.width - 32, height: 44)
            label.autoresizingMask = [.flexibleWidth]
            container.addSubview(label)

            // What the action did, so a shake (or the button) visibly does something.
            let status = UILabel()
            status.font = .preferredFont(forTextStyle: .footnote)
            status.textColor = .secondaryLabel
            status.text = "Not run yet"
            status.frame = CGRect(x: 16, y: 122, width: container.bounds.width - 32, height: 24)
            status.autoresizingMask = [.flexibleWidth]
            container.addSubview(status)
            var runs = 0
            let perform = { [weak status] in
                runs += 1
                status?.text = "Done — ran \(runs) time\(runs == 1 ? "" : "s")"
            }
            container.onShake = perform

            if let title = card.alternative {
                let button = UIButton(type: .system).srcLine()
                button.setTitle(title, for: .normal)
                button.isAccessibilityElement = card.exposed
                button.addAction(UIAction { _ in perform() }, for: .touchUpInside)
                button.frame = CGRect(x: 16, y: 70, width: 220, height: 44)
                container.addSubview(button)
            }
            view.addSubview(container)
            cardViews.append(container)
            y += 184
        }
        shakeTarget = cardViews.first
    }

    /// The card that holds first-responder status, so the device's shake reaches the screen.
    private var shakeTarget: ShakeCardView?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shakeTarget?.becomeFirstResponder()
    }
}
