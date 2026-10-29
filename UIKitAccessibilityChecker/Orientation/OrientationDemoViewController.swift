import UIKit

/// Shared layout for the three Orientation screens: a heading and a paragraph. Each subclass
/// says which orientations the screen allows.
class OrientationDemoViewController: UIViewController {

    var screenTitle: String { "" }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = .systemBackground

        let heading = UILabel().srcLine()
        heading.text = "Delivery details"
        heading.font = .preferredFont(forTextStyle: .headline)
        heading.accessibilityTraits = .header

        let body = UILabel().srcLine()
        body.text = "Your order will arrive between 9am and 5pm. You can change the address until it ships."
        body.font = .preferredFont(forTextStyle: .body)
        body.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [heading, body])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
        ])
    }
}
