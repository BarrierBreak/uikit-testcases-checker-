import UIKit

/// Worst-case tier: every gap from Partial remains, plus the alert has no
/// title/message, the sheet has no navigation title, the popover content
/// is empty, and every trigger is an unlabeled icon-only button.
/// Deliberately broken; reference only.
final class AccessibleNameExtrasFailViewController: UIViewController {

    private let sectionHeaderLabel = UILabel().srcLine()
    private let showAlertButton = UIButton(type: .system).srcLine()
    private let showSheetButton = UIButton(type: .system).srcLine()
    private let infoButton = UIButton(type: .system).srcLine()
    private let decorativeImageView = UIImageView(image: UIImage(systemName: "sparkles"))
    private let warningImageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
    private let downloadProgressView = UIProgressView(progressViewStyle: .default).srcLine()
    private let saveButton = UIButton(type: .system).srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gearshape"), tag: 0)
        // No title, no tabBarItem.accessibilityLabel.

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

        // Section header — no text, no trait, nothing.
        sectionHeaderLabel.font = .preferredFont(forTextStyle: .headline)

        // Alert trigger — icon-only, no label.
        showAlertButton.setImage(UIImage(systemName: "airplane"), for: .normal)
        showAlertButton.addAction(UIAction { [weak self] _ in
            self?.presentAirplaneModeAlert()
        }, for: .touchUpInside)

        // Sheet trigger — icon-only, no label.
        showSheetButton.setImage(UIImage(systemName: "square.on.square"), for: .normal)
        showSheetButton.addAction(UIAction { [weak self] _ in
            self?.presentDetailSheet()
        }, for: .touchUpInside)

        // Popover trigger — icon-only, no label.
        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.addAction(UIAction { [weak self] _ in
            self?.presentInfoPopover()
        }, for: .touchUpInside)

        // Images — decorative not hidden, informative not labeled, no adjacent text.
        let imageRow = UIStackView(arrangedSubviews: [decorativeImageView, warningImageView])
        imageRow.axis = .horizontal
        imageRow.spacing = 8
        imageRow.alignment = .center

        // Progress — no label/value.
        downloadProgressView.progress = 0.4

        // Save — icon-only, no label, no announcement.
        saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        saveButton.addAction(UIAction { _ in
            // no-op, no announcement
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func presentDetailSheet() {
        let detailVC = DetailSheetFailViewController()
        present(detailVC, animated: true)
    }

    private func presentInfoPopover() {
        let contentVC = UIViewController()
        contentVC.view.backgroundColor = .secondarySystemBackground
        contentVC.preferredContentSize = CGSize(width: 200, height: 80)
        contentVC.modalPresentationStyle = .popover
        if let popover = contentVC.popoverPresentationController {
            popover.sourceView = infoButton
            popover.sourceRect = infoButton.bounds
        }
        present(contentVC, animated: true)
    }
}

/// No accessibilityViewIsModal, no navigation title, no labeled close control.
final class DetailSheetFailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = "Modal sheet content goes here."
        label.translatesAutoresizingMaskIntoConstraints = false

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
