import UIKit

final class AccessibleColorContrastPartialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessible Color Contrast (Partial)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }

    /// A photo-style background behind overlay text — ColorContrastValidator cannot compute
    /// an effective background color from a UIImageView, so it emits BB40514 ("Validate")
    /// instead of a Pass/Fail verdict: contrast here genuinely depends on which part of the
    /// image sits behind the text, which only a person can judge.
    private func imageBackgroundCard() -> UIView {
        let card = UIImageView()
        card.contentMode = .scaleAspectFill
        card.clipsToBounds = true
        card.layer.cornerRadius = 10
        card.image = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 120)).image { context in
            let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
            context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 300, y: 120), options: [])
        }
        card.isUserInteractionEnabled = true

        let label = UILabel().srcLine()
        label.text = "Overlay text on a photo background"
        label.textColor = .white
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            card.heightAnchor.constraint(equalToConstant: 120)
        ])
        return card
    }

    /// A gradient layer background — the other ancestry check ColorContrastValidator treats
    /// the same way as an image: it can't reliably read a single "background color" off a
    /// CAGradientLayer either, so this also resolves to BB40514 rather than a ratio check.
    private func gradientBackgroundCard() -> UIView {
        let card = UIView()
        card.layer.cornerRadius = 10
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.white.cgColor]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        gradientLayer.cornerRadius = 10
        card.layer.insertSublayer(gradientLayer, at: 0)

        let label = UILabel().srcLine()
        label.text = "Overlay text on a gradient background"
        label.textColor = .black
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            card.heightAnchor.constraint(equalToConstant: 100)
        ])
        return card
    }

    private func buildLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView(arrangedSubviews: [
            sectionLabel("Text over a non-solid background — contrast can't be checked automatically"),
            imageBackgroundCard(),
            gradientBackgroundCard()
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
