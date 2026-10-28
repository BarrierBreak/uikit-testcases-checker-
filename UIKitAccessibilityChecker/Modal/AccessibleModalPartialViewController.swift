import UIKit

/// MODAL — Partial tier.
///
/// One dialog is complete, one has nothing in it, and one has a button but no way out.
///
/// Elements covered (3):
///   1. Delete draft?  — Save and Close buttons     → no row
///   2. Discard edits? — labels only                → BB40244 Fail, BB40115 Fail
///   3. Share draft?   — a Save button, no Close    → BB40115 Fail
final class AccessibleModalPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Modal (Partial)" }


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
        dialog("Discard edits?", message: "Your changes will be lost.", contents: .labelsOnly, tag: 1)
        dialog("Share draft?", message: "Anyone with the link can read it.", contents: .controlsNoClose, tag: 2)
    }
}
