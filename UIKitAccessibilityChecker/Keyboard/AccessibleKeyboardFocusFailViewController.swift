//
//  AccessibleKeyboardFocusFailViewController.swift
//
//  FAIL test page — WCAG 2.1.1 Keyboard (Level A)
//  Issue: Interactive control cannot receive keyboard focus.
//
//  40 examples across every common interactive component type. Every control
//  is fully FUNCTIONAL by touch (state changes, menus open, values update),
//  but cannot be reached or operated with a hardware keyboard.
//
//  How to test:
//  1. Pair a hardware keyboard with the iPhone/iPad.
//  2. Settings > Accessibility > Keyboards > Full Keyboard Access = ON.
//  3. Navigate with Tab / Shift+Tab / Arrow keys, activate with Space,
//     open actions with Tab+Z.
//  4. Compare: tap the control (works, status bar updates) vs. keyboard
//     (focus never lands on it / action not available).
//
//  Requirements: iOS 14+, UIKit, programmatic UI (no storyboard).
//

import UIKit

final class AccessibleKeyboardFocusFailViewController: UIViewController {

    // MARK: - Properties

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let statusContainer = UIView()
    private let statusLabel = UILabel()

    /// Closures for every gesture recognizer on the page, keyed by recognizer.
    private var gestureHandlers: [ObjectIdentifier: (UIGestureRecognizer) -> Void] = [:]
    private var sectionCount = 0
    private var mediaTimer: Timer?
    private weak var activeOverlay: UIView?
    private weak var activeToast: UIView?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Keyboard Focus – Fail"
        view.backgroundColor = .systemBackground

        setupLayout()
        addIntro()

        addCategory("Buttons & links")
        addCustomButton()                 // KF-01
        addIconToggleButton()             // KF-02
        addFloatingActionButton()         // KF-03
        addTextLink()                     // KF-04
        addReadMoreLink()                 // KF-05
        addHiddenSystemButton()           // KF-06

        addCategory("Selection controls")
        addCustomCheckbox()               // KF-07
        addCustomRadioGroup()             // KF-08
        addCustomToggleSwitch()           // KF-09
        addHiddenSystemSwitch()           // KF-10
        addFilterChips()                  // KF-11
        addRemovableTags()                // KF-12
        addColourSwatches()               // KF-13
        addStarRating()                   // KF-14

        addCategory("Value & range controls")
        addCustomSlider()                 // KF-15
        addCustomStepper()                // KF-16
        addCustomSegmentedControl()       // KF-17
        addCustomTabs()                   // KF-18

        addCategory("Pickers & dropdowns")
        addCustomDropdown()               // KF-19
        addDateStripPicker()              // KF-20

        addCategory("Text input & keyboard extras")
        addOTPInput()                     // KF-21
        addFakeSearchBar()                // KF-22
        addLoginFormExtras()              // KF-23, KF-24, KF-25

        addCategory("Disclosure & navigation")
        addAccordion()                    // KF-26
        addCarousel()                     // KF-27
        addPagination()                   // KF-28
        addHamburgerMenu()                // KF-29
        addInfoTooltip()                  // KF-30

        addCategory("Overlays & feedback")
        addCustomModalDialog()            // KF-31
        addToastWithUndo()                // KF-32

        addCategory("Gesture-only interactions")
        addSwipeToDelete()                // KF-33
        addLongPressMenu()                // KF-34
        addDoubleTapToLike()              // KF-35
        addSwipeToDecideCard()            // KF-36
        addPinchToZoom()                  // KF-37

        addCategory("Media")
        addCustomMediaPlayer()            // KF-38

