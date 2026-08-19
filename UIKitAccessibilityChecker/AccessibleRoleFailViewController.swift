import UIKit

/// Worst-case tier: several controls are given the WRONG accessibilityTraits
/// outright, actively misleading VoiceOver users about how something
/// behaves, instead of merely omitting a trait. Deliberately broken;
/// reference only.
final class AccessibleRoleFailViewController: UIViewController {

    private let refreshLabel = UILabel()
    private let headerLabel = UILabel()
    private let linkLabel = UILabel()
    private let filterChipView = UIView()
    private let filterCheckImageView = UIImageView()
    private let filterTextLabel = UILabel()
    private var shippingRowViews: [UIView] = []
    private let dialView = PlainDialControl()
    private let sparkleImageView = UIImageView(image: UIImage(systemName: "sparkle"))

    private var isWifiOnlyFilterOn = false
    private var selectedShippingOption = 0
    private let shippingOptions = ["Standard (5-7 days)", "Express (2-3 days)", "Overnight"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // MARK: Custom button — WRONG role
        refreshLabel.text = "Refresh"
        refreshLabel.textColor = .white
        refreshLabel.textAlignment = .center
        refreshLabel.backgroundColor = .systemBlue
        refreshLabel.layer.cornerRadius = 8
        refreshLabel.layer.masksToBounds = true
        refreshLabel.isUserInteractionEnabled = true
        refreshLabel.isAccessibilityElement = true
        // Actively wrong: tells VoiceOver this is definitely NOT
        // interactive, despite the tap gesture right above it.
        refreshLabel.accessibilityTraits = .staticText
        refreshLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(refreshTapped)))
        refreshLabel.srcLine()

        // MARK: Section header — no header, no context at all
        headerLabel.text = nil
        headerLabel.font = .preferredFont(forTextStyle: .headline)
        headerLabel.srcLine()

        // MARK: Custom link — WRONG role
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        linkLabel.attributedText = NSAttributedString(string: "View documentation", attributes: linkAttributes)
        linkLabel.isUserInteractionEnabled = true
        linkLabel.isAccessibilityElement = true
        // Actively wrong: announced as "button" when it's really a link.
        linkLabel.accessibilityTraits = .button
        linkLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkTapped)))
        linkLabel.srcLine()

        // MARK: Custom filter chip — no grouping, no role at all
        filterCheckImageView.image = UIImage(systemName: "square")
        filterTextLabel.text = "Wi-Fi Only"
        let filterStack = UIStackView(arrangedSubviews: [filterCheckImageView, filterTextLabel])
        filterStack.axis = .horizontal
        filterStack.spacing = 8
        filterChipView.addSubview(filterStack)
        filterStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterStack.topAnchor.constraint(equalTo: filterChipView.topAnchor),
            filterStack.bottomAnchor.constraint(equalTo: filterChipView.bottomAnchor),
            filterStack.leadingAnchor.constraint(equalTo: filterChipView.leadingAnchor),
            filterStack.trailingAnchor.constraint(equalTo: filterChipView.trailingAnchor)
        ])
        filterChipView.isUserInteractionEnabled = true
        // isAccessibilityElement left false, no traits — VoiceOver swipes
        // through the checkbox image and text as two separate, unrelated,
        // non-interactive elements. Nothing indicates this can be tapped.
        filterChipView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterChipTapped)))
        filterChipView.srcLine()

        // MARK: Custom radio rows — no grouping, no role, no state
        let radioStack = UIStackView()
        radioStack.axis = .vertical
        radioStack.spacing = 12
        for (index, option) in shippingOptions.enumerated() {
            let row = makeShippingRow(title: option, index: index)
            shippingRowViews.append(row)
            radioStack.addArrangedSubview(row)
        }

        // MARK: Custom adjustable dial — WRONG role
        dialView.onValueChanged = { _ in }
        dialView.isAccessibilityElement = true
        dialView.accessibilityLabel = "Brightness"
        // Actively wrong: marked as a simple button, implying one
        // double-tap does something discrete, instead of a continuous
        // control adjusted by swiping up/down. Double-tapping does
        // nothing, which reads as a broken button, not a working dial.
        dialView.accessibilityTraits = .button
        dialView.srcLine()

        // MARK: Decorative icon — WRONG role
        sparkleImageView.isUserInteractionEnabled = true
        sparkleImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sparkleTapped)))
        // Actively wrong: explicitly opted into the accessibility tree
        // AND marked as a button, implying a real discoverable control
        // exists here when there's nothing meaningful behind it.
        sparkleImageView.isAccessibilityElement = true
        sparkleImageView.accessibilityTraits = .button
        sparkleImageView.srcLine()

        [
            refreshLabel,
            headerLabel,
            linkLabel,
            filterChipView,
            radioStack,
            dialView,
            sparkleImageView
        ].forEach { stack.addArrangedSubview($0) }

        refreshLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        dialView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        dialView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    private func makeShippingRow(title: String, index: Int) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = title
        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.isHidden = index != selectedShippingOption
        let rowStack = UIStackView(arrangedSubviews: [label, UIView(), checkmark])
        rowStack.axis = .horizontal
        container.addSubview(rowStack)
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: container.topAnchor),
            rowStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            rowStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        container.isUserInteractionEnabled = true
        container.tag = index
        // Not grouped, no traits — reads as two disconnected, non-
        // interactive elements (label, then an unlabeled checkmark image
        // when present) instead of one selectable row.
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shippingRowTapped(_:))))
        container.srcLine()
        return container
    }

    @objc private func refreshTapped() { /* refresh action */ }
    @objc private func linkTapped() { /* open URL */ }

    @objc private func filterChipTapped() {
        isWifiOnlyFilterOn.toggle()
        filterCheckImageView.image = UIImage(systemName: isWifiOnlyFilterOn ? "checkmark.square.fill" : "square")
    }

    @objc private func shippingRowTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }
        selectedShippingOption = row.tag
    }

    @objc private func sparkleTapped() { /* hidden easter egg */ }
}
