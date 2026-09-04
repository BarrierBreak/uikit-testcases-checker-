import UIKit

/// STATE — Partial tier, custom controls.
///
/// Ten hand-built controls. Every one has a correct NAME and a plausible
/// ROLE — a checker looking only at accessibilityLabel or
/// accessibilityTraits.button passes all ten.
///
/// What is missing in each case is the state itself: it is either never
/// set, set once at build time and never refreshed, refreshed through a
/// helper this scan cannot fully trace, or refreshed in the visual code
/// path but not the accessibility one.
///
/// Element-by-element:
///   1.  Custom switch          — value set once at launch, never updated
///   2.  Custom checkbox        — no accessibilityValue at all
///   3.  Radio group rows       — .button on all, .selected on none
///   4.  Filter chip            — updates through two levels of helper calls
///   5.  Custom segmented strip — background highlight only, no .selected
///   6.  Custom disabled button — dimmed with alpha, isEnabled still true
///   7.  Favorite star toggle   — image swaps, no value, no .selected
///   8.  Disclosure row         — no expanded/collapsed state, no post
///   9.  Star rating            — .adjustable trait but no increment override
///   10. Multi-select rows      — selection tracked but never announced
final class AccessibleStatePartialViewController: UIViewController {

    // MARK: - Controls

    private let switchRow = PartialSwitchRow(title: "Enable notifications").srcLine()
    private let checkboxRow = PartialCheckboxRow(title: "I agree to the Terms of Service").srcLine()
    private var shippingRowViews: [UIView] = []
    private let filterChipRow = PartialChipRow(title: "Wi-Fi Only").srcLine()
    private let segmentStack = UIStackView()
    private var segmentButtons: [UIButton] = []
    private let saveDraftButton = UIButton(type: .system).srcLine()
    private let favoriteStarRow = PartialFavoriteRow(title: "Favorite", symbolOn: "star.fill", symbolOff: "star").srcLine()
    private let disclosureRow = PartialDisclosureRow(title: "Shipping details").srcLine()
    private let ratingView = StateStarRatingView(maximumRating: 5).srcLine()
    private var tagRowViews: [UIView] = []

    private var selectedShippingOption = 0
    private let shippingOptions = ["Standard (5-7 days)", "Express (2-3 days)", "Overnight"]
    private var selectedSegmentIndex = 2
    private let colorOptions = ["Red", "Green", "Blue"]
    private let tagOptions = ["Work", "Personal", "Urgent"]
    private var selectedTags: Set<Int> = [0]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom State (Partial)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 3. Radio group — every row is announced as a button, none is
        // ever marked .selected. The checkmark is visible; the state is not.
        let radioStack = UIStackView()
        radioStack.axis = .vertical
        radioStack.spacing = 12
        for (index, option) in shippingOptions.enumerated() {
            let row = makeSelectableRow(title: option, index: index, action: #selector(shippingRowTapped(_:))).srcLine()
            row.accessibilityLabel = option
            row.accessibilityTraits = .button // Bug: .selected never added
            if let checkmark = row.viewWithTag(900) {
                checkmark.isHidden = index != selectedShippingOption
            }
            shippingRowViews.append(row)
            radioStack.addArrangedSubview(row)
        }

        // 5. Custom segmented strip — selection is conveyed purely by a
        // background colour change, which VoiceOver cannot perceive.
        segmentStack.axis = .horizontal
        segmentStack.distribution = .fillEqually
        for (index, option) in colorOptions.enumerated() {
            let button = UIButton(type: .system).srcLine()
            button.setTitle(option, for: .normal)
            button.tag = index
            button.accessibilityLabel = option
            button.accessibilityTraits = .button // Bug: .selected never added
            button.addAction(UIAction { [weak self] _ in
                self?.selectSegment(index)
            }, for: .touchUpInside)
            segmentButtons.append(button)
            segmentStack.addArrangedSubview(button)
        }
        highlightSelectedSegment()

        // 6. Custom disabled button — dimmed visually only. isEnabled is
        // still true, so there is no .notEnabled trait and the button is
        // still focusable and activatable.
        saveDraftButton.setTitle("Save Draft", for: .normal)
        saveDraftButton.accessibilityLabel = "Save draft"
        saveDraftButton.alpha = 0.4
        saveDraftButton.addAction(UIAction { _ in
            // Intentionally does nothing — it is "disabled" in appearance
            // only, which reads as a broken button to VoiceOver users.
        }, for: .touchUpInside)

        // 9. Star rating — grouped, named, and marked .adjustable, so
        // VoiceOver offers swipe up/down. But StateStarRatingView has no
        // accessibilityIncrement/Decrement override, so the gesture does
        // nothing and the value is never announced.
        ratingView.isAccessibilityElement = true
        ratingView.accessibilityTraits = .adjustable
        ratingView.accessibilityLabel = "Rating"
        // Bug: no accessibilityValue, no working increment/decrement.

        // 10. Multi-select rows — the set is maintained in code and the
        // checkmarks update, but no row ever carries .selected.
        let tagStack = UIStackView()
        tagStack.axis = .vertical
        tagStack.spacing = 12
        for (index, tag) in tagOptions.enumerated() {
            let row = makeSelectableRow(title: tag, index: index, action: #selector(tagRowTapped(_:))).srcLine()
            row.accessibilityLabel = tag
            row.accessibilityTraits = .button // Bug: .selected never added
            if let checkmark = row.viewWithTag(900) {
                checkmark.isHidden = !selectedTags.contains(index)
            }
            tagRowViews.append(row)
            tagStack.addArrangedSubview(row)
        }

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
        let container = UIStackView(arrangedSubviews: [label, control])
        container.axis = .vertical
        container.spacing = 6
        container.alignment = .leading
        return container
    }

    // MARK: - Actions (visual only)

    private func selectSegment(_ index: Int) {
        selectedSegmentIndex = index
        highlightSelectedSegment()
    }

    private func highlightSelectedSegment() {
        for (index, button) in segmentButtons.enumerated() {
            button.backgroundColor = index == selectedSegmentIndex ? .systemGray5 : .clear
        }
    }

    @objc private func shippingRowTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }
        selectedShippingOption = row.tag
        for (index, view) in shippingRowViews.enumerated() {
            view.viewWithTag(900)?.isHidden = index != selectedShippingOption
        }
        // Bug: traits are never refreshed here.
    }

    @objc private func tagRowTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }
        if selectedTags.contains(row.tag) {
            selectedTags.remove(row.tag)
        } else {
            selectedTags.insert(row.tag)
        }
        for (index, view) in tagRowViews.enumerated() {
            view.viewWithTag(900)?.isHidden = !selectedTags.contains(index)
        }
        // Bug: traits are never refreshed here either.
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
        container.isAccessibilityElement = true
        container.tag = index
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        return container
    }
}

