import UIKit

/// A five-star rating VoiceOver adjusts with a swipe up or down — a custom view carrying the
/// `.adjustable` trait. With `speaksValue`, it announces "3 of 5 stars"; without, it never says
/// where it is set (the BB40278 defect).
final class AdjustableRatingView: UIView {

    private(set) var rating = 3 { didSet { redraw() } }
    private let speaksValue: Bool
    private let stars = UILabel()

    init(speaksValue: Bool) {
        self.speaksValue = speaksValue
        super.init(frame: .zero)
        stars.font = .systemFont(ofSize: 28)
        stars.textColor = .systemOrange
        stars.isAccessibilityElement = false
        addSubview(stars)
        isAccessibilityElement = true
        accessibilityLabel = "Rating"
        accessibilityTraits = .adjustable
        redraw()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        stars.frame = bounds
    }

    private func redraw() {
        stars.text = String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
        accessibilityValue = speaksValue ? "\(rating) of 5 stars" : nil
    }

    override func accessibilityIncrement() { rating = min(rating + 1, 5) }
    override func accessibilityDecrement() { rating = max(rating - 1, 1) }
}
