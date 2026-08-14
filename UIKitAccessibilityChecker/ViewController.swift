//
//  ViewController.swift
//  UIKitAccessibilityChecker
//
//  Created by Meet Pokar on 31/07/26.
//

//import UIKit

//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }
//
//
//}
//


//
//  ViewController.swift
//  UIKitAccessibilityChecker
//
//  Created by Meet Pokar on 31/07/26.
//

import UIKit

class ViewController: UIViewController {

    private let passButton = UIButton(type: .system)
    private let partialButton = UIButton(type: .system)
    private let failButton = UIButton(type: .system)

    // The Extras screens stage the accessible-name defects the three screens above
    // cannot express. They are scanned by UIKitA11yScanRunner, so they need a way in
    // here too — otherwise they can only be inspected headlessly.
    private let extrasPassButton = UIButton(type: .system)
    private let extrasPartialButton = UIButton(type: .system)
    private let extrasFailButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Accessibility Checker"
        view.backgroundColor = .systemBackground
        passButton.accessibilityLabel = "Accessibility-Pass"
        partialButton.accessibilityLabel = "Accessibility-Partial"
        failButton.accessibilityLabel = "Accessibility-Fail"
        extrasPassButton.accessibilityLabel = "Accessibility-Extras-Pass"
        extrasPartialButton.accessibilityLabel = "Accessibility-Extras-Partial"
        extrasFailButton.accessibilityLabel = "Accessibility-Extras-Fail"
        setupButtons()
    }

    private func setupButtons() {

        configureButton(
            passButton,
            title: "Accessibility-Pass",
            action: #selector(openPassScreen)
        )

        configureButton(
            partialButton,
            title: "Accessibility-Partial",
            action: #selector(openPartialScreen)
        )

        configureButton(
            failButton,
            title: "Accessibility-Fail",
            action: #selector(openFailScreen)
        )

        configureButton(
            extrasPassButton,
            title: "Accessibility-Extras-Pass",
            action: #selector(openExtrasPassScreen)
        )

        configureButton(
            extrasPartialButton,
            title: "Accessibility-Extras-Partial",
            action: #selector(openExtrasPartialScreen)
        )

        configureButton(
            extrasFailButton,
            title: "Accessibility-Extras-Fail",
            action: #selector(openExtrasFailScreen)
        )

        let stackView = UIStackView(arrangedSubviews: [
            passButton,
            partialButton,
            failButton,
            extrasPassButton,
            extrasPartialButton,
            extrasFailButton
        ])

        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            stackView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }

    private func configureButton(_ button: UIButton,
                                 title: String,
                                 action: Selector) {

        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10

        button.addTarget(self, action: action, for: .touchUpInside)
    }

    @objc private func openPassScreen() {
        navigationController?.pushViewController(AccessibleNamePassViewController(), animated: true)
    }

    @objc private func openPartialScreen() {
        navigationController?.pushViewController(AccessibleNamePartialViewController(), animated: true)
    }

    @objc private func openFailScreen() {
        navigationController?.pushViewController(AccessibleNameFailViewController(), animated: true)
    }

    @objc private func openExtrasPassScreen() {
        navigationController?.pushViewController(AccessibleNameExtrasPassViewController(), animated: true)
    }

    @objc private func openExtrasPartialScreen() {
        navigationController?.pushViewController(AccessibleNameExtrasPartialViewController(), animated: true)
    }

    @objc private func openExtrasFailScreen() {
        navigationController?.pushViewController(AccessibleNameExtrasFailViewController(), animated: true)
    }
}
