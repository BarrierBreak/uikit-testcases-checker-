import UIKit

/// STATE — Pass tier, custom controls.
///
/// Ten hand-built controls. None of these is a real UIKit control, so
/// NOTHING about their state reaches VoiceOver for free — every on/off,
/// selected, expanded, disabled and value has to be re-derived by hand and
/// kept in sync on every change.
///
/// The rule this file demonstrates: whenever the visual state changes, the
/// accessibility state must change in the same code path — each control
/// below keeps its own accessibility state update inside its own action
/// method (or a helper it calls), for exactly that reason.
///
/// Elements covered (10) — all 10 require explicit state work:
///   1.  Custom switch          — accessibilityValue "On"/"Off"
///   2.  Custom checkbox        — accessibilityValue "Checked"/"Unchecked"
///   3.  Radio group rows       — .selected on exactly one row
///   4.  Filter chip            — .selected + value
///   5.  Custom segmented strip — .selected on the active segment
///   6.  Custom disabled button — .notEnabled trait
///   7.  Favorite star toggle   — .selected + value
///   8.  Disclosure row         — "Expanded"/"Collapsed" + layout change post
///   9.  Star rating            — .adjustable + live value
///   10. Multi-select rows      — .selected on each chosen row
final class AccessibleStatePassViewController: UIViewController {

    // MARK: - Controls

    private let switchRow = PassSwitchRow(title: "Enable notifications").srcLine()
    private let checkboxRow = PassCheckboxRow(title: "I agree to the Terms of Service").srcLine()
    private var shippingRowViews: [UIView] = []
    private let filterChipRow = PassChipRow(title: "Wi-Fi Only").srcLine()
    private let segmentStack = UIStackView()
    private var segmentButtons: [UIButton] = []
    private let saveDraftButton = UIButton(type: .system).srcLine()
    private let favoriteStarRow = PassChipRow(title: "Favorite", symbolOn: "star.fill", symbolOff: "star").srcLine()
    private let disclosureRow = PassDisclosureRow(title: "Shipping details").srcLine()
    private let ratingView = AdjustableStateStarRatingView(maximumRating: 5).srcLine()
    private var tagRowViews: [UIView] = []

