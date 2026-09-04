import UIKit

/// STATE — Fail tier, custom controls.
///
/// Ten hand-built controls. Where Partial left state absent or stale, this
/// file asserts state that is wrong: values inverted or hardcoded, .selected
/// applied to every option at once, .notEnabled on working controls, and
/// grouped elements torn apart so the state indicator becomes an orphaned,
/// unlabeled image.
/// Deliberately broken; reference only.
///
/// Element-by-element:
///   1.  Custom switch          — value inverted against isOn
///   2.  Custom checkbox        — value hardcoded "Checked", always
///   3.  Radio group rows       — .selected on EVERY row
///   4.  Filter chip            — .selected permanently, value hardcoded "Off"
///   5.  Custom segmented strip — .selected on every segment
///   6.  Custom disabled button — .notEnabled on a fully working button
///   7.  Favorite star toggle   — .selected hardcoded, value hardcoded "On"
///   8.  Disclosure row         — value hardcoded "Collapsed" while expanded
///   9.  Star rating            — .adjustable with a frozen value of 5
///   10. Multi-select rows      — not grouped; state is a bare checkmark image
final class AccessibleStateFailViewController: UIViewController {

    // MARK: - Controls

    private let switchRow = FailSwitchRow(title: "Enable notifications").srcLine()
    private let checkboxRow = FailCheckboxRow(title: "I agree to the Terms of Service").srcLine()
    private var shippingRowViews: [UIView] = []
    private let filterChipRow = FailChipRow(title: "Wi-Fi Only").srcLine()
    private let segmentStack = UIStackView()
    private var segmentButtons: [UIButton] = []
    private let saveDraftButton = UIButton(type: .system).srcLine()
    private let favoriteStarRow = FailChipRow(title: "Favorite", symbolOn: "star.fill", symbolOff: "star").srcLine()
    private let disclosureRow = FailDisclosureRow(title: "Shipping details").srcLine()
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
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    // MARK: - Layout

    private func buildLayout() {
        // 3. Radio group — .selected on all three rows. A single-choice
        // group that reports three simultaneous choices.
        let radioStack = UIStackView()
        radioStack.axis = .vertical
        radioStack.spacing = 12
        for (index, option) in shippingOptions.enumerated() {
            let row = makeSelectableRow(title: option, index: index, action: #selector(shippingRowTapped(_:))).srcLine()
            row.isAccessibilityElement = true
            row.accessibilityLabel = option
            row.accessibilityTraits = [.button, .selected]
            if let checkmark = row.viewWithTag(900) {
                checkmark.isHidden = index != selectedShippingOption
            }
            shippingRowViews.append(row)
            radioStack.addArrangedSubview(row)
        }

        // 5. Custom segmented strip — every segment claims to be selected.
        segmentStack.axis = .horizontal
        segmentStack.distribution = .fillEqually
        for (index, option) in colorOptions.enumerated() {
            let button = UIButton(type: .system).srcLine()
            button.setTitle(option, for: .normal)
            button.tag = index
            button.accessibilityLabel = option
            button.accessibilityTraits = [.button, .selected]
            button.addAction(UIAction { [weak self] _ in
                self?.selectSegment(index)
            }, for: .touchUpInside)
            segmentButtons.append(button)
            segmentStack.addArrangedSubview(button)
        }
        highlightSelectedSegment()

        // 6. Custom disabled button — the inverse failure. The button is
        // enabled, styled normally, and does real work, but is announced
        // as dimmed so VoiceOver users skip past a primary action.
        saveDraftButton.setTitle("Save Draft", for: .normal)
        saveDraftButton.isEnabled = true
        saveDraftButton.accessibilityLabel = "Save draft"
        saveDraftButton.accessibilityTraits = [.button, .notEnabled]
        saveDraftButton.addAction(UIAction { _ in /* saves the draft */ }, for: .touchUpInside)

        // 9. Star rating — .adjustable with no increment/decrement support
        // and a value frozen at the maximum. Swiping does nothing and the
        // reported rating is wrong from the first focus.
        ratingView.isAccessibilityElement = true
        ratingView.accessibilityTraits = .adjustable
        ratingView.accessibilityLabel = "Rating"
        ratingView.accessibilityValue = "5 out of 5 stars"

        // 10. Multi-select rows — the container is NOT an accessibility
        // element, so each row splinters into a text label plus, when
        // selected, a separate unlabeled checkmark image. Selection state
        // exists only as a floating icon with no owner.
        let tagStack = UIStackView()
        tagStack.axis = .vertical
        tagStack.spacing = 12
        for (index, tag) in tagOptions.enumerated() {
            let row = makeSelectableRow(title: tag, index: index, action: #selector(tagRowTapped(_:))).srcLine()
            row.isAccessibilityElement = false
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
        container.tag = index
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        return container
    }
}

// MARK: - Fail-tier controls (each owns its own, intentionally wrong, accessibility code)

/// Capsule switch whose accessibilityValue reads the WRONG branch of its own
/// ternary — inverted from the very first frame, in both init and toggle.
private final class FailSwitchRow: UIControl {
    private(set) var isOn = true
    private let thumb = UIView()

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = .systemGreen
        layer.cornerRadius = 15.5
        thumb.backgroundColor = .white
        thumb.layer.cornerRadius = 13.5
        addSubview(thumb)

        addTarget(self, action: #selector(toggle), for: .touchUpInside)

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        // Bug: the ternary reads the wrong way round, so the announcement
        // is the exact opposite of the visual state on every toggle.
        accessibilityValue = isOn ? "Off" : "On"
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
        accessibilityValue = isOn ? "Off" : "On"
    }

    override var intrinsicContentSize: CGSize { CGSize(width: 51, height: 31) }
}

/// Square/checkmark checkbox hardcoded to "Checked" — a user relying on this
/// believes they have accepted terms they have not.
private final class FailCheckboxRow: UIControl {
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
        // Bug: hardcoded literal instead of reading isChecked.
        accessibilityValue = "Checked"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isChecked.toggle()
        imageView.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
        // accessibilityValue stays "Checked" forever — never touched again.
    }
}

/// Icon + title pill used for both the filter chip and the favorite toggle.
/// .selected is forced on permanently and the value is a fixed literal that
/// never tracks isOn — trait and value both lie, independently of each other.
private final class FailChipRow: UIControl {
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
        // Bug: permanently .selected regardless of isOn, and a fixed value
        // that never changes either — neither one tracks the real control.
        accessibilityTraits = [.button, .selected]
        accessibilityValue = "Off"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isOn.toggle()
        imageView.image = UIImage(systemName: isOn ? symbolOn : symbolOff)
        // Neither accessibilityTraits nor accessibilityValue is ever touched here.
    }
}

/// Title + chevron that expands/collapses a detail label — always reports
/// "Collapsed", including while the detail content is visible on screen.
private final class FailDisclosureRow: UIControl {
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
        // Bug: hardcoded literal instead of reading isExpanded, and no
        // notification posted when the tree changes shape either.
        accessibilityValue = "Collapsed"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isExpanded.toggle()
        detailLabel.isHidden = !isExpanded
        chevron.image = UIImage(systemName: isExpanded ? "chevron.down" : "chevron.right")
        // accessibilityValue stays "Collapsed" forever — never touched again.
    }
}
