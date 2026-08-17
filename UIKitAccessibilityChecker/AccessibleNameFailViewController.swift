import UIKit

/// UIKit equivalent of AccessibleNameFail. Worst case: no accessibilityLabel
/// anywhere, AND no visible text/title/placeholder for VoiceOver to fall
/// back on either. Row title UILabels have been removed entirely. VoiceOver
/// will announce bare control types and raw SF Symbol names — "Button,
/// trash", "Switch, off", "Slider, 50%", "Text Field, blank" — with no way
/// to know what any of it does. Deliberately broken; reference only.
final class AccessibleNameFailViewController: UIViewController {

    // MARK: - Controls

    private let deleteIconButton = UIButton(type: .system).srcLine()
    private let notificationsSwitch = UISwitch().srcLine()
    private let volumeSlider = UISlider().srcLine()
    private let quantityStepper = UIStepper().srcLine()
    private let colorSegmentedControl = UISegmentedControl(items: ["", "", ""]).srcLine()
    private let moreActionsButton = UIButton(type: .system).srcLine()
    private let usernameField = UITextField().srcLine()
    private let passwordField = UITextField().srcLine()
    private let notesTextView = UITextView().srcLine()
    private let birthDatePicker = UIDatePicker().srcLine()
    private let favoriteColorWell = NamedColorWell().srcLine()
    private let openWebsiteButton = UIButton(type: .system).srcLine()
    private let shareButton = UIButton(type: .system).srcLine()
    private let openSettingsButton = UIButton(type: .system).srcLine()
    private let favoriteStarButton = UIButton(type: .system).srcLine()
    private let ratingControl = PlainRatingControl(maximumRating: 5).srcLine()
    private let agreeSwitch = UISwitch().srcLine()
    private let deleteAccountButton = UIButton(type: .system).srcLine()

    // MARK: - Controls staging the remaining accessible-name defects
    //
    // Every button above is an SF Symbol image button, and UIKit derives an implicit
    // accessibilityLabel from the symbol name ("trash", "favorite") — so none of them is
    // ever actually nameless, and the rules for a missing or wrongly-provided button name
    // could not fire on this screen. These five controls stage those remaining defects so
    // the demo exercises the full accessible-name ruleset rather than only part of it.

    /// No label, no title, no hint, no image → button has no accessible name at all.
    private let namelessButton = UIButton(type: .system).srcLine()
    /// Image button whose image carries no accessibility description (drawn, not an SF
    /// Symbol), so nothing supplies a name.
    private let unlabelledImageButton = UIButton(type: .system).srcLine()
    /// Description supplied via accessibilityHint instead of accessibilityLabel.
    private let hintOnlyButton = UIButton(type: .system).srcLine()
    /// Visible title and accessible name say different things.
    private let mismatchedNameButton = UIButton(type: .system).srcLine()
    /// Non-button control described by a hint rather than a label.
    private let hintOnlySwitch = UISwitch().srcLine()
    /// Non-button control whose name is a generic word that conveys nothing.
    /// A UIStepper, not a UISlider: ElementNameQualityWorkflow's element collector
    /// explicitly skips UISwitch and UISlider, so a slider here would never be examined.
    private let genericNameStepper = UIStepper().srcLine()

    // MARK: - Controls staging the button ROLE defects
    //
    // These two are about the button *role* rather than its name, and nothing on the
    // screens previously triggered either rule.

    /// A button that cannot be tapped. If interaction is genuinely not wanted the element
    /// should not look or behave like a button at all, so this needs a human to confirm.
    private let nonInteractiveButton = UIButton(type: .system).srcLine()
    /// A label wired to a tap gesture: it behaves as a button but announces as plain text,
    /// so a screen reader user has no reason to think double-tapping does anything.
    private let tappableLabel = UILabel().srcLine()