    private var selectedShippingOption = 0
    private let shippingOptions = ["Standard (5-7 days)", "Express (2-3 days)", "Overnight"]
    private var selectedSegmentIndex = 2
    private let colorOptions = ["Red", "Green", "Blue"]
    private let tagOptions = ["Work", "Personal", "Urgent"]
    private var selectedTags: Set<Int> = [0]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom State (Pass)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 3. Radio group — every row is a button, and exactly one carries
        // .selected. This is what tells VoiceOver which option is current.
        let radioStack = UIStackView()
        radioStack.axis = .vertical
        radioStack.spacing = 12
        for (index, option) in shippingOptions.enumerated() {
            let row = makeSelectableRow(title: option, index: index, action: #selector(shippingRowTapped(_:))).srcLine()
            shippingRowViews.append(row)
            radioStack.addArrangedSubview(row)
        }
        refreshShippingRows()

        // 5. Custom segmented strip — .selected marks the active segment
        // and is cleared from the others on every change.
        segmentStack.axis = .horizontal
        segmentStack.distribution = .fillEqually
        for (index, option) in colorOptions.enumerated() {
            let button = UIButton(type: .system).srcLine()
            button.setTitle(option, for: .normal)
            button.tag = index
            button.accessibilityLabel = option
            button.addAction(UIAction { [weak self] _ in
                self?.selectSegment(index)
            }, for: .touchUpInside)
            segmentButtons.append(button)
            segmentStack.addArrangedSubview(button)
        }
        refreshSegments()

        // 6. Custom disabled button — a plain UIButton styled as disabled.
        // isEnabled is set for real, so .notEnabled comes along with it and
        // the button is genuinely inert.
        saveDraftButton.setTitle("Save Draft", for: .normal)
        saveDraftButton.accessibilityLabel = "Save draft"
        saveDraftButton.accessibilityHint = "Add a title to enable"
        saveDraftButton.isEnabled = false
        saveDraftButton.alpha = 0.4

        // 9. Star rating — a value state, so .adjustable plus a live
        // accessibilityValue, with increment/decrement overridden in
        // AdjustableStateStarRatingView.
        ratingView.isAccessibilityElement = true
        ratingView.accessibilityTraits = .adjustable
        ratingView.accessibilityLabel = "Rating"
        ratingView.onRatingChanged = { [weak self] in self?.refreshRating() }
        refreshRating()

        // 10. Multi-select rows — more than one row can carry .selected at
        // the same time, which is what distinguishes this from the radio
        // group above.
        let tagStack = UIStackView()
        tagStack.axis = .vertical
        tagStack.spacing = 12
        for (index, tag) in tagOptions.enumerated() {
            let row = makeSelectableRow(title: tag, index: index, action: #selector(tagRowTapped(_:))).srcLine()
            tagRowViews.append(row)
            tagStack.addArrangedSubview(row)
        }
        refreshTagRows()

        let stack = UIStackView(arrangedSubviews: [
            row(title: "Notifications", control: switchRow),
            checkboxRow,
            radioStack,
            filterChipRow,
            segmentStack,
            saveDraftButton,
            favoriteStarRow,
            disclosureRow,
            ratingView,
            tagStack
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
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

        switchRow.widthAnchor.constraint(equalToConstant: 51).isActive = true
        switchRow.heightAnchor.constraint(equalToConstant: 31).isActive = true
    }

    private func row(title: String, control: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        label.accessibilityTraits = .header
        let container = UIStackView(arrangedSubviews: [label, control])
        container.axis = .vertical
        container.spacing = 6
        container.alignment = .leading
        return container
    }

    // MARK: - State refresh (visual + accessibility in the same path)

    private func refreshShippingRows() {
        for (index, row) in shippingRowViews.enumerated() {
            let isSelected = index == selectedShippingOption
            row.accessibilityLabel = shippingOptions[index]
            row.accessibilityTraits = isSelected ? [.button, .selected] : .button
            if let checkmark = row.viewWithTag(900) {
                checkmark.isHidden = !isSelected
            }
        }
    }

    private func refreshSegments() {
        for (index, button) in segmentButtons.enumerated() {
            let isSelected = index == selectedSegmentIndex
            button.backgroundColor = isSelected ? .systemGray5 : .clear
            button.accessibilityTraits = isSelected ? [.button, .selected] : .button
        }
    }

    private func refreshRating() {
        ratingView.accessibilityValue = "\(ratingView.rating) out of \(ratingView.maximumRating) stars"
    }

    private func refreshTagRows() {
        for (index, row) in tagRowViews.enumerated() {
            let isSelected = selectedTags.contains(index)
            row.accessibilityLabel = tagOptions[index]
            row.accessibilityTraits = isSelected ? [.button, .selected] : .button
            if let checkmark = row.viewWithTag(900) {
                checkmark.isHidden = !isSelected
            }
        }
    }

    // MARK: - Actions

    private func selectSegment(_ index: Int) {
        selectedSegmentIndex = index
        refreshSegments()
    }

    @objc private func shippingRowTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }
        selectedShippingOption = row.tag
        refreshShippingRows()
    }

    @objc private func tagRowTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }
        if selectedTags.contains(row.tag) {
            selectedTags.remove(row.tag)
        } else {
            selectedTags.insert(row.tag)
        }
        refreshTagRows()
    }

    // MARK: - Helpers

    private func makeSelectableRow(title: String, index: Int, action: Selector) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = title
        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.tag = 900
        let rowStack = UIStackView(arrangedSubviews: [label, UIView(), checkmark])
        rowStack.axis = .horizontal
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(rowStack)
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: container.topAnchor),
            rowStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            rowStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        container.isUserInteractionEnabled = true
        container.isAccessibilityElement = true // one element per row
        container.tag = index
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        return container
    }
}

// MARK: - Pass-tier controls (each keeps its own accessibility state in sync)

/// Capsule switch — one element carrying label + live value, refreshed
/// directly inside its own action method.
private final class PassSwitchRow: UIControl {
    private(set) var isOn = false
    private let thumb = UIView()

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = .systemGray4
        layer.cornerRadius = 15.5
        thumb.backgroundColor = .white
        thumb.layer.cornerRadius = 13.5
        addSubview(thumb)

        addTarget(self, action: #selector(toggle), for: .touchUpInside)

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        accessibilityValue = isOn ? "On" : "Off"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let side: CGFloat = 27
        thumb.frame = CGRect(x: isOn ? bounds.width - side - 2 : 2, y: 2, width: side, height: side)
    }

    @objc private func toggle() {
        isOn.toggle()
        backgroundColor = isOn ? .systemGreen : .systemGray4
        setNeedsLayout()
        accessibilityValue = isOn ? "On" : "Off"
    }

