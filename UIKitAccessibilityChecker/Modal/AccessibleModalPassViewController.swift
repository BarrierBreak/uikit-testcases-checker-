import UIKit

/// MODAL — Pass tier.
///
/// Two dialogs, each with controls to act on and a Close button, so a keyboard user has
/// something to focus and a VoiceOver user has a way out. Nothing is reported.
///
/// Elements covered (2) — none is a defect:
///   1. Delete draft? — Save and Close buttons      → no row
///   2. Discard edits? — Save and Close buttons     → no row
final class AccessibleModalPassViewController: NewRuleScreen {

    override var screenTitle: String { "Modal (Pass)" }


    enum Contents { case controlsAndClose, labelsOnly, controlsNoClose }

    /// An in-page dialog that asks VoiceOver to stay inside it (accessibilityViewIsModal).
    private func dialog(_ heading: String, message: String, contents: Contents, tag: Int) {
        let dialog = UIView().srcLine()
        dialog.tag = tag
        dialog.backgroundColor = .secondarySystemBackground
        dialog.layer.cornerRadius = 12
        dialog.accessibilityViewIsModal = true

        let title = UILabel(frame: CGRect(x: 16, y: 12, width: 300, height: 24))
        title.text = heading
        title.font = .preferredFont(forTextStyle: .headline)
        let body = UILabel(frame: CGRect(x: 16, y: 40, width: 300, height: 22))
        body.text = message
        dialog.addSubview(title)
        dialog.addSubview(body)

        switch contents {
        case .controlsAndClose:
            let save = UIButton(type: .system)
            save.setTitle("Save", for: .normal)
            save.frame = CGRect(x: 16, y: 72, width: 100, height: 44)
            let close = UIButton(type: .system)
            close.setTitle("Close", for: .normal)
            close.frame = CGRect(x: 130, y: 72, width: 100, height: 44)
            dialog.addSubview(save)
            dialog.addSubview(close)
        case .controlsNoClose:
            let save = UIButton(type: .system)
            save.setTitle("Save", for: .normal)
            save.frame = CGRect(x: 16, y: 72, width: 100, height: 44)
            dialog.addSubview(save)
        case .labelsOnly:
            break
        }
        place(dialog, height: 128, gap: 24)
    }

    override func build() {
        dialog("Delete draft?", message: "This cannot be undone.", contents: .controlsAndClose, tag: 0)
        dialog("Discard edits?", message: "Your changes will be lost.", contents: .controlsAndClose, tag: 1)
    }
}
