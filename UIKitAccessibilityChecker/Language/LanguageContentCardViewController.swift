import UIKit

/// Shared scaffold for the Language Content screens (BB40109 "Language of content does not
/// match app language"): one settings card — heading, description, switch, text field, save
/// button and a status line that is announced on save.
///
/// Each element is built from a `Text`: what it says, and the `accessibilityLanguage` it
/// declares (nil = nothing declared, so VoiceOver uses the app's language).
class LanguageContentCardViewController: UIViewController {

    struct Text {
        let string: String
        let language: String?
    }

    var screenTitle: String { "" }
    var heading: Text { Text(string: "", language: nil) }
    var body: Text { Text(string: "", language: nil) }
    var switchName: Text { Text(string: "", language: nil) }
    var fieldName: Text { Text(string: "", language: nil) }
    var saveTitle: Text { Text(string: "", language: nil) }
    var savedMessage: Text { Text(string: "", language: nil) }

    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = .systemBackground
        setupLayout()
        print("[\(type(of: self))] App development language:",
              Bundle.main.developmentLocalization ?? "nil",
              "| Preferred:", Bundle.main.preferredLocalizations.first ?? "nil")
    }

    private func label(_ text: Text, style: UIFont.TextStyle = .body, color: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.text = text.string
        label.accessibilityLanguage = text.language
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = color
        label.numberOfLines = 0
        return label
    }

    private func setupLayout() {
        let headingLabel = label(heading, style: .title2)
        headingLabel.accessibilityTraits = .header

        let bodyLabel = label(body)

        let switchLabel = label(switchName)
        switchLabel.isAccessibilityElement = false   // the switch carries the name
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.accessibilityLabel = switchName.string
        toggle.accessibilityLanguage = switchName.language
        let switchRow = UIStackView(arrangedSubviews: [switchLabel, toggle])
        switchRow.axis = .horizontal
        switchRow.alignment = .center
        switchRow.spacing = 12

        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = fieldName.string
        field.accessibilityLabel = fieldName.string
        field.accessibilityLanguage = fieldName.language
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true

        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 0
        statusLabel.accessibilityLanguage = savedMessage.language

        var config = UIButton.Configuration.filled()
        config.title = saveTitle.string
        let message = savedMessage
        let saveButton = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.statusLabel.text = message.string
            // An announcement carries its language only as an attributed string.
            let announcement = NSMutableAttributedString(string: message.string)
            if let language = message.language {
                announcement.addAttribute(.accessibilitySpeechLanguage, value: language,
                                          range: NSRange(location: 0, length: announcement.length))
            }
            UIAccessibility.post(notification: .announcement, argument: announcement)
        })
        saveButton.accessibilityLanguage = saveTitle.language

        let card = UIStackView(arrangedSubviews: [headingLabel, bodyLabel, switchRow, field, saveButton, statusLabel])
        card.axis = .vertical
        card.spacing = 16
        card.isLayoutMarginsRelativeArrangement = true
        card.directionalLayoutMargins = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(card)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            card.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