// MARK: - Partial-tier controls

/// Capsule switch — value written once during setup and never refreshed in
/// the action method. The thumb slides, the announcement never changes.
private final class PartialSwitchRow: UIControl {
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
        // Bug: set once here, never touched again in toggle() below.
        accessibilityValue = "Off"
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
        // Bug: accessibilityValue is never refreshed here.
    }

    override var intrinsicContentSize: CGSize { CGSize(width: 51, height: 31) }
}

/// Square/checkmark checkbox — grouped and named correctly, but no value is
/// ever set, so checked and unchecked sound identical.
private final class PartialCheckboxRow: UIControl {
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
        // Bug: no accessibilityValue anywhere in this class at all.
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isChecked.toggle()
        imageView.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
    }
}

/// Filter chip — updates its accessibility state through two levels of
/// helper calls (toggle -> applyState -> refreshAccessibility), one level
/// past what a static scan follows before giving up and asking for a
/// manual check rather than guessing.
private final class PartialChipRow: UIControl {
    private(set) var isOn = false
    private let imageView = UIImageView(image: UIImage(systemName: "square"))
    private let titleLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
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
        refreshAccessibility()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isOn.toggle()
        imageView.image = UIImage(systemName: isOn ? "checkmark.square.fill" : "square")
        applyState()
    }

    private func applyState() {
        refreshAccessibility()
    }

    private func refreshAccessibility() {
        accessibilityValue = isOn ? "On" : "Off"
    }
}

/// Favorite star toggle — the star fills in, nothing else changes: no
/// value, no .selected, no refresh on toggle at all.
private final class PartialFavoriteRow: UIControl {
    private(set) var isOn = false
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let symbolOn: String
    private let symbolOff: String

    init(title: String, symbolOn: String, symbolOff: String) {
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
        accessibilityTraits = .button
        accessibilityLabel = title
        // Bug: no accessibilityValue anywhere in this class at all.
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isOn.toggle()
        imageView.image = UIImage(systemName: isOn ? symbolOn : symbolOff)
        // Bug: no value, no .selected, no refresh — purely visual.
    }
}

/// Title + chevron disclosure row — announced as a button, but nothing
/// indicates whether the section is open or closed, and no notification is
/// posted when the content appears.
private final class PartialDisclosureRow: UIControl {
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
        // Bug: no accessibilityValue, no .layoutChanged post.
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isExpanded.toggle()
        detailLabel.isHidden = !isExpanded
        chevron.image = UIImage(systemName: isExpanded ? "chevron.down" : "chevron.right")
    }
}