        addCategory("Lists & cards")
        addProductCard()                  // KF-39
        addGroupedOrderRow()              // KF-40
    }

    deinit {
        mediaTimer?.invalidate()
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        statusContainer.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        view.addSubview(statusContainer)
        scrollView.addSubview(contentStack)

        contentStack.axis = .vertical
        contentStack.spacing = 28

        statusContainer.backgroundColor = .secondarySystemBackground
        statusLabel.text = "Status: No action yet"
        statusLabel.font = .preferredFont(forTextStyle: .subheadline)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.textColor = .systemBlue
        statusLabel.numberOfLines = 0
        statusContainer.addSubview(statusLabel)

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        statusContainer.addSubview(separator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: statusContainer.topAnchor),

            statusContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            separator.topAnchor.constraint(equalTo: statusContainer.topAnchor),
            separator.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),

            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            statusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    private func addIntro() {
        let intro = makeLabel(
            "This page has 40 failing examples. Every control works by touch, but none can be reached or operated with a hardware keyboard.\n\nTo test: turn on Settings > Accessibility > Keyboards > Full Keyboard Access, then use Tab / Shift+Tab / arrow keys, Space to activate and Tab+Z for actions. The status bar at the bottom shows what each touch action did.",
            style: .subheadline,
            color: .secondaryLabel
        )
        contentStack.addArrangedSubview(intro)
    }

    private func addCategory(_ title: String) {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let label = makeLabel(title)
        label.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 22, weight: .bold))
        label.accessibilityTraits = .header

        contentStack.addArrangedSubview(vStack([divider, label], spacing: 12))
    }

    private func addSection(title: String, failure: String, content: UIView) {
        sectionCount += 1
        let id = String(format: "KF-%02d", sectionCount)

        let titleLabel = makeLabel("\(id): \(title)", style: .headline)
        titleLabel.accessibilityTraits = .header

        let failureLabel = makeLabel("FAIL: \(failure)", style: .footnote, color: .secondaryLabel)

        contentStack.addArrangedSubview(vStack([titleLabel, failureLabel, content], spacing: 8))
    }

    private func report(_ message: String) {
        statusLabel.text = "Status: \(message)"
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    // MARK: - View helpers

    private func makeLabel(_ text: String, style: UIFont.TextStyle = .body, color: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    private func makeIcon(_ systemName: String, size: CGFloat = 32, tint: UIColor = .label) -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: systemName))
        imageView.tintColor = tint
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size),
            imageView.heightAnchor.constraint(equalToConstant: size)
        ])
        return imageView
    }

    private func makeBox(
        _ text: String,
        textColor: UIColor = .label,
        background: UIColor = .secondarySystemBackground,
        cornerRadius: CGFloat = 10,
        vertical: CGFloat = 12,
        horizontal: CGFloat = 16
    ) -> (box: UIView, label: UILabel) {
        let box = UIView()
        box.backgroundColor = background
        box.layer.cornerRadius = cornerRadius

        let label = makeLabel(text, color: textColor)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: box.topAnchor, constant: vertical),
            label.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -vertical),
            label.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: horizontal),
            label.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -horizontal)
        ])
        return (box, label)
    }

    private func makeTextField(placeholder: String) -> UITextField {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = placeholder
        field.accessibilityLabel = placeholder
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return field
    }

    /// Wraps an icon in a fixed-size container for use as a text field rightView.
    private func makeRightViewContainer(for icon: UIView) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        icon.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    private func hStack(
        _ views: [UIView],
        spacing: CGFloat = 8,
        alignment: UIStackView.Alignment = .center,
        distribution: UIStackView.Distribution = .fill
    ) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribution
        return stack
    }

    private func vStack(_ views: [UIView], spacing: CGFloat = 8, alignment: UIStackView.Alignment = .fill) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = alignment
        return stack
    }

    private func spacer() -> UIView {
        let view = UIView()
        view.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        view.setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
        return view
    }

    /// Keeps a view at its natural width, aligned to the leading edge.
    private func leading(_ view: UIView) -> UIStackView {
        hStack([view, spacer()])
    }

    private func wrapRows(_ views: [UIView], perRow: Int, spacing: CGFloat = 8) -> UIStackView {
        var rows: [UIView] = []
        var index = 0
        while index < views.count {
            let slice = Array(views[index..<min(index + perRow, views.count)])
            rows.append(hStack(slice + [spacer()], spacing: spacing))
            index += perRow
        }
        return vStack(rows, spacing: spacing)
    }

    private func pin(_ child: UIView, in parent: UIView, inset: CGFloat = 0) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor, constant: inset),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: inset),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -inset),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -inset)
        ])
    }

    private func center(_ child: UIView, in parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            child.centerYAnchor.constraint(equalTo: parent.centerYAnchor)
        ])
    }

    // MARK: - Gesture helpers

    @discardableResult
    private func addGesture<G: UIGestureRecognizer>(_ gesture: G, to view: UIView, handler: @escaping (G) -> Void) -> G {
        gesture.addTarget(self, action: #selector(handleGesture(_:)))
        gestureHandlers[ObjectIdentifier(gesture)] = { recognizer in
            if let typed = recognizer as? G { handler(typed) }
        }
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gesture)
        return gesture
    }

    private func onTap(_ view: UIView, handler: @escaping () -> Void) {
        addGesture(UITapGestureRecognizer(target: nil, action: nil), to: view) { _ in handler() }
    }

    @objc private func handleGesture(_ recognizer: UIGestureRecognizer) {
        gestureHandlers[ObjectIdentifier(recognizer)]?(recognizer)
    }

    /// Removes a view and releases the gesture handlers attached inside it.
    private func discard(_ view: UIView?) {
        guard let view = view else { return }
        func clearHandlers(_ target: UIView) {
            target.gestureRecognizers?.forEach { self.gestureHandlers[ObjectIdentifier($0)] = nil }
            target.subviews.forEach { clearHandlers($0) }
        }
        clearHandlers(view)
        view.removeFromSuperview()
    }

    // =========================================================================
    // MARK: - BUTTONS & LINKS
    // =========================================================================

    // KF-01
    private func addCustomButton() {
        let (button, _) = makeBox("Submit application", textColor: .white, background: .systemBlue)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true

        // FAIL: UIView styled as a button with a tap gesture. Not a UIControl,
        // not an accessibility element, no .button trait.
        onTap(button) { [weak self] in self?.report("Application submitted") }

        addSection(
            title: "Custom primary button",
            failure: "Button is a UIView with a tap gesture. It never receives keyboard focus, so Space cannot submit.",
            content: button
        )
    }

    // KF-02
    private func addIconToggleButton() {
        let heart = makeIcon("heart", size: 36, tint: .systemPink)
        var isFavourite = false

        // FAIL: Icon-only toggle built from UIImageView + tap gesture.
        onTap(heart) { [weak self] in
            isFavourite.toggle()
            heart.image = UIImage(systemName: isFavourite ? "heart.fill" : "heart")
            self?.report(isFavourite ? "Added to favourites" : "Removed from favourites")
        }

        addSection(
            title: "Icon-only favourite toggle",
            failure: "Heart icon toggles by touch only. Keyboard focus skips it.",
            content: leading(heart)
        )
    }

    // KF-03
    private func addFloatingActionButton() {
        let fab = UIView()
        fab.backgroundColor = .systemGreen
        fab.layer.cornerRadius = 28
        fab.layer.shadowOpacity = 0.25
        fab.layer.shadowRadius = 4
        fab.layer.shadowOffset = CGSize(width: 0, height: 2)
        fab.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fab.widthAnchor.constraint(equalToConstant: 56),
            fab.heightAnchor.constraint(equalToConstant: 56)
        ])
        center(makeIcon("plus", size: 24, tint: .white), in: fab)

        let countLabel = makeLabel("Notes created: 0", style: .subheadline)
        var count = 0

        // FAIL: Floating action button is a round UIView with a tap gesture.
        onTap(fab) { [weak self] in
            count += 1
            countLabel.text = "Notes created: \(count)"
            self?.report("New note created (\(count))")
        }

        addSection(
            title: "Floating action button (FAB)",
            failure: "Round “+” button is a UIView with a tap gesture. It cannot receive keyboard focus.",
            content: hStack([fab, countLabel, spacer()], spacing: 16)
        )
    }

    // KF-04
    private func addTextLink() {
        let link = UILabel()
        link.attributedText = NSAttributedString(
            string: "View terms of service",
            attributes: [
                .foregroundColor: UIColor.systemBlue,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: UIFont.preferredFont(forTextStyle: .body)
            ]
        )
        link.adjustsFontForContentSizeCategory = true

        // FAIL: Looks like a link but is static text with a tap gesture.
        link.accessibilityTraits = .staticText
        onTap(link) { [weak self] in self?.report("Terms of service opened") }

        addSection(
            title: "Text link",
            failure: "Link is a UILabel with a tap gesture and no .link trait. It cannot be reached with the keyboard.",
            content: leading(link)
        )
    }

    // KF-05
    private func addReadMoreLink() {
        let paragraph = makeLabel(
            "Our rooftop café serves seasonal breakfast and lunch menus made with ingredients from local farms. We also host weekend workshops on baking, coffee brewing and plant care, and the space can be booked for private events.",
            style: .subheadline
        )
        paragraph.numberOfLines = 2

        let readMore = makeLabel("Read more", style: .subheadline, color: .systemBlue)
        var expanded = false

        // FAIL: Expand/collapse "Read more" is a label with a tap gesture.
        onTap(readMore) { [weak self] in
            expanded.toggle()
            paragraph.numberOfLines = expanded ? 0 : 2
            readMore.text = expanded ? "Read less" : "Read more"
            self?.report(expanded ? "Description expanded" : "Description collapsed")
        }

        addSection(
            title: "“Read more” expand link",
            failure: "Inline Read more / Read less control is a label with a tap gesture. Keyboard users cannot expand the text.",
            content: vStack([paragraph, leading(readMore)], spacing: 4)
        )
    }

    // KF-06
    private func addHiddenSystemButton() {
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save draft", for: .normal)
        saveButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        saveButton.titleLabel?.adjustsFontForContentSizeCategory = true
        saveButton.addAction(UIAction { [weak self] _ in self?.report("Draft saved") }, for: .touchUpInside)

        let wrapper = leading(saveButton)

        // FAIL: A real UIButton, but its container hides all children from the
        // accessibility tree, which Full Keyboard Access relies on.
        wrapper.accessibilityElementsHidden = true

        addSection(
            title: "System button hidden from accessibility",
            failure: "Container uses accessibilityElementsHidden = true. The real UIButton is skipped by keyboard focus.",
            content: wrapper
        )
    }

    // =========================================================================
    // MARK: - SELECTION CONTROLS
    // =========================================================================

    // KF-07
    private func addCustomCheckbox() {
        let box = makeIcon("square", size: 28)
        let row = hStack([box, makeLabel("I agree to the terms and conditions")], spacing: 12)
        var isChecked = false

        // FAIL: Checkbox built from an image + label with a tap gesture.
        onTap(row) { [weak self] in
            isChecked.toggle()
            box.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
            box.tintColor = isChecked ? .systemBlue : .label
            self?.report(isChecked ? "Terms accepted" : "Terms not accepted")
        }

        addSection(
            title: "Custom checkbox",
            failure: "Checkbox toggles by touch only. No focus, no Space to check or uncheck.",
            content: row
        )
    }

    // KF-08
    private func addCustomRadioGroup() {
        let options = ["Standard delivery (3–5 days)", "Express delivery (1 day)", "Store pickup"]
        var icons: [UIImageView] = []
        var rows: [UIView] = []

        for title in options {
            let icon = makeIcon("circle", size: 24, tint: .systemBlue)
            icons.append(icon)
            rows.append(hStack([icon, makeLabel(title)], spacing: 12))
        }
        icons.first?.image = UIImage(systemName: "largecircle.fill.circle")

        let allIcons = icons
        for (index, row) in rows.enumerated() {
            // FAIL: Each radio option is a stack view with a tap gesture.
            onTap(row) { [weak self] in
                for (i, icon) in allIcons.enumerated() {
                    icon.image = UIImage(systemName: i == index ? "largecircle.fill.circle" : "circle")
                }
                self?.report("Selected: \(options[index])")
            }
        }

        addSection(
            title: "Custom radio group",
            failure: "Radio options change by touch only. Keyboard focus cannot reach any option.",
            content: vStack(rows, spacing: 12)
        )
    }

    // KF-09
    private func addCustomToggleSwitch() {
        let label = makeLabel("Dark mode: Off")

        let track = UIView()
        track.backgroundColor = .systemGray4
        track.layer.cornerRadius = 16
        track.translatesAutoresizingMaskIntoConstraints = false

        let knob = UIView()
        knob.backgroundColor = .white
        knob.layer.cornerRadius = 14
        knob.layer.shadowOpacity = 0.2
        knob.layer.shadowRadius = 2
        knob.layer.shadowOffset = CGSize(width: 0, height: 1)
        knob.translatesAutoresizingMaskIntoConstraints = false
        track.addSubview(knob)

        let knobLeading = knob.leadingAnchor.constraint(equalTo: track.leadingAnchor, constant: 2)
        NSLayoutConstraint.activate([
            track.widthAnchor.constraint(equalToConstant: 52),
            track.heightAnchor.constraint(equalToConstant: 32),
            knob.widthAnchor.constraint(equalToConstant: 28),
            knob.heightAnchor.constraint(equalToConstant: 28),
            knob.centerYAnchor.constraint(equalTo: track.centerYAnchor),
            knobLeading
        ])

        var isOn = false

        // FAIL: Switch drawn with plain views + tap gesture. Not a UISwitch.
        onTap(track) { [weak self] in
            isOn.toggle()
            knobLeading.constant = isOn ? 22 : 2
            UIView.animate(withDuration: 0.2) {
                track.backgroundColor = isOn ? .systemGreen : .systemGray4
                track.layoutIfNeeded()
            }
            label.text = "Dark mode: \(isOn ? "On" : "Off")"
            self?.report("Dark mode \(isOn ? "on" : "off")")
        }

        addSection(
            title: "Custom toggle switch",
            failure: "Toggle is drawn with UIViews and a tap gesture. It cannot receive keyboard focus.",
            content: hStack([label, spacer(), track], spacing: 12)
        )
    }

    // KF-10
    private func addHiddenSystemSwitch() {
        let wifiSwitch = UISwitch()
        wifiSwitch.isOn = true
        wifiSwitch.addAction(UIAction { [weak self] action in
            let isOn = (action.sender as? UISwitch)?.isOn ?? false
            self?.report("Wi-Fi \(isOn ? "on" : "off")")
        }, for: .valueChanged)

        let row = hStack([makeLabel("Wi-Fi"), spacer(), wifiSwitch], spacing: 12)

        // FAIL: Real UISwitch, but the row hides it from the accessibility tree.
        row.accessibilityElementsHidden = true

        addSection(
            title: "System switch hidden from accessibility",
            failure: "A real UISwitch inside a row with accessibilityElementsHidden = true. Keyboard focus skips it.",
            content: row
        )
    }

    // KF-11
    private func addFilterChips() {
        let filters = ["Vegetarian", "Under ₹300", "Open now", "Rating 4+"]
        var selected = Set<String>()
        var chips: [UIView] = []

        for filter in filters {
            let (chip, label) = makeBox(filter, cornerRadius: 16, vertical: 8, horizontal: 12)
            label.font = .preferredFont(forTextStyle: .subheadline)
            chip.layer.borderWidth = 1
            chip.layer.borderColor = UIColor.separator.cgColor

            // FAIL: Multi-select chip is a UIView with a tap gesture.
            onTap(chip) { [weak self] in
                if selected.contains(filter) {
                    selected.remove(filter)
                    chip.backgroundColor = .secondarySystemBackground
                    label.textColor = .label
                } else {
                    selected.insert(filter)
                    chip.backgroundColor = .systemBlue
                    label.textColor = .white
                }
                let summary = selected.isEmpty ? "none" : selected.sorted().joined(separator: ", ")
                self?.report("Filters: \(summary)")
            }
            chips.append(chip)
        }

        addSection(
            title: "Filter chips (multi-select)",
            failure: "Filter chips toggle by touch only. Keyboard users cannot apply filters.",
            content: wrapRows(chips, perRow: 2)
        )
    }

    // KF-12
    private func addRemovableTags() {
        let tags = ["Swift", "UIKit", "Accessibility", "Testing"]
        var tagViews: [UIView] = []

        for tag in tags {
            let tagView = UIView()
            tagView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            tagView.layer.cornerRadius = 14

            let label = makeLabel(tag, style: .subheadline, color: .systemBlue)
            let removeIcon = makeIcon("xmark.circle.fill", size: 18, tint: .systemBlue)
            pin(hStack([label, removeIcon], spacing: 6), in: tagView, inset: 8)

            // FAIL: The remove (x) icon is an image with a tap gesture.
            onTap(removeIcon) { [weak self, weak tagView] in
                self?.discard(tagView)
                self?.report("Removed tag: \(tag)")
            }
            tagViews.append(tagView)
        }

        addSection(
            title: "Removable tags",
            failure: "Each tag's remove (x) icon works by touch only. Keyboard users cannot remove tags.",
            content: wrapRows(tagViews, perRow: 2)
        )
    }

    // KF-13
    private func addColourSwatches() {
        let swatches: [(name: String, color: UIColor)] = [
            ("Red", .systemRed), ("Blue", .systemBlue), ("Green", .systemGreen),
            ("Orange", .systemOrange), ("Purple", .systemPurple)
        ]
        var circles: [UIView] = []

        for swatch in swatches {
            let circle = UIView()
            circle.backgroundColor = swatch.color
            circle.layer.cornerRadius = 20
            circle.layer.borderColor = UIColor.label.cgColor
            circle.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                circle.widthAnchor.constraint(equalToConstant: 40),
                circle.heightAnchor.constraint(equalToConstant: 40)
            ])
            circles.append(circle)
        }
        circles.first?.layer.borderWidth = 3

        let selectedLabel = makeLabel("Colour: Red", style: .caption1, color: .secondaryLabel)
        let allCircles = circles

        for (index, circle) in circles.enumerated() {
            // FAIL: Colour swatch is a round UIView with a tap gesture.
            onTap(circle) { [weak self] in
                for (i, other) in allCircles.enumerated() {
                    other.layer.borderWidth = i == index ? 3 : 0
                }
                selectedLabel.text = "Colour: \(swatches[index].name)"
                self?.report("Colour \(swatches[index].name) selected")
            }
        }

        addSection(
            title: "Colour swatches",
            failure: "Colour options are selectable by touch only. Keyboard focus cannot reach any swatch.",
            content: vStack([hStack(circles + [spacer()], spacing: 12), selectedLabel], spacing: 8)
        )
    }

    // KF-14
    private func addStarRating() {
        var stars: [UIImageView] = []
        for _ in 1...5 {
            stars.append(makeIcon("star", size: 34, tint: .systemOrange))
        }
        let allStars = stars

        for (index, star) in stars.enumerated() {
            // FAIL: Each star is an image with a tap gesture; no adjustable trait.
            onTap(star) { [weak self] in
                let rating = index + 1
                for (i, other) in allStars.enumerated() {
                    other.image = UIImage(systemName: i < rating ? "star.fill" : "star")
                }
                self?.report("Rated \(rating) of 5 stars")
            }
        }

        addSection(
            title: "Star rating",
            failure: "Rating is set by tapping stars only. No keyboard focus and no arrow-key support.",
            content: hStack(stars + [spacer()], spacing: 8)
        )
    }

    // =========================================================================
    // MARK: - VALUE & RANGE CONTROLS
    // =========================================================================

    // KF-15
    private func addCustomSlider() {
        let container = UIView()
        let track = UIView()
        let fill = UIView()
        let thumb = UIView()

        track.backgroundColor = .systemGray4
        track.layer.cornerRadius = 4
        fill.backgroundColor = .systemBlue
        fill.layer.cornerRadius = 4
        thumb.backgroundColor = .white
        thumb.layer.cornerRadius = 12
        thumb.layer.shadowOpacity = 0.25
        thumb.layer.shadowRadius = 2
        thumb.layer.shadowOffset = CGSize(width: 0, height: 1)

        [track, fill, thumb].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        container.addSubview(track)
        track.addSubview(fill)
        container.addSubview(thumb)

        let fillWidth = fill.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 44),
            track.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            track.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            track.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            track.heightAnchor.constraint(equalToConstant: 8),
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fillWidth,
            thumb.widthAnchor.constraint(equalToConstant: 24),
            thumb.heightAnchor.constraint(equalToConstant: 24),
            thumb.centerYAnchor.constraint(equalTo: track.centerYAnchor),
            thumb.centerXAnchor.constraint(equalTo: fill.trailingAnchor)
        ])

        let valueLabel = makeLabel("Volume: 0%", style: .caption1, color: .secondaryLabel)

        let apply: (CGFloat, Bool) -> Void = { [weak self] locationX, announce in
            let width = track.bounds.width
            guard width > 0 else { return }
            let x = min(max(locationX, 0), width)
            fillWidth.constant = x
            let percent = Int((x / width * 100).rounded())
            valueLabel.text = "Volume: \(percent)%"
            if announce { self?.report("Volume set to \(percent)%") }
        }

        // FAIL: Slider built from UIViews with pan/tap gestures. Not a UISlider,
        // no .adjustable trait, no increment/decrement.
        addGesture(UIPanGestureRecognizer(target: nil, action: nil), to: container) { gesture in
            apply(gesture.location(in: track).x, gesture.state == .ended)
        }
        addGesture(UITapGestureRecognizer(target: nil, action: nil), to: container) { gesture in
            apply(gesture.location(in: track).x, true)
        }

        addSection(
            title: "Custom slider",
            failure: "Value changes only by dragging or tapping the track. The slider cannot receive keyboard focus.",
            content: vStack([container, valueLabel], spacing: 4)
        )
    }

    // KF-16
    private func addCustomStepper() {
        let (minus, _) = makeBox("−", vertical: 8, horizontal: 18)
        let (plus, _) = makeBox("+", vertical: 8, horizontal: 18)
        let valueLabel = makeLabel("Quantity: 1")
        var quantity = 1

        let change: (Int) -> Void = { [weak self] delta in
            let newValue = min(max(quantity + delta, 1), 10)
            guard newValue != quantity else {
                self?.report(delta < 0 ? "Minimum quantity is 1" : "Maximum quantity is 10")
                return
            }
            quantity = newValue
            valueLabel.text = "Quantity: \(quantity)"
            self?.report("Quantity \(quantity)")
        }

        // FAIL: − and + are UIViews with tap gestures. Not a UIStepper.
        onTap(minus) { change(-1) }
        onTap(plus) { change(1) }

        addSection(
            title: "Custom quantity stepper",
            failure: "Minus and plus buttons work by touch only. Keyboard users cannot change the quantity.",
            content: hStack([minus, valueLabel, plus, spacer()], spacing: 16)
        )
    }

    // KF-17
    private func addCustomSegmentedControl() {
        let segments = ["Day", "Week", "Month"]
        var items: [(UIView, UILabel)] = []
        for segment in segments {
            let (box, label) = makeBox(segment, background: .clear, cornerRadius: 8, vertical: 8, horizontal: 8)
            items.append((box, label))
        }

        let control = hStack(items.map { $0.0 }, spacing: 4, alignment: .fill, distribution: .fillEqually)
        control.isLayoutMarginsRelativeArrangement = true
        control.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        control.backgroundColor = .systemGray5
        control.layer.cornerRadius = 10

        let result = makeLabel("", style: .subheadline, color: .secondaryLabel)
        let allItems = items

        let select: (Int, Bool) -> Void = { [weak self] index, announce in
            for (i, item) in allItems.enumerated() {
                item.0.backgroundColor = i == index ? .systemBlue : .clear
                item.1.textColor = i == index ? .white : .label
            }
            result.text = "Showing: \(segments[index]) view"
            if announce { self?.report("\(segments[index]) selected") }
        }
        select(0, false)

        for (index, item) in allItems.enumerated() {
            // FAIL: Each segment is a UIView with a tap gesture. Not a UISegmentedControl.
            onTap(item.0) { select(index, true) }
        }

        addSection(
            title: "Custom segmented control",
            failure: "Segments switch by touch only. Keyboard focus cannot reach any segment.",
            content: vStack([control, result], spacing: 8)
        )
    }

    // KF-18
    private func addCustomTabs() {
        let tabs = ["Overview", "Reviews", "Specs"]
        let panels = [
            "Lightweight running shoes with a breathable mesh upper.",
            "Rated 4.6 out of 5 by 1,203 buyers.",
            "Weight 240 g · Drop 8 mm · Sizes 6–12."
        ]
        var tabItems: [(UIView, UILabel, UIView)] = []

        for tab in tabs {
            let label = makeLabel(tab, style: .subheadline)
            label.textAlignment = .center
            let underline = UIView()
            underline.heightAnchor.constraint(equalToConstant: 3).isActive = true
            tabItems.append((vStack([label, underline], spacing: 6), label, underline))
        }

        let tabRow = hStack(tabItems.map { $0.0 }, spacing: 0, alignment: .fill, distribution: .fillEqually)
        let panel = makeLabel("", style: .subheadline, color: .secondaryLabel)
        let allTabs = tabItems

        let select: (Int, Bool) -> Void = { [weak self] index, announce in
            for (i, item) in allTabs.enumerated() {
                item.1.textColor = i == index ? .systemBlue : .label
                item.2.backgroundColor = i == index ? .systemBlue : .systemGray5
            }
            panel.text = panels[index]
            if announce { self?.report("\(tabs[index]) tab selected") }
        }
        select(0, false)

        for (index, item) in allTabs.enumerated() {
            // FAIL: Tab is a stack view with a tap gesture; no .tabBar / button traits.
            onTap(item.0) { select(index, true) }
        }

        addSection(
            title: "Custom tabs",
            failure: "Tabs switch content by touch only. Keyboard users cannot change tabs.",
            content: vStack([tabRow, panel], spacing: 10)
        )
    }

    // =========================================================================
    // MARK: - PICKERS & DROPDOWNS
    // =========================================================================

    // KF-19
    private func addCustomDropdown() {
        let selectedLabel = makeLabel("Select city")
        let chevron = makeIcon("chevron.down", size: 16, tint: .secondaryLabel)

        let header = hStack([selectedLabel, chevron], spacing: 8)
        header.isLayoutMarginsRelativeArrangement = true
        header.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        header.backgroundColor = .secondarySystemBackground
        header.layer.cornerRadius = 10

        let options = vStack([], spacing: 0)
        options.isHidden = true
        options.backgroundColor = .systemGray6
        options.layer.cornerRadius = 10
        options.clipsToBounds = true

        for city in ["Mumbai", "Pune", "Delhi", "Bengaluru"] {
            let (row, rowLabel) = makeBox(city, background: .clear, vertical: 12, horizontal: 12)
            rowLabel.textAlignment = .natural

            // FAIL: Each option is a UIView with a tap gesture.
            onTap(row) { [weak self] in
                selectedLabel.text = city
                options.isHidden = true
                chevron.image = UIImage(systemName: "chevron.down")
                self?.report("City selected: \(city)")
            }
            options.addArrangedSubview(row)
        }

        // FAIL: The dropdown trigger is a stack view with a tap gesture.
        onTap(header) { [weak self] in
            options.isHidden.toggle()
            chevron.image = UIImage(systemName: options.isHidden ? "chevron.down" : "chevron.up")
            self?.report(options.isHidden ? "City list collapsed" : "City list expanded")
        }

        addSection(
            title: "Custom dropdown",
            failure: "Neither the dropdown trigger nor its options can receive keyboard focus.",
            content: vStack([header, options], spacing: 4)
        )
    }

    // KF-20
    private func addDateStripPicker() {
        let calendar = Calendar.current
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEE"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let fullFormatter = DateFormatter()
        fullFormatter.dateStyle = .medium

        var dates: [Date] = []
        var cells: [(UIView, UILabel, UILabel)] = []

        for offset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: offset, to: Date()) ?? Date()
            dates.append(date)

            let weekday = makeLabel(weekdayFormatter.string(from: date), style: .caption2, color: .secondaryLabel)
            let day = makeLabel(dayFormatter.string(from: date), style: .headline)
            weekday.textAlignment = .center
            day.textAlignment = .center

            let cell = UIView()
            cell.layer.cornerRadius = 10
            pin(vStack([weekday, day], spacing: 2), in: cell, inset: 6)
            cells.append((cell, weekday, day))
        }

        let strip = hStack(cells.map { $0.0 }, spacing: 6, alignment: .fill, distribution: .fillEqually)
        let selectedLabel = makeLabel("", style: .caption1, color: .secondaryLabel)
        let allCells = cells
        let allDates = dates

        let select: (Int, Bool) -> Void = { [weak self] index, announce in
            for (i, cell) in allCells.enumerated() {
                let isSelected = i == index
                cell.0.backgroundColor = isSelected ? .systemBlue : .secondarySystemBackground
                cell.1.textColor = isSelected ? .white : .secondaryLabel
                cell.2.textColor = isSelected ? .white : .label
            }
            let text = fullFormatter.string(from: allDates[index])
            selectedLabel.text = "Delivery date: \(text)"
            if announce { self?.report("Delivery date \(text) selected") }
        }
        select(0, false)

        for (index, cell) in allCells.enumerated() {
            // FAIL: Each date cell is a UIView with a tap gesture. Not a UIDatePicker.
            onTap(cell.0) { select(index, true) }
        }

        addSection(
            title: "Date strip picker",
            failure: "Dates are selectable by touch only. Keyboard focus cannot reach any date.",
            content: vStack([strip, selectedLabel], spacing: 8)
        )
    }

    // =========================================================================
    // MARK: - TEXT INPUT & KEYBOARD EXTRAS
    // =========================================================================

    // KF-21
    private func addOTPInput() {
        // Real input is a near-invisible text field hidden from accessibility.
        let hiddenField = UITextField()
        hiddenField.keyboardType = .numberPad
        hiddenField.textContentType = .oneTimeCode
        hiddenField.alpha = 0.02
        hiddenField.tintColor = .clear
        hiddenField.isAccessibilityElement = false
        hiddenField.accessibilityElementsHidden = true
        hiddenField.translatesAutoresizingMaskIntoConstraints = false

        var digitLabels: [UILabel] = []
        var boxes: [UIView] = []

        for _ in 0..<4 {
            let box = UIView()
            box.backgroundColor = .secondarySystemBackground
            box.layer.cornerRadius = 10
            box.layer.borderWidth = 1
            box.layer.borderColor = UIColor.separator.cgColor
            box.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                box.widthAnchor.constraint(equalToConstant: 52),
                box.heightAnchor.constraint(equalToConstant: 60)
            ])
            let digit = makeLabel(" ", style: .title2)
            center(digit, in: box)
            digitLabels.append(digit)
            boxes.append(box)
        }

        let row = hStack(boxes + [spacer()], spacing: 10)
        let container = UIView()
        pin(row, in: container)
        container.addSubview(hiddenField)
        NSLayoutConstraint.activate([
            hiddenField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hiddenField.topAnchor.constraint(equalTo: container.topAnchor),
            hiddenField.widthAnchor.constraint(equalToConstant: 1),
            hiddenField.heightAnchor.constraint(equalToConstant: 1)
        ])

        let resultLabel = makeLabel("Code: —", style: .caption1, color: .secondaryLabel)
        let allDigits = digitLabels

        hiddenField.addAction(UIAction { [weak self] action in
            guard let field = action.sender as? UITextField else { return }
            let digits = String((field.text ?? "").filter { $0.isNumber }.prefix(4))
            field.text = digits
            let characters = Array(digits)
            for (i, label) in allDigits.enumerated() {
                label.text = i < characters.count ? String(characters[i]) : " "
            }
            if digits.count == 4 {
                field.resignFirstResponder()
                resultLabel.text = "Code: \(digits)"
                self?.report("Verification code \(digits) entered")
            }
        }, for: .editingChanged)

        // FAIL: The only way to start typing is tapping the boxes. The boxes are
        // UIViews with a tap gesture and the real field is hidden.
        onTap(row) { hiddenField.becomeFirstResponder() }

        addSection(
            title: "OTP code boxes",
            failure: "Code boxes are views with a tap gesture over a hidden text field. Keyboard users cannot focus the input to type the code.",
            content: vStack([container, resultLabel], spacing: 8)
        )
    }

    // KF-22
    private func addFakeSearchBar() {
        let icon = makeIcon("magnifyingglass", size: 18, tint: .secondaryLabel)
        let placeholder = makeLabel("Search products", color: .placeholderText)

        let bar = hStack([icon, placeholder], spacing: 8)
        bar.isLayoutMarginsRelativeArrangement = true
        bar.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        bar.backgroundColor = .secondarySystemBackground
        bar.layer.cornerRadius = 10

        let resultLabel = makeLabel("No search yet", style: .caption1, color: .secondaryLabel)

        // FAIL: Looks like a search field, but it is a stack view with a tap gesture.
        onTap(bar) { [weak self] in
            let alert = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
            alert.addTextField { $0.placeholder = "Product name" }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Search", style: .default) { [weak self, weak alert] _ in
                let query = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) ?? ""
                placeholder.text = query.isEmpty ? "Search products" : query
                placeholder.textColor = query.isEmpty ? .placeholderText : .label
                resultLabel.text = query.isEmpty ? "No search yet" : "Results for “\(query)”: 12 items"
                self?.report(query.isEmpty ? "Empty search" : "Searched for \(query)")
            })
            self?.present(alert, animated: true)
        }

        addSection(
            title: "Fake search bar",
            failure: "Search bar is a styled view with a tap gesture, not a UISearchBar or UITextField. It cannot receive keyboard focus.",
            content: vStack([bar, resultLabel], spacing: 8)
        )
    }

    // KF-23, KF-24, KF-25
    private func addLoginFormExtras() {
        let usernameField = makeTextField(placeholder: "Username")
        let passwordField = makeTextField(placeholder: "Password")
        passwordField.isSecureTextEntry = true

        // KF-23 — custom clear (x) icon
        let clearIcon = makeIcon("xmark.circle.fill", size: 20, tint: .tertiaryLabel)
        usernameField.rightView = makeRightViewContainer(for: clearIcon)
        usernameField.rightViewMode = .whileEditing

        // FAIL: Clear icon is an image with a tap gesture.
        onTap(clearIcon) { [weak self] in
            usernameField.text = ""
            self?.report("Username cleared")
        }

        addSection(
            title: "Clear text (x) icon",
            failure: "The custom clear icon inside the Username field works by touch only. Keyboard focus cannot reach it.",
            content: usernameField
        )

        // KF-24 — show/hide password icon
        let eyeIcon = makeIcon("eye", size: 22, tint: .secondaryLabel)
        passwordField.rightView = makeRightViewContainer(for: eyeIcon)
        passwordField.rightViewMode = .always

        // FAIL: Password visibility toggle is an image with a tap gesture.
        onTap(eyeIcon) { [weak self] in
            passwordField.isSecureTextEntry.toggle()
            let isHidden = passwordField.isSecureTextEntry
            eyeIcon.image = UIImage(systemName: isHidden ? "eye" : "eye.slash")
            self?.report(isHidden ? "Password hidden" : "Password shown")
        }

        addSection(
            title: "Show / hide password icon",
            failure: "The eye icon toggles password visibility by touch only. Keyboard users cannot reveal the password.",
            content: passwordField
        )

        // KF-25 — keyboard accessory toolbar (Prev / Next / Done)
        let goPrevious: () -> Void = { [weak self] in
            usernameField.becomeFirstResponder()
            self?.report("Moved to Username")
        }
        let goNext: () -> Void = { [weak self] in
            passwordField.becomeFirstResponder()
            self?.report("Moved to Password")
        }
        let finish: () -> Void = { [weak self] in
            self?.view.endEditing(true)
            self?.report("Keyboard dismissed")
        }
        usernameField.inputAccessoryView = makeAccessoryBar(onPrevious: goPrevious, onNext: goNext, onDone: finish)
        passwordField.inputAccessoryView = makeAccessoryBar(onPrevious: goPrevious, onNext: goNext, onDone: finish)

        addSection(
            title: "Keyboard accessory toolbar",
            failure: "Focus Username or Password to show the Prev / Next / Done toolbar. Its items are labels with tap gestures in a bar hidden from accessibility, so none receive keyboard focus.",
            content: makeLabel("Uses the two fields above.", style: .caption1, color: .secondaryLabel)
        )
    }

    private func makeAccessoryBar(
        onPrevious: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onDone: @escaping () -> Void
    ) -> UIView {
        let bar = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 48))
        bar.autoresizingMask = .flexibleWidth
        bar.backgroundColor = .secondarySystemBackground

        let previous = makeLabel("Prev", color: .systemBlue)
        let next = makeLabel("Next", color: .systemBlue)
        let done = makeLabel("Done", style: .headline, color: .systemBlue)

        // FAIL: Toolbar items are labels with tap gestures, not UIBarButtonItems.
        onTap(previous, handler: onPrevious)
        onTap(next, handler: onNext)
        onTap(done, handler: onDone)

        let row = hStack([previous, next, spacer(), done], spacing: 24)
        row.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -16),
            row.topAnchor.constraint(equalTo: bar.topAnchor),
            row.bottomAnchor.constraint(equalTo: bar.bottomAnchor)
        ])

        // FAIL: The whole bar is hidden from the accessibility tree.
        bar.accessibilityElementsHidden = true
        return bar
    }

    // =========================================================================
    // MARK: - DISCLOSURE & NAVIGATION
    // =========================================================================

    // KF-26
    private func addAccordion() {
        let faqs = [
            ("What is the return policy?", "You can return items within 30 days of delivery for a full refund."),
            ("Do you ship internationally?", "Yes, we ship to over 40 countries. Delivery takes 7–14 days.")
        ]
        var items: [UIView] = []

        for (question, answer) in faqs {
            let questionLabel = makeLabel(question)
            let chevron = makeIcon("chevron.down", size: 18, tint: .secondaryLabel)
            let header = hStack([questionLabel, chevron], spacing: 8)

            let answerLabel = makeLabel(answer, style: .subheadline, color: .secondaryLabel)
            answerLabel.isHidden = true

            let item = vStack([header, answerLabel], spacing: 8)
            item.isLayoutMarginsRelativeArrangement = true
            item.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            item.backgroundColor = .secondarySystemBackground
            item.layer.cornerRadius = 10

            // FAIL: Accordion header is a stack view with a tap gesture.
            onTap(header) { [weak self] in
                answerLabel.isHidden.toggle()
                chevron.image = UIImage(systemName: answerLabel.isHidden ? "chevron.down" : "chevron.up")
                self?.report(answerLabel.isHidden ? "Collapsed: \(question)" : "Expanded: \(question)")
            }
            items.append(item)
        }

        addSection(
            title: "Accordion (FAQ)",
            failure: "Accordion headers expand and collapse by touch only. Keyboard users cannot open the answers.",
            content: vStack(items, spacing: 8)
        )
    }

    // KF-27
    private func addCarousel() {
        let slides: [(text: String, color: UIColor)] = [
            ("Summer sale – up to 50% off", .systemOrange),
            ("New arrivals this week", .systemTeal),
            ("Free delivery over ₹999", .systemGreen),
            ("Refer a friend, get ₹200", .systemPurple)
        ]

        let (slideBox, slideLabel) = makeBox("", textColor: .white, background: slides[0].color, cornerRadius: 12, vertical: 32, horizontal: 12)
        slideLabel.font = .preferredFont(forTextStyle: .title3)

        let previous = makeIcon("chevron.left.circle.fill", size: 36)
        let next = makeIcon("chevron.right.circle.fill", size: 36)

        var dots: [UIView] = []
        var current = 0

        let show: (Int, Bool) -> Void = { [weak self] index, announce in
            current = (index + slides.count) % slides.count
            slideLabel.text = "Slide \(current + 1) of \(slides.count): \(slides[current].text)"
            slideBox.backgroundColor = slides[current].color
            for (i, dot) in dots.enumerated() {
                dot.backgroundColor = i == current ? .label : .systemGray4
            }
            if announce { self?.report("Slide \(current + 1): \(slides[current].text)") }
        }

        let dotRow = hStack([], spacing: 10)
        for index in 0..<slides.count {
            let dot = UIView()
            dot.layer.cornerRadius = 6
            dot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 12),
                dot.heightAnchor.constraint(equalToConstant: 12)
            ])
            // FAIL: Page dots are tiny UIViews with tap gestures.
            onTap(dot) { show(index, true) }
            dots.append(dot)
            dotRow.addArrangedSubview(dot)
        }

        // FAIL: Previous / next arrows are images with tap gestures.
        onTap(previous) { show(current - 1, true) }
        onTap(next) { show(current + 1, true) }
        show(0, false)

        addSection(
            title: "Carousel (arrows + page dots)",
            failure: "Previous / next arrows and page dots work by touch only. Keyboard users cannot change slides.",
            content: vStack([hStack([previous, slideBox, next], spacing: 8), hStack([spacer(), dotRow, spacer()])], spacing: 10)
        )
    }

    // KF-28
    private func addPagination() {
        let titles = ["‹", "1", "2", "3", "›"]
        var items: [(UIView, UILabel)] = []
        for title in titles {
            let (box, label) = makeBox(title, vertical: 8, horizontal: 14)
            items.append((box, label))
        }

        let info = makeLabel("", style: .caption1, color: .secondaryLabel)
        let allItems = items
        var page = 1

        let show: (Int, Bool) -> Void = { [weak self] newPage, announce in
            page = min(max(newPage, 1), 3)
            for i in 1...3 {
                allItems[i].0.backgroundColor = i == page ? .systemBlue : .secondarySystemBackground
                allItems[i].1.textColor = i == page ? .white : .label
            }
            let start = (page - 1) * 10 + 1
            info.text = "Page \(page) of 3 · Results \(start)–\(start + 9)"
            if announce { self?.report("Page \(page) of 3") }
        }
        show(1, false)

        // FAIL: Every page control is a UIView with a tap gesture.
        onTap(allItems[0].0) { show(page - 1, true) }
        for i in 1...3 {
            onTap(allItems[i].0) { show(i, true) }
        }
        onTap(allItems[4].0) { show(page + 1, true) }

        addSection(
            title: "Pagination",
            failure: "Previous, page numbers and next work by touch only. Keyboard users cannot change pages.",
            content: vStack([hStack(allItems.map { $0.0 } + [spacer()], spacing: 6), info], spacing: 8)
        )
    }

    // KF-29
    private func addHamburgerMenu() {
        let menuIcon = makeIcon("line.horizontal.3", size: 28)
        let currentLabel = makeLabel("Current screen: Home", style: .subheadline, color: .secondaryLabel)

        let menu = vStack([], spacing: 0)
        menu.isHidden = true
        menu.backgroundColor = .secondarySystemBackground
        menu.layer.cornerRadius = 10
        menu.clipsToBounds = true

        for item in ["Home", "Orders", "Settings", "Log out"] {
            let (row, rowLabel) = makeBox(item, background: .clear, vertical: 12, horizontal: 16)
            rowLabel.textAlignment = .natural

            // FAIL: Menu item is a UIView with a tap gesture.
            onTap(row) { [weak self] in
                currentLabel.text = "Current screen: \(item)"
                menu.isHidden = true
                self?.report("Navigated to \(item)")
            }
            menu.addArrangedSubview(row)
        }

        // FAIL: Hamburger icon is an image with a tap gesture.
        onTap(menuIcon) { [weak self] in
            menu.isHidden.toggle()
            self?.report(menu.isHidden ? "Menu closed" : "Menu opened")
        }

        addSection(
            title: "Hamburger menu",
            failure: "The menu icon and its items work by touch only. Keyboard users cannot open the menu or navigate.",
            content: vStack([hStack([menuIcon, currentLabel], spacing: 12), menu], spacing: 8)
        )
    }

    // KF-30
    private func addInfoTooltip() {
        let feeLabel = makeLabel("Delivery fee: ₹40")
        let infoIcon = makeIcon("info.circle", size: 22, tint: .systemBlue)
        let (tip, _) = makeBox("Free delivery on orders above ₹999.", textColor: .white, background: .systemGray, vertical: 8, horizontal: 12)
        let tipRow = leading(tip)
        tipRow.isHidden = true

        // FAIL: Info (i) icon is an image with a tap gesture.
        onTap(infoIcon) { [weak self] in
            tipRow.isHidden.toggle()
            self?.report(tipRow.isHidden ? "Tooltip hidden" : "Tooltip: Free delivery on orders above ₹999")
        }

        addSection(
            title: "Info tooltip",
            failure: "The (i) icon shows its tooltip by touch only. Keyboard users cannot read the extra information.",
            content: vStack([hStack([feeLabel, infoIcon, spacer()], spacing: 8), tipRow], spacing: 8)
        )
    }

    // =========================================================================
    // MARK: - OVERLAYS & FEEDBACK
    // =========================================================================

    // KF-31
    private func addCustomModalDialog() {
        let (trigger, _) = makeBox("Delete account…", textColor: .white, background: .systemIndigo)

        // FAIL: Dialog trigger is a UIView with a tap gesture.
        onTap(trigger) { [weak self] in self?.presentCustomDialog() }

        addSection(
            title: "Custom modal dialog",
            failure: "The trigger, the close (x) icon and the Cancel / Delete buttons are all views with tap gestures. Keyboard users can neither open nor dismiss the dialog.",
            content: leading(trigger)
        )
    }

    private func presentCustomDialog() {
        discard(activeOverlay)

        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        pin(overlay, in: view)

        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(card)

        let titleLabel = makeLabel("Delete account?", style: .headline)
        let closeIcon = makeIcon("xmark", size: 20, tint: .secondaryLabel)
        let message = makeLabel("This removes your profile, orders and saved addresses. This cannot be undone.", style: .subheadline, color: .secondaryLabel)
        let (cancelBox, _) = makeBox("Cancel")
        let (deleteBox, _) = makeBox("Delete", textColor: .white, background: .systemRed)
        let buttons = hStack([cancelBox, deleteBox], spacing: 12, alignment: .fill, distribution: .fillEqually)

        pin(vStack([hStack([titleLabel, closeIcon], spacing: 8), message, buttons], spacing: 16), in: card, inset: 20)

        NSLayoutConstraint.activate([
            card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])

        let dismiss: (String) -> Void = { [weak self, weak overlay] text in
            self?.discard(overlay)
            self?.report(text)
        }

        // FAIL: Close icon and dialog buttons are views with tap gestures.
        onTap(closeIcon) { dismiss("Dialog closed") }
        onTap(cancelBox) { dismiss("Account deletion cancelled") }
        onTap(deleteBox) { dismiss("Account deleted (demo)") }

        activeOverlay = overlay
        report("Delete account dialog opened")
    }

    // KF-32
    private func addToastWithUndo() {
        // The trigger is a real UIButton (setup only — it works with the keyboard).
        let trigger = UIButton(type: .system)
        trigger.setTitle("Archive email (shows toast)", for: .normal)
        trigger.contentHorizontalAlignment = .leading
        trigger.addAction(UIAction { [weak self] _ in self?.showToast() }, for: .touchUpInside)

        addSection(
            title: "Toast with Undo action",
            failure: "The trigger button works, but Undo in the toast is a label with a tap gesture, the toast is hidden from accessibility, and it disappears after 4 seconds.",
            content: trigger
        )
    }

    private func showToast() {
        discard(activeToast)

        let toast = UIView()
        toast.backgroundColor = UIColor.label.withAlphaComponent(0.92)
        toast.layer.cornerRadius = 10
        toast.translatesAutoresizingMaskIntoConstraints = false

        let message = makeLabel("Email archived", style: .subheadline, color: .systemBackground)
        let undo = makeLabel("UNDO", style: .headline, color: .systemYellow)
        pin(hStack([message, spacer(), undo], spacing: 12), in: toast, inset: 14)

        view.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            toast.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            toast.bottomAnchor.constraint(equalTo: statusContainer.topAnchor, constant: -12)
        ])

        // FAIL: Toast hidden from accessibility; Undo is a label with a tap gesture.
        toast.accessibilityElementsHidden = true
        onTap(undo) { [weak self, weak toast] in
            self?.discard(toast)
            self?.report("Email restored")
        }

        activeToast = toast
        report("Email archived")

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self, weak toast] in
            guard let self = self, let toast = toast, self.activeToast === toast else { return }
            self.discard(toast)
        }
    }

    // =========================================================================
    // MARK: - GESTURE-ONLY INTERACTIONS
    // =========================================================================

    // KF-33
    private func addSwipeToDelete() {
        let fileName = "📄 Meeting-notes.txt"
        let (row, label) = makeBox(fileName)
        label.textAlignment = .natural
        let hint = makeLabel("Swipe left to delete, swipe right to restore.", style: .caption1, color: .secondaryLabel)

        // FAIL: Delete / restore exist only as swipe gestures.
        let swipeLeft = UISwipeGestureRecognizer(target: nil, action: nil)
        swipeLeft.direction = .left
        addGesture(swipeLeft, to: row) { [weak self] _ in
            label.text = "🗑 Meeting-notes.txt (deleted)"
            row.alpha = 0.5
            self?.report("Meeting-notes.txt deleted")
        }

        let swipeRight = UISwipeGestureRecognizer(target: nil, action: nil)
        swipeRight.direction = .right
        addGesture(swipeRight, to: row) { [weak self] _ in
            label.text = fileName
            row.alpha = 1
            self?.report("Meeting-notes.txt restored")
        }

        addSection(
            title: "Swipe to delete",
            failure: "Delete and restore are available only through swipe gestures. No focusable button and no custom action for Tab+Z.",
            content: vStack([row, hint], spacing: 4)
        )
    }

    // KF-34
    private func addLongPressMenu() {
        let (row, label) = makeBox("🖼 Photo_0021.jpg")
        label.textAlignment = .natural
        let hint = makeLabel("Long-press for Share / Rename / Delete.", style: .caption1, color: .secondaryLabel)

        // FAIL: Options open only on long press.
        addGesture(UILongPressGestureRecognizer(target: nil, action: nil), to: row) { [weak self] gesture in
            guard gesture.state == .began, let self = self else { return }
            let alert = UIAlertController(title: "Photo_0021.jpg", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Share", style: .default) { [weak self] _ in
                self?.report("Photo shared")
            })
            alert.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
                label.text = "🖼 Holiday-beach.jpg"
                self?.report("Photo renamed to Holiday-beach.jpg")
            })
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                row.alpha = 0.5
                self?.report("Photo deleted")
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }

        addSection(
            title: "Long-press-only menu",
            failure: "The options menu opens only on long press. The row cannot receive keyboard focus and has no custom actions.",
            content: vStack([row, hint], spacing: 4)
        )
    }

    // KF-35
    private func addDoubleTapToLike() {
        let photoBox = UIView()
        photoBox.backgroundColor = .secondarySystemBackground
        photoBox.layer.cornerRadius = 12
        photoBox.heightAnchor.constraint(equalToConstant: 160).isActive = true

        center(makeIcon("photo", size: 64, tint: .secondaryLabel), in: photoBox)
        let heart = makeIcon("heart.fill", size: 48, tint: .systemPink)
        heart.alpha = 0
        center(heart, in: photoBox)

        let likeLabel = makeLabel("Not liked · double-tap the photo to like", style: .caption1, color: .secondaryLabel)
        var liked = false

        // FAIL: Like is available only through a double-tap gesture.
        let doubleTap = UITapGestureRecognizer(target: nil, action: nil)
        doubleTap.numberOfTapsRequired = 2
        addGesture(doubleTap, to: photoBox) { [weak self] _ in
            liked.toggle()
            UIView.animate(withDuration: 0.25) { heart.alpha = liked ? 1 : 0 }
            likeLabel.text = liked ? "Liked · double-tap again to unlike" : "Not liked · double-tap the photo to like"
            self?.report(liked ? "Photo liked" : "Photo unliked")
        }

        addSection(
            title: "Double-tap to like",
            failure: "Liking works only with a double-tap gesture. There is no focusable Like button.",
            content: vStack([photoBox, likeLabel], spacing: 6)
        )
    }

    // KF-36
    private func addSwipeToDecideCard() {
        let (card, label) = makeBox(
            "Riya Sharma · UX Designer\nSwipe right to shortlist, left to reject",
            cornerRadius: 12,
            vertical: 28,
            horizontal: 16
        )

        // FAIL: Shortlist / reject exist only as left / right swipes.
        let swipeRight = UISwipeGestureRecognizer(target: nil, action: nil)
        swipeRight.direction = .right
        addGesture(swipeRight, to: card) { [weak self] _ in
            card.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.25)
            label.text = "Riya Sharma · UX Designer\n✅ Shortlisted"
            self?.report("Riya Sharma shortlisted")
        }

        let swipeLeft = UISwipeGestureRecognizer(target: nil, action: nil)
        swipeLeft.direction = .left
        addGesture(swipeLeft, to: card) { [weak self] _ in
            card.backgroundColor = UIColor.systemRed.withAlphaComponent(0.25)
            label.text = "Riya Sharma · UX Designer\n❌ Rejected"
            self?.report("Riya Sharma rejected")
        }

        addSection(
            title: "Swipe-to-decide card",
            failure: "Shortlist and reject are available only by swiping the card. No buttons or custom actions for keyboard users.",
            content: card
        )
    }

    // KF-37
    private func addPinchToZoom() {
        let mapBox = UIView()
        mapBox.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.15)
        mapBox.layer.cornerRadius = 12
        mapBox.clipsToBounds = true
        mapBox.heightAnchor.constraint(equalToConstant: 180).isActive = true

        let mapIcon = makeIcon("map", size: 72, tint: .systemTeal)
        center(mapIcon, in: mapBox)

        let zoomLabel = makeLabel("Zoom: 1.0x · pinch the map to zoom", style: .caption1, color: .secondaryLabel)
        var scale: CGFloat = 1
        var startScale: CGFloat = 1

        // FAIL: Zoom is available only through a pinch gesture. No zoom buttons.
        addGesture(UIPinchGestureRecognizer(target: nil, action: nil), to: mapBox) { [weak self] gesture in
            if gesture.state == .began { startScale = scale }
            scale = min(max(startScale * gesture.scale, 1), 3)
            mapIcon.transform = CGAffineTransform(scaleX: scale, y: scale)
            zoomLabel.text = String(format: "Zoom: %.1fx · pinch the map to zoom", scale)
            if gesture.state == .ended {
                self?.report(String(format: "Map zoomed to %.1fx", scale))
            }
        }

        addSection(
            title: "Pinch to zoom",
            failure: "Map zoom works only with a two-finger pinch. Keyboard users have no way to zoom.",
            content: vStack([mapBox, zoomLabel], spacing: 6)
        )
    }

    // =========================================================================
    // MARK: - MEDIA
    // =========================================================================

    // KF-38
    private func addCustomMediaPlayer() {
        let playIcon = makeIcon("play.circle.fill", size: 40, tint: .systemBlue)
        let muteIcon = makeIcon("speaker.wave.2.fill", size: 24)

        let trackContainer = UIView()
        trackContainer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        let track = UIView()
        track.backgroundColor = .systemGray4
        track.layer.cornerRadius = 3
        let fill = UIView()
        fill.backgroundColor = .systemBlue
        fill.layer.cornerRadius = 3

        track.translatesAutoresizingMaskIntoConstraints = false
        fill.translatesAutoresizingMaskIntoConstraints = false
        trackContainer.addSubview(track)
        track.addSubview(fill)

        let fillWidth = fill.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            trackContainer.heightAnchor.constraint(equalToConstant: 44),
            track.leadingAnchor.constraint(equalTo: trackContainer.leadingAnchor),
            track.trailingAnchor.constraint(equalTo: trackContainer.trailingAnchor),
            track.centerYAnchor.constraint(equalTo: trackContainer.centerYAnchor),
            track.heightAnchor.constraint(equalToConstant: 6),
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fillWidth
        ])

        let timeLabel = UILabel()
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        timeLabel.textColor = .secondaryLabel
        timeLabel.text = "0:00 / 0:30"

        let duration = 30
        var position = 0
        var isPlaying = false
        var isMuted = false

        let render: () -> Void = {
            fillWidth.constant = track.bounds.width * CGFloat(position) / CGFloat(duration)
            timeLabel.text = String(format: "%d:%02d / 0:30", position / 60, position % 60)
        }

        // FAIL: Play / pause is an image with a tap gesture.
        onTap(playIcon) { [weak self] in
            guard let self = self else { return }
            isPlaying.toggle()
            playIcon.image = UIImage(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
            self.mediaTimer?.invalidate()
            self.mediaTimer = nil

            if isPlaying {
                if position >= duration { position = 0 }
                self.mediaTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                    position += 1
                    if position >= duration {
                        position = duration
                        isPlaying = false
                        timer.invalidate()
                        self?.mediaTimer = nil
                        playIcon.image = UIImage(systemName: "play.circle.fill")
                        self?.report("Playback finished")
                    }
                    render()
                }
            }
            self.report(isPlaying ? "Playing" : "Paused")
        }

        // FAIL: Seek bar is a UIView with a tap gesture. Not a UISlider.
        addGesture(UITapGestureRecognizer(target: nil, action: nil), to: trackContainer) { [weak self] gesture in
            let width = track.bounds.width
            guard width > 0 else { return }
            let x = min(max(gesture.location(in: track).x, 0), width)
            position = Int((x / width * CGFloat(duration)).rounded())
            render()
            self?.report(String(format: "Seeked to %d:%02d", position / 60, position % 60))
        }

        // FAIL: Mute is an image with a tap gesture.
        onTap(muteIcon) { [weak self] in
            isMuted.toggle()
            muteIcon.image = UIImage(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
            self?.report(isMuted ? "Muted" : "Unmuted")
        }

        let player = hStack([playIcon, trackContainer, timeLabel, muteIcon], spacing: 10)
        player.isLayoutMarginsRelativeArrangement = true
        player.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        player.backgroundColor = .secondarySystemBackground
        player.layer.cornerRadius = 12

        addSection(
            title: "Custom media player",
            failure: "Play / pause, the seek bar and mute all work by touch only. Keyboard users cannot control playback.",
            content: player
        )
    }

    // =========================================================================
    // MARK: - LISTS & CARDS
    // =========================================================================

    // KF-39
    private func addProductCard() {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12

        let productImage = makeIcon("bag.fill", size: 44, tint: .systemOrange)
        let name = makeLabel("Wireless earbuds", style: .headline)
        let price = makeLabel("₹2,499 · Tap to view details", style: .subheadline, color: .secondaryLabel)
        let info = hStack([productImage, vStack([name, price], spacing: 2)], spacing: 12)

        let (addButton, addLabel) = makeBox("Add to cart", textColor: .white, background: .systemOrange, vertical: 10, horizontal: 16)
        pin(vStack([info, leading(addButton)], spacing: 12), in: card, inset: 16)

        var quantity = 0

        // FAIL: Product details link is a stack view with a tap gesture.
        onTap(info) { [weak self] in self?.report("Opened details: Wireless earbuds") }

        // FAIL: Add to cart is a UIView with a tap gesture.
        onTap(addButton) { [weak self] in
            quantity += 1
            addLabel.text = "In cart (\(quantity))"
            self?.report("Wireless earbuds added to cart (\(quantity))")
        }

        addSection(
            title: "Product card",
            failure: "Both the card's details link and the Add to cart button work by touch only. Neither receives keyboard focus.",
            content: card
        )
    }

    // KF-40
    private func addGroupedOrderRow() {
        let orderLabel = makeLabel("Order #1234 · Shipped")

        let trackButton = UIButton(type: .system)
        trackButton.setTitle("Track", for: .normal)
        trackButton.addAction(UIAction { [weak self] _ in
            self?.report("Order 1234 is out for delivery")
        }, for: .touchUpInside)

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.addAction(UIAction { [weak self] _ in
            orderLabel.text = "Order #1234 · Cancelled"
            self?.report("Order 1234 cancelled")
        }, for: .touchUpInside)

        let row = hStack([orderLabel, trackButton, cancelButton], spacing: 12)
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        row.backgroundColor = .secondarySystemBackground
        row.layer.cornerRadius = 12

        // FAIL: Row is a single static accessibility element, which hides its
        // child buttons. No accessibilityCustomActions are provided.
        row.isAccessibilityElement = true
        row.accessibilityLabel = "Order 1234"
        row.accessibilityTraits = .staticText

        addSection(
            title: "List row with inner buttons",
            failure: "The row is grouped as one static element, so the real Track and Cancel buttons inside it cannot receive keyboard focus.",
            content: row
        )
    }
}
