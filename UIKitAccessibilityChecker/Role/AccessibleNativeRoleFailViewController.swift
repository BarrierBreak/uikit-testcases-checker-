import UIKit

/// Worst-case tier: reuses the same hand-drawn clones (SwitchClone,
/// SliderClone, CheckboxClone) defined in
/// AccessibleNativeRolePartialViewController.swift, but with NO
/// accessibility wiring at all. Nothing here is a real UISwitch/UISlider/
/// UIStepper/UISegmentedControl, and without a single accessibility
/// property set, VoiceOver either skips these views entirely or reads
/// them as generic, unlabeled shapes. Deliberately broken; reference only.
final class AccessibleNativeRoleFailViewController: UIViewController {

    private let switchClone = SwitchClone().srcLine()
    private let sliderClone = SliderClone().srcLine()
    private let stepperMinusButton = UIButton(type: .system).srcLine()
    private let stepperPlusButton = UIButton(type: .system).srcLine()
    private let stepperCountLabel = UILabel()
    private let segmentStack = UIStackView()
    private let checkboxClone = CheckboxClone().srcLine()

    private var quantity = 1 {
        didSet { stepperCountLabel.text = "\(quantity)" }
    }
    private var selectedColorIndex = 2
    private let colorOptions = ["Red", "Green", "Blue"]
    private var segmentButtons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        // No accessibilityLabel/Traits/Value set on switchClone or
        // sliderClone at all — plain UIView subclasses with no
        // accessibility opt-in are invisible to VoiceOver by default.

        stepperMinusButton.setTitle("−", for: .normal)
        stepperMinusButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.quantity = max(self.quantity - 1, 1)
        }, for: .touchUpInside)
        // No accessibilityLabel — VoiceOver reads the button's title
        // glyph "−" with no indication of what it decreases.

        stepperPlusButton.setTitle("+", for: .normal)
        stepperPlusButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.quantity = min(self.quantity + 1, 10)
        }, for: .touchUpInside)

        stepperCountLabel.text = "\(quantity)"

        segmentStack.axis = .horizontal
        segmentStack.distribution = .fillEqually
        for (index, option) in colorOptions.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.tag = index
            button.addAction(UIAction { [weak self] _ in
                self?.selectColor(index)
            }, for: .touchUpInside)
            // No accessibilityLabel/Traits — button titles alone happen to
            // read the color name, but nothing conveys selection state.
            button.srcLine()
            segmentButtons.append(button)
            segmentStack.addArrangedSubview(button)
        }
        highlightSelectedSegment()

        // checkboxClone gets no accessibility wiring — VoiceOver swipes
        // through its internal image and label as two separate,
        // unrelated, non-interactive pieces.

        let stack = UIStackView(arrangedSubviews: [
            switchClone,
            sliderClone,
            hstack([stepperMinusButton, stepperCountLabel, stepperPlusButton]),
            segmentStack,
            checkboxClone
        ])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        switchClone.heightAnchor.constraint(equalToConstant: 31).isActive = true
        sliderClone.heightAnchor.constraint(equalToConstant: 20).isActive = true
        checkboxClone.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }

    private func selectColor(_ index: Int) {
        selectedColorIndex = index
        highlightSelectedSegment()
    }

    private func highlightSelectedSegment() {
        for (index, button) in segmentButtons.enumerated() {
            button.backgroundColor = index == selectedColorIndex ? .systemGray5 : .clear
        }
    }

    private func hstack(_ views: [UIView]) -> UIView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }
}
