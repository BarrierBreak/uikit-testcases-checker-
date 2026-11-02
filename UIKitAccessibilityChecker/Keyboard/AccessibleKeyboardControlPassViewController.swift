import UIKit

/// KEYBOARD CONTROLS — Pass tier for BB40066 "Interactive control cannot receive keyboard focus".
///
/// The verdict is read live from the focus engine (`canBecomeFocused`), so it follows the code:
/// every control here is one Tab and Full Keyboard Access can land on.
///
/// Elements covered (5) — none fails:
///   1. Quantity stepper — stock UIStepper                                  → no row
///   2. Volume slider    — stock UISlider                                   → no row
///   3. Notifications    — stock UISwitch                                   → no row
///   4. Promo code field — stock UITextField                                → no row
///   5. Star rating      — custom .adjustable view that overrides
///                         canBecomeFocused to return true                  → no row
final class AccessibleKeyboardControlPassViewController: NewRuleScreen {

    override var screenTitle: String { "Keyboard Control (Pass)" }

    override func build() {
        let stepper = UIStepper().srcLine()
        stepper.accessibilityLabel = "Quantity"
        place(stepper, width: 100)

        let slider = UISlider().srcLine()
        slider.accessibilityLabel = "Volume"
        place(slider)

        let toggle = UISwitch().srcLine()
        toggle.accessibilityLabel = "Notifications"
        place(toggle, width: 60)

        let field = UITextField().srcLine()
        field.placeholder = "Promo code"
        field.accessibilityLabel = "Promo code"
        field.borderStyle = .roundedRect
        place(field)

        place(KeyboardRatingView(focusable: true).srcLine())
    }
}

/// A five-star rating adjusted with the arrow keys or a VoiceOver swipe — a custom view with the
/// `.adjustable` trait. A plain `UIView` is never focusable, so with `focusable` false the focus
/// engine skips it (the BB40066 defect); with `focusable` true it overrides `canBecomeFocused`.
final class KeyboardRatingView: UIView {

    private let focusable: Bool
    private var rating = 3 { didSet { refresh() } }
    private let stars = UILabel()

    init(focusable: Bool) {
        self.focusable = focusable
        super.init(frame: .zero)
        stars.font = .systemFont(ofSize: 28)
        stars.textColor = .systemOrange
        stars.isAccessibilityElement = false
        addSubview(stars)
        isAccessibilityElement = true
        accessibilityLabel = "Rating"
        accessibilityTraits = .adjustable
        refresh()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var canBecomeFocused: Bool { focusable }

    override func layoutSubviews() {
        super.layoutSubviews()
        stars.frame = bounds
    }

    private func refresh() {
        stars.text = String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
        accessibilityValue = "\(rating) of 5 stars"
    }

    override func accessibilityIncrement() { rating = min(rating + 1, 5) }
    override func accessibilityDecrement() { rating = max(rating - 1, 1) }
    override func accessibilityActivate() -> Bool { rating = rating % 5 + 1; return true }

    // Arrow keys change the rating once the view has keyboard focus.
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return super.pressesBegan(presses, with: event) }
        switch key.keyCode {
        case .keyboardRightArrow, .keyboardUpArrow: accessibilityIncrement()
        case .keyboardLeftArrow, .keyboardDownArrow: accessibilityDecrement()
        default: super.pressesBegan(presses, with: event)
        }
    }
}
