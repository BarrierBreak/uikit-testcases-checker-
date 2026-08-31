import UIKit

final class AccessibleColorContrastPassViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessible Color Contrast (Pass)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }

    /// A card with a fixed, explicit background — not `.systemBackground` — so the label's
    /// contrast is deterministic regardless of the system's light/dark appearance.
    /// ColorContrastValidator resolves an element's effective background from the nearest
    /// ancestor's own backgroundColor, not the screen's.
    private func contrastCard(text: String, textColor: UIColor, font: UIFont, cardBackground: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = cardBackground
        card.layer.cornerRadius = 10

        let label = UILabel().srcLine()
        label.text = text
        label.textColor = textColor
        label.font = font
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    private func buildLayout() {
        let normalTextCard = contrastCard(
            text: "Black text on white, 15pt — well above the 4.5:1 normal-text AA threshold.",
            textColor: .black,
            font: .systemFont(ofSize: 15),
            cardBackground: .white
        )

        let largeTextCard = contrastCard(
            text: "Black text on white, 22pt — well above the 3:1 large-text AA threshold.",
            textColor: .black,
            font: .systemFont(ofSize: 22),
            cardBackground: .white
        )

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView(arrangedSubviews: [
            sectionLabel("High-contrast text — passes WCAG AA"),
            normalTextCard,
            largeTextCard
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
}
