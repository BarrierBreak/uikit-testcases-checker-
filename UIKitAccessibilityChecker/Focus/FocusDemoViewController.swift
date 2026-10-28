import UIKit

/// Shared layout for the three Focus screens. Each control draws its own focus ring, and draws it
/// only while it has keyboard focus: the ring is written in the control's `didUpdateFocus`.
///
/// What a control looks like while it has keyboard focus can't be observed from a running iPhone
/// screen, so the scan reads the ring where the app wrote it down — and only a ring tied to focus
/// counts. A plain static border is not a focus indicator.
class FocusDemoViewController: UIViewController {

    var screenTitle: String { "" }

    /// Adds the controls. Each is created on its own line, tagged with `.srcLine()`.
    func build() {}

    private var nextY: CGFloat = 24

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        build()
    }

    func place(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(hex: "#1A1A1A"), for: .normal)
        button.backgroundColor = UIColor(hex: "#FFFFFF")
        button.layer.cornerRadius = 8
        button.frame = CGRect(x: 24, y: nextY, width: 240, height: 48)
        view.addSubview(button)
        nextY += 72
    }
}