    private var quantity = 1
    private var isFavorite = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildLayout()
        // No title, no row labels, no accessibilityLabel calls anywhere.
    }

    // MARK: - Layout

    /// Stages the accessible-name defects the SF Symbol buttons above cannot express.
    /// Each control is deliberately broken in exactly one way; the comment on each says
    /// which rule it is there to trigger.
    private func configureRemainingDefectControls() {
        // No name of any kind — nothing for VoiceOver to announce but "Button".
        namelessButton.backgroundColor = .systemGray5
        namelessButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        // An image with no accessibility description. An SF Symbol would supply one
        // implicitly ("trash"), which is exactly why a drawn image is used here.
        let blankIcon = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24)).image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 24, height: 24))
        }
        unlabelledImageButton.setImage(blankIcon, for: .normal)

        // Purpose described with a hint instead of a label — the wrong property.
        hintOnlyButton.backgroundColor = .systemGray5
        hintOnlyButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        hintOnlyButton.accessibilityHint = "Deletes this item permanently"

        // Visible text and accessible name disagree: a Voice Control user saying the
        // words they can see ("Save") cannot activate a control named "Submit form".
        mismatchedNameButton.setTitle("Save", for: .normal)
        mismatchedNameButton.accessibilityLabel = "Submit form"

        // Same wrong-property mistake on a non-button control.
        hintOnlySwitch.accessibilityHint = "Turns notifications on and off"

        // A name that conveys nothing about what the control does.
        genericNameStepper.accessibilityLabel = "control"

        // Looks like a button, cannot be operated.
        nonInteractiveButton.setTitle("Submit application", for: .normal)
        nonInteractiveButton.isUserInteractionEnabled = false
        nonInteractiveButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        // Text that acts as a button but never says so: no .button trait is added, so
        // VoiceOver announces "Show more details" as plain text.
        tappableLabel.text = "Show more details"
        tappableLabel.isUserInteractionEnabled = true
        tappableLabel.isAccessibilityElement = true
        tappableLabel.textColor = .systemBlue
        tappableLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleLabelTap))
        )
    }

    @objc private func handleLabelTap() {
        // Stand-in for whatever action the text performs.
    }

    private func buildLayout() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
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

        deleteIconButton.setImage(UIImage(systemName: "trash"), for: .normal)

        moreActionsButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        moreActionsButton.showsMenuAsPrimaryAction = true
        moreActionsButton.menu = UIMenu(children: [
            UIAction(image: UIImage(systemName: "square.and.arrow.up")) { _ in },
            UIAction(image: UIImage(systemName: "plus.square.on.square")) { _ in },
            UIAction(image: UIImage(systemName: "trash"), attributes: .destructive) { _ in }
        ])

        usernameField.borderStyle = .roundedRect
        // no placeholder

        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        // no placeholder

        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.separator.cgColor
        notesTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        birthDatePicker.datePickerMode = .date
        birthDatePicker.preferredDatePickerStyle = .compact

        openWebsiteButton.setImage(UIImage(systemName: "figure.roll"), for: .normal)
        openWebsiteButton.addAction(UIAction { [weak self] _ in
            guard let url = URL(string: "https://www.apple.com/accessibility/") else { return }
            self?.open(url: url)
        }, for: .touchUpInside)

        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.addAction(UIAction { [weak self] _ in
            guard let url = URL(string: "https://developer.apple.com") else { return }
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self?.present(activityVC, animated: true)
        }, for: .touchUpInside)

        openSettingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        openSettingsButton.addAction(UIAction { [weak self] _ in
            let settingsVC = UIViewController()
            settingsVC.view.backgroundColor = .systemBackground
            self?.navigationController?.pushViewController(settingsVC, animated: true)
        }, for: .touchUpInside)

        favoriteStarButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteStarButton.addAction(UIAction { [weak self] _ in
            self?.toggleFavorite()
        }, for: .touchUpInside)

        deleteAccountButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteAccountButton.tintColor = .systemRed
        deleteAccountButton.addAction(UIAction { [weak self] _ in
            self?.presentDeleteConfirmation()
        }, for: .touchUpInside)

        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.value = 1
        quantityStepper.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.quantity = Int(self.quantityStepper.value)
        }, for: .valueChanged)

        configureRemainingDefectControls()

        [
            deleteIconButton,
            notificationsSwitch,
            volumeSlider,
            quantityStepper,
            colorSegmentedControl,
            moreActionsButton,
            usernameField,
            passwordField,
            notesTextView,
            birthDatePicker,
            favoriteColorWell,
            openWebsiteButton,
            shareButton,
            openSettingsButton,
            favoriteStarButton,
            ratingControl,
            agreeSwitch,
            deleteAccountButton,
            namelessButton,
            unlabelledImageButton,
            hintOnlyButton,
            mismatchedNameButton,
            hintOnlySwitch,
            genericNameStepper,
            nonInteractiveButton,
            tappableLabel
        ].forEach { stack.addArrangedSubview($0) }
    }

    private func open(url: URL) {
        UIApplication.shared.open(url)
    }

    private func toggleFavorite() {
        isFavorite.toggle()
        let imageName = isFavorite ? "star.fill" : "star"
        favoriteStarButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    private func presentDeleteConfirmation() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "", style: .destructive))
        alert.addAction(UIAlertAction(title: "", style: .cancel))
        present(alert, animated: true)
    }
}
