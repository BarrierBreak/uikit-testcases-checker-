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

    // Role / Native Role / State screens were previously reachable only through
    // UIKitA11yScanRunner's headless --a11y-scan sweep (it swaps window.rootViewController
    // for ~0.3s per screen and tears down) — there was no stable, real navigation path to
    // any of them, so nothing that needs the screen to actually stay on-screen (keyboard
    // focus navigation, VoiceOver inspection by hand) could reach them. Added here so they
    // behave the same way the Name/Extras screens already do.
    private let rolePassButton = UIButton(type: .system)
    private let rolePartialButton = UIButton(type: .system)
    private let roleFailButton = UIButton(type: .system)

    private let nativeRolePassButton = UIButton(type: .system)
    private let nativeRolePartialButton = UIButton(type: .system)
    private let nativeRoleFailButton = UIButton(type: .system)

    private let statePassButton = UIButton(type: .system)
    private let statePartialButton = UIButton(type: .system)
    private let stateFailButton = UIButton(type: .system)

    private let keyboardPassButton = UIButton(type: .system)
    private let keyboardPartialButton = UIButton(type: .system)
    private let keyboardFailButton = UIButton(type: .system)

    private let contrastPassButton = UIButton(type: .system)
    private let contrastPartialButton = UIButton(type: .system)
    private let contrastFailButton = UIButton(type: .system)

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
        rolePassButton.accessibilityLabel = "Accessibility-Role-Pass"
        rolePartialButton.accessibilityLabel = "Accessibility-Role-Partial"
        roleFailButton.accessibilityLabel = "Accessibility-Role-Fail"
        nativeRolePassButton.accessibilityLabel = "Accessibility-NativeRole-Pass"
        nativeRolePartialButton.accessibilityLabel = "Accessibility-NativeRole-Partial"
        nativeRoleFailButton.accessibilityLabel = "Accessibility-NativeRole-Fail"
        statePassButton.accessibilityLabel = "Accessibility-State-Pass"
        statePartialButton.accessibilityLabel = "Accessibility-State-Partial"
        stateFailButton.accessibilityLabel = "Accessibility-State-Fail"
        keyboardPassButton.accessibilityLabel = "Accessibility-Keyboard-Pass"
        keyboardPartialButton.accessibilityLabel = "Accessibility-Keyboard-Partial"
        keyboardFailButton.accessibilityLabel = "Accessibility-Keyboard-Fail"
        contrastPassButton.accessibilityLabel = "Accessibility-Contrast-Pass"
        contrastPartialButton.accessibilityLabel = "Accessibility-Contrast-Partial"
        contrastFailButton.accessibilityLabel = "Accessibility-Contrast-Fail"
        setupButtons()
    }

    private func setupButtons() {

        configureButton(passButton, title: "Accessibility-Pass", action: #selector(openPassScreen))
        configureButton(partialButton, title: "Accessibility-Partial", action: #selector(openPartialScreen))
        configureButton(failButton, title: "Accessibility-Fail", action: #selector(openFailScreen))

        configureButton(extrasPassButton, title: "Accessibility-Extras-Pass", action: #selector(openExtrasPassScreen))
        configureButton(extrasPartialButton, title: "Accessibility-Extras-Partial", action: #selector(openExtrasPartialScreen))
        configureButton(extrasFailButton, title: "Accessibility-Extras-Fail", action: #selector(openExtrasFailScreen))

        configureButton(rolePassButton, title: "Accessibility-Role-Pass", action: #selector(openRolePassScreen))
        configureButton(rolePartialButton, title: "Accessibility-Role-Partial", action: #selector(openRolePartialScreen))
        configureButton(roleFailButton, title: "Accessibility-Role-Fail", action: #selector(openRoleFailScreen))

        configureButton(nativeRolePassButton, title: "Accessibility-NativeRole-Pass", action: #selector(openNativeRolePassScreen))
        configureButton(nativeRolePartialButton, title: "Accessibility-NativeRole-Partial", action: #selector(openNativeRolePartialScreen))
        configureButton(nativeRoleFailButton, title: "Accessibility-NativeRole-Fail", action: #selector(openNativeRoleFailScreen))

        configureButton(statePassButton, title: "Accessibility-State-Pass", action: #selector(openStatePassScreen))
        configureButton(statePartialButton, title: "Accessibility-State-Partial", action: #selector(openStatePartialScreen))
        configureButton(stateFailButton, title: "Accessibility-State-Fail", action: #selector(openStateFailScreen))

        configureButton(keyboardPassButton, title: "Accessibility-Keyboard-Pass", action: #selector(openKeyboardPassScreen))
        configureButton(keyboardPartialButton, title: "Accessibility-Keyboard-Partial", action: #selector(openKeyboardPartialScreen))
        configureButton(keyboardFailButton, title: "Accessibility-Keyboard-Fail", action: #selector(openKeyboardFailScreen))

        configureButton(contrastPassButton, title: "Accessibility-Contrast-Pass", action: #selector(openContrastPassScreen))
        configureButton(contrastPartialButton, title: "Accessibility-Contrast-Partial", action: #selector(openContrastPartialScreen))
        configureButton(contrastFailButton, title: "Accessibility-Contrast-Fail", action: #selector(openContrastFailScreen))

        // 21 buttons no longer fit a fixed-height, centered stack — wrapped in a scroll
        // view, matching the pattern every example screen in this app already uses
        // (see AccessibleNamePassViewController.buildLayout()) rather than inventing a
        // second layout convention.
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stackView = UIStackView(arrangedSubviews: [
            passButton, partialButton, failButton,
            extrasPassButton, extrasPartialButton, extrasFailButton,
            rolePassButton, rolePartialButton, roleFailButton,
            nativeRolePassButton, nativeRolePartialButton, nativeRoleFailButton,
            statePassButton, statePartialButton, stateFailButton,
            keyboardPassButton, keyboardPartialButton, keyboardFailButton,
            contrastPassButton, contrastPartialButton, contrastFailButton
        ])

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -30),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -60),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(21 * 56 + 20 * 16))
        ])
    }

    private func configureButton(_ button: UIButton,
                                 title: String,
                                 action: Selector) {

        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true

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

    @objc private func openRolePassScreen() {
        navigationController?.pushViewController(AccessibleRolePassViewController(), animated: true)
    }

    @objc private func openRolePartialScreen() {
        navigationController?.pushViewController(AccessibleRolePartialViewController(), animated: true)
    }

    @objc private func openRoleFailScreen() {
        navigationController?.pushViewController(AccessibleRoleFailViewController(), animated: true)
    }

    @objc private func openNativeRolePassScreen() {
        navigationController?.pushViewController(AccessibleNativeRolePassViewController(), animated: true)
    }

    @objc private func openNativeRolePartialScreen() {
        navigationController?.pushViewController(AccessibleNativeRolePartialViewController(), animated: true)
    }

    @objc private func openNativeRoleFailScreen() {
        navigationController?.pushViewController(AccessibleNativeRoleFailViewController(), animated: true)
    }

    @objc private func openStatePassScreen() {
        navigationController?.pushViewController(AccessibleStatePassViewController(), animated: true)
    }

    @objc private func openStatePartialScreen() {
        navigationController?.pushViewController(AccessibleStatePartialViewController(), animated: true)
    }

    @objc private func openStateFailScreen() {
        navigationController?.pushViewController(AccessibleStateFailViewController(), animated: true)
    }

    @objc private func openKeyboardPassScreen() {
        navigationController?.pushViewController(AccessibleKeyboardPassViewController(), animated: true)
    }

    @objc private func openKeyboardPartialScreen() {
        navigationController?.pushViewController(AccessibleKeyboardPartialViewController(), animated: true)
    }

    @objc private func openKeyboardFailScreen() {
        navigationController?.pushViewController(AccessibleKeyboardFailViewController(), animated: true)
    }

    @objc private func openContrastPassScreen() {
        navigationController?.pushViewController(AccessibleColorContrastPassViewController(), animated: true)
    }

    @objc private func openContrastPartialScreen() {
        navigationController?.pushViewController(AccessibleColorContrastPartialViewController(), animated: true)
    }

    @objc private func openContrastFailScreen() {
        navigationController?.pushViewController(AccessibleColorContrastFailViewController(), animated: true)
    }
}
