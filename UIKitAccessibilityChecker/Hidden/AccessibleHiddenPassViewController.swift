import UIKit

/// HIDDEN FROM SCREEN READER — Pass tier.
///
/// Everything a sighted user can read or operate is also in the accessibility tree, and the
/// only things kept out of it are things that carry nothing: a decorative image with no
/// description. Nothing here is reported — a scan that finds nothing hidden says nothing.
///
/// Elements covered (9) — none is a defect:
///   1. Title label                — plain UILabel, exposed
///   2. Primary button             — plain UIButton, exposed
///   3. Switch                     — UISwitch, exposed
///   4. Slider                     — UISlider, exposed
///   5. Stepper                    — UIStepper; its flag is false by design, its +/- are the
///                                   accessibility elements. Must not be mistaken for hidden
///   6. Segmented control          — same composite shape as the stepper
///   7. Decorative image           — no description, not an element: correctly absent
///   8. Combined card              — one element whose two labels are read as part of it, so
///                                   neither label is "hidden"
///   9. Receipt control            — an app's own UIControl, exposed with a name and button trait
final class AccessibleHiddenPassViewController: UIViewController {

    private let titleLabel = UILabel().srcLine()
    private let payButton = UIButton(type: .system).srcLine()
    private let notifySwitch = UISwitch().srcLine()
    private let volumeSlider = UISlider().srcLine()
    private let quantityStepper = UIStepper().srcLine()
    private let sortControl = UISegmentedControl(items: ["Newest", "Oldest"]).srcLine()
    private let flourishImage = UIImageView(image: UIImage(systemName: "sparkles")).srcLine()
    private let summaryCard = UIView().srcLine()
    private let cardTitle = UILabel()
    private let cardDetail = UILabel()
    private let tappableCard = ReceiptControl().srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hidden (Pass)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        titleLabel.text = "Account overview"
        titleLabel.frame = CGRect(x: 24, y: 24, width: 300, height: 30)
        view.addSubview(titleLabel)

        payButton.setTitle("Pay now", for: .normal)
        payButton.frame = CGRect(x: 24, y: 70, width: 120, height: 44)
        view.addSubview(payButton)

        notifySwitch.accessibilityLabel = "Notifications"
        notifySwitch.frame.origin = CGPoint(x: 200, y: 76)
        view.addSubview(notifySwitch)

        volumeSlider.accessibilityLabel = "Volume"
        volumeSlider.frame = CGRect(x: 24, y: 130, width: 300, height: 44)
        view.addSubview(volumeSlider)

        quantityStepper.accessibilityLabel = "Quantity"
        quantityStepper.frame.origin = CGPoint(x: 24, y: 190)
        view.addSubview(quantityStepper)

        sortControl.accessibilityLabel = "Sort order"
        sortControl.frame = CGRect(x: 24, y: 240, width: 220, height: 36)
        view.addSubview(sortControl)

        // Decoration: no description, not an element. Hiding it is correct.
        flourishImage.isAccessibilityElement = false
        flourishImage.frame = CGRect(x: 280, y: 190, width: 32, height: 32)
        view.addSubview(flourishImage)

        // One element standing for the whole card; the labels inside are read through it.
        summaryCard.isAccessibilityElement = true
        summaryCard.accessibilityLabel = "Balance, 42 dollars, due Friday"
        summaryCard.backgroundColor = .secondarySystemBackground
        summaryCard.frame = CGRect(x: 24, y: 300, width: 300, height: 70)
        cardTitle.text = "Balance"
        cardTitle.frame = CGRect(x: 12, y: 8, width: 200, height: 24)
        cardDetail.text = "$42.00 due Friday"
        cardDetail.frame = CGRect(x: 12, y: 36, width: 250, height: 24)
        summaryCard.addSubview(cardTitle)
        summaryCard.addSubview(cardDetail)
        view.addSubview(summaryCard)

        // An app's own control, exposed with a name and the button trait.
        tappableCard.isAccessibilityElement = true
        tappableCard.accessibilityLabel = "Open receipt"
        tappableCard.accessibilityTraits = .button
        tappableCard.backgroundColor = .tertiarySystemBackground
        tappableCard.frame = CGRect(x: 24, y: 390, width: 300, height: 56)
        tappableCard.addTarget(self, action: #selector(noop), for: .touchUpInside)
        view.addSubview(tappableCard)
    }

    @objc private func noop() {}
}

private final class ReceiptControl: UIControl {}
