import UIKit

/// Partial tier: visible text/content is all still present, but
/// accessibilityTraits are simply omitted rather than set correctly.
/// Buttons and links read as plain text, the filter chip never announces
/// its selected state, radio rows never reveal which is chosen, and the
/// adjustable dial has no way to be adjusted under VoiceOver at all.
final class AccessibleRolePartialViewController: UIViewController {

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
        title = "Accessible Roles (Partial)"
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

        // MARK: Custom button — role omitted
        refreshLabel.text = "Refresh"
        refreshLabel.textColor = .white
        refreshLabel.textAlignment = .center
        refreshLabel.backgroundColor = .systemBlue
        refreshLabel.layer.cornerRadius = 8
        refreshLabel.layer.masksToBounds = true
        refreshLabel.isUserInteractionEnabled = true
        refreshLabel.isAccessibilityElement = true
        // No accessibilityTraits — reads as "Refresh" with no indication
        // it's actionable.
        refreshLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(refreshTapped)))

        // MARK: Section header — role omitted
        headerLabel.text = "Connectivity"
        headerLabel.font = .preferredFont(forTextStyle: .headline)
        // No .header trait — looks like a heading, isn't one for the rotor.

        // MARK: Custom link — role omitted
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        linkLabel.attributedText = NSAttributedString(string: "View documentation", attributes: linkAttributes)
        linkLabel.isUserInteractionEnabled = true
        linkLabel.isAccessibilityElement = true
        // No .link trait — VoiceOver can't distinguish this from any
        // other line of plain text.
        linkLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(linkTapped)))

        // MARK: Custom filter chip — role incomplete
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
        filterChipView.isAccessibilityElement = true
        // .button is set, so VoiceOver knows it's actionable — but
        // .selected is never applied, so on/off state is invisible.
        filterChipView.accessibilityTraits = .button
        filterChipView.accessibilityLabel = "Wi-Fi Only"
        filterChipView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterChipTapped)))

        // MARK: Custom radio-style rows — role incomplete
        let radioStack = UIStackView()
        radioStack.axis = .vertical
        radioStack.spacing = 12
        for (index, option) in shippingOptions.enumerated() {
            let row = makeShippingRow(title: option, index: index)
            shippingRowViews.append(row)
            radioStack.addArrangedSubview(row)
        }

        // MARK: Custom adjustable dial — role omitted entirely
        dialView.onValueChanged = { _ in }
        dialView.accessibilityLabel = "Brightness"
        dialView.accessibilityValue = "\(Int(dialView.value * 100)) percent"
        // No .adjustable trait, no accessibilityIncrement/Decrement
        // overrides — VoiceOver focuses this and reads its value, but
        // swiping up/down does nothing at all.

        // MARK: Decorative icon — left at default
        sparkleImageView.isUserInteractionEnabled = true
        sparkleImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sparkleTapped)))
        // isAccessibilityElement left false (UIImageView's default) —
        // harmless here since it happens to match "correct," but this is
        // an accident of the default, not a deliberate choice, and a
        // common source of confusion: developers who DO set it true (to
        // make an icon findable) often forget the matching trait.

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
        container.isAccessibilityElement = true
        container.tag = index
        // Every row gets .button, but none is ever marked .selected —
        // VoiceOver users can't tell which shipping option is chosen.
        container.accessibilityTraits = .button
        container.accessibilityLabel = title
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shippingRowTapped(_:))))
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

/// A hand-built dial with NO accessibilityIncrement/Decrement overrides and
/// no .adjustable trait. Sighted users can drag it; VoiceOver users have no
/// equivalent way to change its value at all.
final class PlainDialControl: UIView {

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

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect.insetBy(dx: 3, dy: 3))
        UIColor.systemGray4.setStroke()
        path.lineWidth = 6
        path.stroke()
    }
}