    override var intrinsicContentSize: CGSize { CGSize(width: 51, height: 31) }
}

/// Square/checkmark checkbox — the inner image and label are folded into a
/// single element so the checked state is announced with the name.
private final class PassCheckboxRow: UIControl {
    private(set) var isChecked = false
    private let imageView = UIImageView(image: UIImage(systemName: "square"))
    private let titleLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addTarget(self, action: #selector(toggle), for: .touchUpInside)

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        accessibilityValue = isChecked ? "Checked" : "Unchecked"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isChecked.toggle()
        imageView.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
        accessibilityValue = isChecked ? "Checked" : "Unchecked"
    }
}

/// Icon + title pill used for both the filter chip and the favorite toggle.
/// On/off state is expressed BOTH as .selected and as a value, since a chip
/// reads as a toggle to sighted users.
private final class PassChipRow: UIControl {
    private(set) var isOn = false
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let symbolOn: String
    private let symbolOff: String

    init(title: String, symbolOn: String = "checkmark.square.fill", symbolOff: String = "square") {
        self.symbolOn = symbolOn
        self.symbolOff = symbolOff
        super.init(frame: .zero)
        titleLabel.text = title
        imageView.image = UIImage(systemName: symbolOff)
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addTarget(self, action: #selector(toggle), for: .touchUpInside)

        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityTraits = isOn ? [.button, .selected] : .button
        accessibilityValue = isOn ? "On" : "Off"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isOn.toggle()
        imageView.image = UIImage(systemName: isOn ? symbolOn : symbolOff)
        accessibilityTraits = isOn ? [.button, .selected] : .button
        accessibilityValue = isOn ? "On" : "Off"
    }
}

/// Title + chevron disclosure row — expanded/collapsed is a state, not just
/// an animation. .layoutChanged tells VoiceOver the tree moved.
private final class PassDisclosureRow: UIControl {
    private(set) var isExpanded = false
    private let titleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let detailLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        detailLabel.text = "Ships from Mumbai. Arrives in 5-7 business days."
        detailLabel.numberOfLines = 0
        detailLabel.isHidden = true

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), chevron])
        headerStack.axis = .horizontal
        let outerStack = UIStackView(arrangedSubviews: [headerStack, detailLabel])
        outerStack.axis = .vertical
        outerStack.spacing = 8
        outerStack.isUserInteractionEnabled = false
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerStack)
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            outerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addTarget(self, action: #selector(toggle), for: .touchUpInside)

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        updateAccessibility()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isExpanded.toggle()
        detailLabel.isHidden = !isExpanded
        chevron.image = UIImage(systemName: isExpanded ? "chevron.down" : "chevron.right")
        updateAccessibility()
        UIAccessibility.post(notification: .layoutChanged, argument: self)
    }

    private func updateAccessibility() {
        accessibilityValue = isExpanded ? "Expanded" : "Collapsed"
    }
}

// MARK: - Shared visual-only controls (rating only — not a boolean toggle,
// out of scope for the toggle-shaped state rules; see the module doc comment
// on why radio/segmented/disabled/rating/multi-select stay untouched)

/// Row of tappable star buttons. Visual only — no traits, no value.
class StateStarRatingView: UIView {
    let maximumRating: Int
    private(set) var rating = 3 {
        didSet {
            updateStars()
            onRatingChanged?()
        }
    }
    var onRatingChanged: (() -> Void)?
    private var starButtons: [UIButton] = []

    init(maximumRating: Int) {
        self.maximumRating = maximumRating
        super.init(frame: .zero)
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        for index in 1...maximumRating {
            let button = UIButton(type: .system)
            button.tag = index
            button.isAccessibilityElement = false // grouped into the container
            button.addAction(UIAction { [weak self] _ in
                self?.rating = index
            }, for: .touchUpInside)
            starButtons.append(button)
            stack.addArrangedSubview(button)
        }
        updateStars()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setRating(_ newValue: Int) {
        rating = min(max(newValue, 1), maximumRating)
    }

    private func updateStars() {
        for button in starButtons {
            button.setImage(UIImage(systemName: button.tag <= rating ? "star.fill" : "star"), for: .normal)
        }
    }
}

/// The Pass-tier rating control. Overriding increment/decrement is what
/// makes the `.adjustable` trait actually operable — the trait alone does
/// nothing without these.
final class AdjustableStateStarRatingView: StateStarRatingView {

    override func accessibilityIncrement() {
        setRating(rating + 1)
    }

    override func accessibilityDecrement() {
        setRating(rating - 1)
    }
}
