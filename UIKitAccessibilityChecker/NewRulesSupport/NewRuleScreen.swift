import UIKit

/// Shared scaffold for the Role Trait, State Trait, Button, Form Label, Custom Action and Touch
/// Event screens: a vertical stack of judged views, no captions (a visible label beside a field
/// is itself an input to the Form Label rule, so a screen must not add one by accident).
class NewRuleScreen: UIViewController {

    var screenTitle: String { "" }
    private var nextY: CGFloat = 24

    /// Subclasses add their judged views with `place(_:)`.
    func build() {}

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = .systemBackground
        build()
    }

    /// Lays `subject` out under the previous one, `gap` points apart.
    func place(_ subject: UIView, height: CGFloat = 44, width: CGFloat? = nil, gap: CGFloat = 32) {
        subject.frame = CGRect(x: 24, y: nextY, width: width ?? view.bounds.width - 48, height: height)
        if width == nil { subject.autoresizingMask = [.flexibleWidth] }
        view.addSubview(subject)
        nextY += height + gap
    }

    // MARK: - Targets for gesture and control wiring

    @objc func activate() {}
    @objc func handleGesture(_ sender: UIGestureRecognizer) {}

    // MARK: - Gesture cards (Custom Action)

    enum Gesture { case swipe, pan, pinch, longPress }

    /// A card driven by one complex gesture. With `alternative`, the card also exposes a custom
    /// action that does the same thing, so VoiceOver and Switch Control users can trigger it.
    func gestureCard(_ name: String, gesture: Gesture, alternative: Bool, tag: Int) -> UIView {
        let card = UIView().srcLine()
        card.tag = tag
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.isAccessibilityElement = true
        card.accessibilityLabel = name

        let recognizer: UIGestureRecognizer
        switch gesture {
        case .swipe:
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
            swipe.direction = .left
            recognizer = swipe
        case .pan:
            recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        case .pinch:
            recognizer = UIPinchGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        case .longPress:
            let press = UILongPressGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
            press.minimumPressDuration = 0.5
            recognizer = press
        }
        card.addGestureRecognizer(recognizer)

        if alternative {
            card.accessibilityCustomActions = [
                UIAccessibilityCustomAction(name: "Perform \(name)") { _ in true }
            ]
        }
        return card
    }
}
