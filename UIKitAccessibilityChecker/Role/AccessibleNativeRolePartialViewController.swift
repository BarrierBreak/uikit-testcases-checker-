import UIKit

/// Partial tier: every native control is replaced with a hand-drawn visual
/// clone. Each gets SOME accessibility wiring (a label, a button trait),
/// but the piece that required manually re-deriving what the native
/// control gave for free — a live value, a selected state, an adjustable
/// action — is missing or stale.
final class AccessibleNativeRolePartialViewController: UIViewController {

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
        title = "Native Controls (Partial)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        // MARK: Custom switch — value never syncs
        switchClone.accessibilityLabel = "Enable Notifications"
        switchClone.accessibilityTraits = .button
        // Bug: hardcoded instead of reading switchClone.isOn — always
        // announces "Off" regardless of visual state.
        switchClone.accessibilityValue = "Off"

        // MARK: Custom slider — not adjustable
        sliderClone.accessibilityLabel = "Volume"
        sliderClone.onValueChanged = { [weak self] value in
            self?.sliderClone.accessibilityValue = "\(Int(value * 100)) percent"
        }
        sliderClone.accessibilityValue = "50 percent"
        // Bug: no accessibilityIncrement/Decrement override — VoiceOver
        // reports the value but swiping up/down does nothing.

        // MARK: Custom stepper — buttons work, count is silent
        stepperMinusButton.setTitle("−", for: .normal)
        stepperMinusButton.accessibilityLabel = "Decrease quantity"
        stepperMinusButton.accessibilityTraits = .button
        stepperMinusButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.quantity = max(self.quantity - 1, 1)
        }, for: .touchUpInside)

        stepperPlusButton.setTitle("+", for: .normal)
        stepperPlusButton.accessibilityLabel = "Increase quantity"
        stepperPlusButton.accessibilityTraits = .button
        stepperPlusButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.quantity = min(self.quantity + 1, 10)
        }, for: .touchUpInside)

        stepperCountLabel.text = "\(quantity)"
        // Bug: stepperCountLabel is a plain UILabel with no
        // accessibilityLabel tying it to the buttons — VoiceOver users
        // must manually navigate to a third, disconnected element to
        // hear the current count.

        // MARK: Custom segmented control — selection is invisible
        segmentStack.axis = .horizontal
        segmentStack.distribution = .fillEqually
        for (index, option) in colorOptions.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.tag = index
            button.accessibilityLabel = option
            // Bug: every segment gets .button, but none is ever marked
            // .selected — VoiceOver can't tell which color is chosen.
            button.accessibilityTraits = .button
            button.addAction(UIAction { [weak self] _ in
                self?.selectColor(index)
            }, for: .touchUpInside)
            button.srcLine()
            segmentButtons.append(button)
            segmentStack.addArrangedSubview(button)
        }
        highlightSelectedSegment()

        // MARK: Custom checkbox — button but no state
        checkboxClone.accessibilityLabel = "I agree to the Terms of Service"
        checkboxClone.accessibilityTraits = .button
        // Bug: no accessibilityValue at all — VoiceOver knows this is
        // tappable but never announces agreed/not agreed.

        let stack = UIStackView(arrangedSubviews: [
            row(title: "Toggle", control: switchClone),
            row(title: "Slider", control: sliderClone),
            row(title: "Stepper", control: hstack([stepperMinusButton, stepperCountLabel, stepperPlusButton])),
            row(title: "Segmented Picker", control: segmentStack),
            row(title: "Checkbox-style Toggle", control: checkboxClone)
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

    private func row(title: String, control: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        let container = UIStackView(arrangedSubviews: [label, control])
        container.axis = .vertical
        container.spacing = 6
        return container
    }

    private func hstack(_ views: [UIView]) -> UIView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }
}

/// Hand-drawn switch: capsule track + circle thumb, toggled by a tap.
final class SwitchClone: UIView {
    private(set) var isOn = false
    private let thumb = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray4
        layer.cornerRadius = 15.5
        thumb.backgroundColor = .white
        thumb.layer.cornerRadius = 13.5
        addSubview(thumb)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggle)))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let side: CGFloat = 27
        let x: CGFloat = isOn ? bounds.width - side - 2 : 2
        thumb.frame = CGRect(x: x, y: 2, width: side, height: side)
    }

    @objc private func toggle() {
        isOn.toggle()
        backgroundColor = isOn ? .systemGreen : .systemGray4
        setNeedsLayout()
    }
}

/// Hand-drawn slider: capsule track + draggable thumb.
final class SliderClone: UIView {
    private(set) var value: Double = 0.5
    var onValueChanged: ((Double) -> Void)?
    private let track = UIView()
    private let thumb = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        track.backgroundColor = .systemGray4
        thumb.backgroundColor = .white
        thumb.layer.cornerRadius = 10
        thumb.layer.shadowOpacity = 0.2
        addSubview(track)
        addSubview(thumb)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        track.frame = CGRect(x: 0, y: bounds.midY - 2, width: bounds.width, height: 4)
        track.layer.cornerRadius = 2
        let x = bounds.width * value - 10
        thumb.frame = CGRect(x: x, y: bounds.midY - 10, width: 20, height: 20)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        value = min(max(location.x / bounds.width, 0), 1)
        onValueChanged?(value)
        setNeedsLayout()
    }
}

/// Hand-drawn checkbox: square/checkmark image + label, toggled by a tap.
final class CheckboxClone: UIView {
    private(set) var isChecked = false
    private let imageView = UIImageView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.image = UIImage(systemName: "square")
        label.text = "I agree to the Terms of Service"
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggle)))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isChecked.toggle()
        imageView.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
    }
}
