import UIKit

/// HIDDEN FROM SCREEN READER — Fail tier.
///
/// Every control here is on screen and works by touch, and none of them can be reached with
/// VoiceOver. Each is reported as BB40046 "Interactive controls hidden from screen reader
/// user". The ways of being hidden are deliberately different, because the rule has to
/// catch all of them:
///
///   own flag    — isAccessibilityElement = false on the control itself
///   container   — accessibilityElementsHidden = true on a view ABOVE the control
///   self        — accessibilityElementsHidden = true on the control itself
///
/// Elements covered (7) — every one fails:
///   1. Pay now         — UIButton, isAccessibilityElement = false
///   2. Notifications   — UISwitch, isAccessibilityElement = false
///   3. Delete account  — UIButton inside a container with accessibilityElementsHidden
///   4. Volume          — UISlider, accessibilityElementsHidden on itself
///   5. Quantity        — UIStepper, accessibilityElementsHidden on itself (a composite,
///                        so only this flag can hide it)
///   6. Open receipt    — an app's own UIControl, isAccessibilityElement = false
///   7. Search field    — UITextField, isAccessibilityElement = false
final class AccessibleHiddenFailViewController: UIViewController {

    private let payButton = UIButton(type: .system).srcLine()
    private let notifySwitch = UISwitch().srcLine()
    private let hiddenContainer = UIView()
    private let deleteButton = UIButton(type: .system).srcLine()
    private let volumeSlider = UISlider().srcLine()
    private let quantityStepper = UIStepper().srcLine()
    private let receiptCard = ReceiptControl().srcLine()
    private let searchField = UITextField().srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hidden (Fail)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        payButton.setTitle("Pay now", for: .normal)
        payButton.isAccessibilityElement = false
        payButton.frame = CGRect(x: 24, y: 24, width: 120, height: 44)
        view.addSubview(payButton)

        notifySwitch.accessibilityLabel = "Notifications"
        notifySwitch.isAccessibilityElement = false
        notifySwitch.frame.origin = CGPoint(x: 200, y: 30)
        view.addSubview(notifySwitch)

        hiddenContainer.accessibilityElementsHidden = true
        hiddenContainer.frame = CGRect(x: 24, y: 90, width: 300, height: 56)
        deleteButton.setTitle("Delete account", for: .normal)
        deleteButton.frame = CGRect(x: 0, y: 6, width: 160, height: 44)
        hiddenContainer.addSubview(deleteButton)
        view.addSubview(hiddenContainer)

        volumeSlider.accessibilityLabel = "Volume"
        volumeSlider.accessibilityElementsHidden = true
        volumeSlider.frame = CGRect(x: 24, y: 170, width: 300, height: 44)
        view.addSubview(volumeSlider)

        quantityStepper.accessibilityLabel = "Quantity"
        quantityStepper.accessibilityElementsHidden = true
        quantityStepper.frame.origin = CGPoint(x: 24, y: 240)
        view.addSubview(quantityStepper)

        receiptCard.isAccessibilityElement = false
        receiptCard.accessibilityLabel = "Open receipt"
        receiptCard.backgroundColor = .secondarySystemBackground
        receiptCard.frame = CGRect(x: 24, y: 290, width: 300, height: 56)
        receiptCard.addTarget(self, action: #selector(noop), for: .touchUpInside)
        view.addSubview(receiptCard)

        searchField.placeholder = "Search"
        searchField.accessibilityLabel = "Search field"
        searchField.borderStyle = .roundedRect
        searchField.isAccessibilityElement = false
        searchField.frame = CGRect(x: 24, y: 370, width: 300, height: 40)
        view.addSubview(searchField)
    }

    @objc private func noop() {}
}

/// An app's own control. A UIControl subclass is NOT an accessibility element by default —
/// only UIButton, UISwitch and the other system controls opt in — so this one stays out of
/// the tree until something says otherwise.
private final class ReceiptControl: UIControl {}
