import UIKit

/// UIKit equivalent of AccessibleRolePass: every custom control gets the
/// correct `accessibilityTraits` for how it behaves — .button, .link,
/// .header, .selected, .adjustable — instead of relying on whatever
/// UIKit assumes by default.
final class AccessibleRolePassViewController: UIViewController {

    private let refreshLabel = UILabel()
    private let headerLabel = UILabel()
    private let linkLabel = UILabel()
    private let filterChipView = UIView()
    private let filterCheckImageView = UIImageView()
    private let filterTextLabel = UILabel()
    private var shippingRowViews: [UIView] = []
    private let dialView = DialControl()
    private let sparkleImageView = UIImageView(image: UIImage(systemName: "sparkle"))

    private var isWifiOnlyFilterOn = false
    private var selectedShippingOption = 0
    private let shippingOptions = ["Standard (5-7 days)", "Express (2-3 days)", "Overnight"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accessible Roles (Pass)"
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

        // MARK: Custom button
        refreshLabel.text = "Refresh"
        refreshLabel.textColor = .white
        refreshLabel.textAlignment = .center
        refreshLabel.backgroundColor = .systemBlue
        refreshLabel.layer.cornerRadius = 8
        refreshLabel.layer.masksToBounds = true
        refreshLabel.isUserInteractionEnabled = true
        refreshLabel.isAccessibilityElement = true
        // Correct role: VoiceOver announces "Refresh, button".
        refreshLabel.accessibilityTraits = .button
        refreshLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(refreshTapped)))
        refreshLabel.srcLine()

        // MARK: Section header
        headerLabel.text = "Connectivity"
        headerLabel.font = .preferredFont(forTextStyle: .headline)
        // Correct role: rotor-navigable as a heading.
        headerLabel.accessibilityTraits = .header
        headerLabel.srcLine()

        // MARK: Custom link
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        linkLabel.attributedText = NSAttributedString(string: "View documentation", attributes: linkAttributes)
        linkLabel.isUserInteractionEnabled = true
        linkLabel.isAccessibilityElement = true
        // Correct role: VoiceOver announces "View documentation, link".
        linkLabel.accessibilityTraits = .link
        linkLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkTapped)))
        linkLabel.srcLine()

        // MARK: Custom filter chip
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
        filterChipView.isAccessibilityElement = true // combines children into one element
        updateFilterChipAccessibility()
        filterChipView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterChipTapped)))
        filterChipView.srcLine()

        // MARK: Custom radio-style rows
        let radioStack = UIStackView()
        radioStack.axis = .vertical
        radioStack.spacing = 12
        for (index, option) in shippingOptions.enumerated() {
            let row = makeShippingRow(title: option, index: index)
            shippingRowViews.append(row)
            radioStack.addArrangedSubview(row)
        }
        updateShippingRowsAccessibility()

        // MARK: Custom adjustable dial
        dialView.onValueChanged = { [weak self] _ in self?.updateDialAccessibility() }
        dialView.isAccessibilityElement = true
        dialView.accessibilityLabel = "Brightness"
        // Correct role: adjustable, with increment/decrement handled by
        // DialControl's overrides below.
        dialView.accessibilityTraits = .adjustable
        dialView.srcLine()
        updateDialAccessibility()

        // MARK: Decorative icon — correctly excluded from accessibility
        sparkleImageView.isUserInteractionEnabled = true
        sparkleImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sparkleTapped)))
        // Correct role: nothing essential here, so it's removed from the
        // accessibility tree entirely (UIImageView defaults to NOT being
        // an accessibility element, so leaving isAccessibilityElement
        // false here is the deliberate, correct choice).
        sparkleImageView.isAccessibilityElement = false
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
        checkmark.tag = 100
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
        container.isAccessibilityElement = true // combines label + checkmark into one element
        container.tag = index
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shippingRowTapped(_:))))
        container.srcLine()
        return container
    }

    private func updateFilterChipAccessibility() {
        filterCheckImageView.image = UIImage(systemName: isWifiOnlyFilterOn ? "checkmark.square.fill" : "square")
        // Correct role: button trait so VoiceOver knows it's actionable,
        // PLUS .selected reflecting current state.
        filterChipView.accessibilityTraits = isWifiOnlyFilterOn ? [.button, .selected] : .button
        filterChipView.accessibilityLabel = "Wi-Fi Only"
        filterChipView.accessibilityValue = isWifiOnlyFilterOn ? "On" : "Off"
    }

    private func updateShippingRowsAccessibility() {
        for (index, row) in shippingRowViews.enumerated() {
            let isSelected = index == selectedShippingOption
            row.accessibilityLabel = shippingOptions[index]
            // Correct role: every row is a button, and .selected marks
            // exactly one as the current choice.
            row.accessibilityTraits = isSelected ? [.button, .selected] : .button
            if let checkmark = row.viewWithTag(100) {
                checkmark.isHidden = !isSelected
            }
        }
    }

    private func updateDialAccessibility() {
        dialView.accessibilityValue = "\(Int(dialView.value * 100)) percent"
    }

    @objc private func refreshTapped() { /* refresh action */ }
    @objc private func linkTapped() { /* open URL */ }

    @objc private func filterChipTapped() {
        isWifiOnlyFilterOn.toggle()
        updateFilterChipAccessibility()
    }

    @objc private func shippingRowTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }
        selectedShippingOption = row.tag
        updateShippingRowsAccessibility()
    }

    @objc private func sparkleTapped() { /* hidden easter egg, not core functionality */ }
}

/// A hand-built adjustable dial. Overriding accessibilityIncrement/
/// accessibilityDecrement is what makes the `.adjustable` trait actually
/// functional under VoiceOver — without these overrides, the trait alone
/// does nothing.
final class DialControl: UIView {

    private(set) var value: Double = 0.5
    var onValueChanged: ((Double) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        value = min(max(location.x / bounds.width, 0), 1)
        onValueChanged?(value)
        setNeedsDisplay()
    }

    override func accessibilityIncrement() {
        value = min(value + 0.1, 1)
        onValueChanged?(value)
    }

    override func accessibilityDecrement() {
        value = max(value - 0.1, 0)
        onValueChanged?(value)
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect.insetBy(dx: 3, dy: 3))
        UIColor.systemGray4.setStroke()
        path.lineWidth = 6
        path.stroke()
    }
}
