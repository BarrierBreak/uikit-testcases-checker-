import UIKit

/// UIKit equivalent of AccessibleNameExtrasPass: alert dialog, modal
/// presentation, popover, decorative vs. informative images, a determinate
/// UIProgressView, a live announcement, and an icon-only UITabBarItem.
final class AccessibleNameExtrasPassViewController: UIViewController {

    private let sectionHeaderLabel = UILabel().srcLine()
    private let showAlertButton = UIButton(type: .system).srcLine()
    private let showSheetButton = UIButton(type: .system).srcLine()
    private let infoButton = UIButton(type: .system).srcLine()
    private let decorativeImageView = UIImageView(image: UIImage(systemName: "sparkles"))
    private let warningImageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
    private let batteryLabel = UILabel().srcLine()
    private let downloadProgressView = UIProgressView(progressViewStyle: .default).srcLine()
    private let saveButton = UIButton(type: .system).srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Extras"
        view.backgroundColor = .systemBackground
        tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gearshape"), tag: 0)
        // Icon-only tab bar item — without an explicit label, VoiceOver
        // reads "gearshape, tab 1 of 2" instead of something meaningful.
        tabBarItem.accessibilityLabel = "Settings"

        buildLayout()
    }

    private func buildLayout() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // MARK: Section header
        sectionHeaderLabel.text = "Connectivity"
        sectionHeaderLabel.font = .preferredFont(forTextStyle: .headline)
        sectionHeaderLabel.accessibilityTraits = .header

        // MARK: Alert
        showAlertButton.setTitle("Show Alert", for: .normal)
        showAlertButton.addAction(UIAction { [weak self] _ in
            self?.presentAirplaneModeAlert()
        }, for: .touchUpInside)

        // MARK: Modal sheet
        showSheetButton.setTitle("Show Sheet", for: .normal)
        showSheetButton.addAction(UIAction { [weak self] _ in
            self?.presentDetailSheet()
        }, for: .touchUpInside)

        // MARK: Popover
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.accessibilityLabel = "More information"
        infoButton.addAction(UIAction { [weak self] _ in
            self?.presentInfoPopover()
        }, for: .touchUpInside)

        // MARK: Decorative vs. informative image
        decorativeImageView.isAccessibilityElement = false // skipped by VoiceOver entirely

        warningImageView.tintColor = .systemOrange
        warningImageView.isAccessibilityElement = true
        warningImageView.accessibilityLabel = "Warning"

        batteryLabel.text = "Battery is low"

        let imageRow = UIStackView(arrangedSubviews: [decorativeImageView, warningImageView, batteryLabel])
        imageRow.axis = .horizontal
        imageRow.spacing = 8
        imageRow.alignment = .center

        // MARK: Determinate progress
        downloadProgressView.progress = 0.4
        downloadProgressView.accessibilityLabel = "Download progress"
        downloadProgressView.accessibilityValue = "40 percent"

        // MARK: Live announcement (toast-style feedback)
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.addAction(UIAction { _ in
            // Nothing visually moves VoiceOver focus for a toast/banner,
            // so without this call the announcement is silent.
            UIAccessibility.post(notification: .announcement, argument: "Changes saved")
        }, for: .touchUpInside)

        [
            sectionHeaderLabel,
            showAlertButton,
            showSheetButton,
            infoButton,
            imageRow,
            downloadProgressView,
            saveButton
        ].forEach { stack.addArrangedSubview($0) }
    }

    private func presentAirplaneModeAlert() {
        let alert = UIAlertController(
            title: "Turn on Airplane Mode?",
            message: "This will disable Wi-Fi and Cellular Data.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Turn On", style: .default))
        present(alert, animated: true)
    }

    private func presentDetailSheet() {
        let detailVC = DetailSheetPassViewController()
        let nav = UINavigationController(rootViewController: detailVC)
        // Marks the presented view as modal so VoiceOver traps swipe
        // navigation inside it instead of leaking to the view underneath.
        nav.view.accessibilityViewIsModal = true
        present(nav, animated: true)
    }

    private func presentInfoPopover() {
        let contentVC = UIViewController()
        contentVC.view.backgroundColor = .secondarySystemBackground
        let label = UILabel()
        label.text = "This feature syncs your data across devices."
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityLabel = "Sync explanation: this feature syncs your data across devices"
        contentVC.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentVC.view.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: contentVC.view.bottomAnchor, constant: -16)
        ])
        contentVC.preferredContentSize = CGSize(width: 260, height: 100)
        contentVC.modalPresentationStyle = .popover
        if let popover = contentVC.popoverPresentationController {
            popover.sourceView = infoButton
            popover.sourceRect = infoButton.bounds
        }
        present(contentVC, animated: true)
    }
}

/// Presented modally with a labeled close button.
final class DetailSheetPassViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        view.backgroundColor = .systemBackground
        view.accessibilityViewIsModal = true

        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(close))
        closeButton.accessibilityLabel = "Close"
        navigationItem.leftBarButtonItem = closeButton

        let label = UILabel()
        label.text = "Modal sheet content goes here."
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}
