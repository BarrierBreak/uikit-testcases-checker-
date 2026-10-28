import UIKit

/// MODAL — Fail tier.
///
/// Two dialogs that hold VoiceOver focus but contain nothing to act on and no way to close.
/// Each draws BB40244 "Modal has no keyboard-focusable interactive controls" and BB40115
/// "Modal dialog inaccessible for screen reader users".
///
/// Elements covered (2) — both fail, twice each:
///   1. Delete draft?  — labels only                → BB40244 Fail, BB40115 Fail
///   2. Discard edits? — labels only                → BB40244 Fail, BB40115 Fail
final class AccessibleModalFailViewController: NewRuleScreen {

    override var screenTitle: String { "Modal (Fail)" }


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
        dialog("Delete draft?", message: "This cannot be undone.", contents: .labelsOnly, tag: 0)
        dialog("Discard edits?", message: "Your changes will be lost.", contents: .labelsOnly, tag: 1)
    }
}
