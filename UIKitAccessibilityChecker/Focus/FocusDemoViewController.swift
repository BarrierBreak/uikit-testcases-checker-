import UIKit

/// Shared layout for the three Focus screens. Each item is a control that draws its own focus
/// ring as a border: its colour and its weight.
///
/// The ring is written here as the border the control carries. What a control looks like while
/// it has keyboard focus can't be observed from a running iPhone screen, so the scan reads the
/// ring where the app wrote it down.
class FocusDemoViewController: UIViewController {

    struct Ring {
        let title: String
        let color: String
        let width: CGFloat
        var shadow = false
    }

    var screenTitle: String { "" }
    var rings: [Ring] { [] }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        var y: CGFloat = 24
        for (index, ring) in rings.enumerated() {
            let button = UIButton(type: .custom).srcLine()
            // The controls are built in one loop, so they share a source line; the tag is what
            // keeps one control's finding from being merged into another's.
            button.tag = index
            button.setTitle(ring.title, for: .normal)
            button.setTitleColor(UIColor(hex: "#1A1A1A"), for: .normal)
            button.backgroundColor = UIColor(hex: "#FFFFFF")
            button.layer.cornerRadius = 8
            button.layer.borderColor = UIColor(hex: ring.color).cgColor
            button.layer.borderWidth = ring.width
            if ring.shadow {
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.4
                button.layer.shadowRadius = 4
                button.layer.shadowOffset = .zero
            }
            button.frame = CGRect(x: 24, y: y, width: 240, height: 48)
            view.addSubview(button)
            y += 72
        }
    }
}
