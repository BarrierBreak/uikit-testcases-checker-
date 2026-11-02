import UIKit

/// Shared scaffold for the Button Disabled State screens (BB40079 "Disabled state of button not
/// defined"): a scroll view of numbered cases, each a heading and the button it is about.
class DisabledStateDemoViewController: UIViewController {

    var screenTitle: String { "" }
    var headerText: String { "" }
    /// Subclasses add their cases with `addCase(_:_:)`.
    func buildCases() {}

    private let scrollView = UIScrollView()
    let stackView = UIStackView()
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Last action: none"
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = .systemBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20)
        ])

        let header = UILabel()
        header.text = headerText
        header.font = .preferredFont(forTextStyle: .title2)
        header.adjustsFontForContentSizeCategory = true
        header.numberOfLines = 0
        header.accessibilityTraits = .header
        stackView.addArrangedSubview(header)

        buildCases()
        stackView.addArrangedSubview(statusLabel)
    }

    func addCase(_ title: String, _ control: UIView) {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.accessibilityTraits = .header
        stackView.setCustomSpacing(24, after: stackView.arrangedSubviews.last ?? stackView)
        stackView.addArrangedSubview(label)
        // Every case's control is made by one helper, so they share a source line; a tag of
        // their own keeps the scan from taking two of them for one control.
        control.tag = stackView.arrangedSubviews.count
        stackView.addArrangedSubview(control)
    }

    /// A button styled to look disabled: grey fill, grey text.
    func makeDisabledLookingButton(title: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = .systemGray5
        config.baseForegroundColor = .systemGray
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        let button = UIButton(configuration: config).srcLine()
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return button
    }

    /// A normal, enabled-looking button.
    func makeButton(title: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        let button = UIButton(configuration: config).srcLine()
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return button
    }

    func report(_ message: String) {
        statusLabel.text = "Last action: \(message)"
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

/// A custom UIView acting as a button. With `exposesState`, a disabled look also sets
/// .notEnabled (correct); without it, only the look changes (the BB40079 defect).
final class DisabledStateCustomButtonView: UIView {

    var onTap: (() -> Void)?
    private let exposesState: Bool
    private let titleLabel = UILabel()

    var isDisabledVisually = false {
        didSet { applyStyle() }
    }

    init(title: String, exposesState: Bool) {
        self.exposesState = exposesState
        super.init(frame: .zero)
        layer.cornerRadius = 8
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        isAccessibilityElement = true
        accessibilityLabel = title
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        applyStyle()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func applyStyle() {
        backgroundColor = isDisabledVisually ? .systemGray5 : .systemBlue
        titleLabel.textColor = isDisabledVisually ? .systemGray : .white
        accessibilityTraits = exposesState && isDisabledVisually ? [.button, .notEnabled] : .button
    }

    @objc private func handleTap() {
        guard !isDisabledVisually else { return }
        onTap?()
    }

    override func accessibilityActivate() -> Bool {
        guard !isDisabledVisually else { return false }
        onTap?()
        return true
    }
}
