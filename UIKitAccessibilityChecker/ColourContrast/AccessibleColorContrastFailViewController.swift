import UIKit

final class AccessibleColorContrastFailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessible Color Contrast (Fail)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }

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
        // #808080 on white ≈ 3.95:1 — below the 4.5:1 normal-text AA threshold.
        let normalTextCard = contrastCard(
            text: "Grey text on white, 15pt — only ≈3.95:1, below the 4.5:1 normal-text AA threshold.",
            textColor: UIColor(red: 0x80 / 255.0, green: 0x80 / 255.0, blue: 0x80 / 255.0, alpha: 1),
            font: .systemFont(ofSize: 15),
            cardBackground: .white
        )

        // A near-white grey on white ≈ 1.4:1 — below the 3:1 large-text AA threshold.
        let largeTextCard = contrastCard(
            text: "Near-white text on white, 22pt — only ≈1.4:1, below the 3:1 large-text AA threshold.",
            textColor: UIColor(white: 0.85, alpha: 1),
            font: .systemFont(ofSize: 22),
            cardBackground: .white
        )

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView(arrangedSubviews: [
            sectionLabel("Low-contrast text — fails WCAG AA"),
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
