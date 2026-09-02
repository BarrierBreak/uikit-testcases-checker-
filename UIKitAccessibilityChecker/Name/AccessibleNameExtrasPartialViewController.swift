import UIKit

/// Partial tier: no explicit accessibility wiring added beyond what UIKit
/// gives by default. Named buttons (UIButton with a title) and alert
/// titles still read fine — those are UIKit's default accessibility
/// labels. The gaps: the header UILabel has no `.header` trait, icon-only
/// buttons (info, close) have no accessibilityLabel, the decorative image
/// isn't hidden, the informative image isn't labeled, the progress view
/// has no label/value, saving never posts an announcement, and the tab
/// bar item has no label.
final class AccessibleNameExtrasPartialViewController: UIViewController {

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
        // No tabBarItem.accessibilityLabel — reads "gearshape, tab 1 of 2".

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

        // MARK: Section header — no .header trait
        sectionHeaderLabel.text = "Connectivity"
        sectionHeaderLabel.font = .preferredFont(forTextStyle: .headline)

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

        // MARK: Popover — icon-only, no label
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.addAction(UIAction { [weak self] _ in
            self?.presentInfoPopover()
        }, for: .touchUpInside)

        // MARK: Decorative vs. informative image — neither handled
        // decorativeImageView still an accessibility element — announces "sparkles"
        // warningImageView has no accessibilityLabel — announces its symbol name

        batteryLabel.text = "Battery is low"

        let imageRow = UIStackView(arrangedSubviews: [decorativeImageView, warningImageView, batteryLabel])
        imageRow.axis = .horizontal
        imageRow.spacing = 8
        imageRow.alignment = .center

        // MARK: Determinate progress — no label/value
        downloadProgressView.progress = 0.4

        // MARK: Announcement — button exists but never posts one
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.addAction(UIAction { _ in
            // No UIAccessibility.post call — silent to VoiceOver users.
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
        let detailVC = DetailSheetPartialViewController()
        let nav = UINavigationController(rootViewController: detailVC)
        // No accessibilityViewIsModal — swipe navigation can leak to the
        // presenting view underneath.
        present(nav, animated: true)
    }

    private func presentInfoPopover() {
        let contentVC = UIViewController()
        contentVC.view.backgroundColor = .secondarySystemBackground
        let label = UILabel()
        label.text = "This feature syncs your data across devices."
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
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

/// No accessibilityViewIsModal, no labeled close button.
final class DetailSheetPartialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        view.backgroundColor = .systemBackground

        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(close))
        // No closeButton.accessibilityLabel — reads "xmark, button".
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
