import UIKit

/// HIDDEN FROM SCREEN READER — Partial tier.
///
/// Nothing here stops a screen-reader user operating anything. Four pieces of readable
/// content are kept out of the accessibility tree, and whether that is right depends on
/// something the scan cannot see: does a screen-reader user get this information some other
/// way? Each is reported as BB40057 "Check if content needs to be hidden from screen reader
/// users" — a Validate row for a person to decide.
///
/// Elements covered (7):
///   1. Order status label     — informative text, isAccessibilityElement = false   → Validate
///   2. Total label            — duplicates the button below it, hidden             → Validate
///   3. Low-stock image        — described image, isAccessibilityElement = false    → Validate
///   4. Footnote in container  — accessibilityElementsHidden on the container above → Validate
///   5. Pay button             — exposed, not reported
///   6. Heading label          — exposed, not reported
///   7. Decorative image       — no description, hidden: not reported
final class AccessibleHiddenPartialViewController: UIViewController {

    private let headingLabel = UILabel().srcLine()
    private let statusLabel = UILabel().srcLine()
    private let totalLabel = UILabel().srcLine()
    private let payButton = UIButton(type: .system).srcLine()
    private let stockImage = UIImageView(image: UIImage(systemName: "exclamationmark.triangle")).srcLine()
    private let hiddenContainer = UIView()
    private let footnoteLabel = UILabel().srcLine()
    private let flourishImage = UIImageView(image: UIImage(systemName: "sparkles")).srcLine()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hidden (Partial)"
        view.backgroundColor = .systemBackground
        buildLayout()
    }

    private func buildLayout() {
        headingLabel.text = "Checkout"
        headingLabel.frame = CGRect(x: 24, y: 24, width: 300, height: 30)
        view.addSubview(headingLabel)

        statusLabel.text = "Order #4821 confirmed"
        statusLabel.isAccessibilityElement = false
        statusLabel.frame = CGRect(x: 24, y: 70, width: 300, height: 30)
        view.addSubview(statusLabel)

        totalLabel.text = "Total: $42.00"
        totalLabel.isAccessibilityElement = false
        totalLabel.frame = CGRect(x: 24, y: 116, width: 300, height: 30)
        view.addSubview(totalLabel)

        payButton.setTitle("Pay $42.00", for: .normal)
        payButton.frame = CGRect(x: 24, y: 160, width: 140, height: 44)
        view.addSubview(payButton)

        stockImage.accessibilityLabel = "Warning: low stock"
        stockImage.isAccessibilityElement = false
        stockImage.frame = CGRect(x: 24, y: 224, width: 32, height: 32)
        view.addSubview(stockImage)

        hiddenContainer.accessibilityElementsHidden = true
        hiddenContainer.frame = CGRect(x: 24, y: 276, width: 300, height: 30)
        footnoteLabel.text = "Prices include tax"
        footnoteLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
        hiddenContainer.addSubview(footnoteLabel)
        view.addSubview(hiddenContainer)

        // Decoration with no description — hiding it is the right call and is not reported.
        flourishImage.isAccessibilityElement = false
        flourishImage.frame = CGRect(x: 280, y: 224, width: 32, height: 32)
        view.addSubview(flourishImage)
    }
}
