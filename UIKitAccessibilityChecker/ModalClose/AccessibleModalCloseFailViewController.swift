import UIKit

/// MODAL CLOSE — Fail tier.
///
/// Elements covered (1) — a defect:
///   1. Share draft? — a Save button, no Close, no escape   → BB40115 Fail (family modal); nothing in family modalClose
final class AccessibleModalCloseFailViewController: NewRuleScreen {

    override var screenTitle: String { "Modal Close (Fail)" }

    /// An in-page dialog that asks VoiceOver to stay inside it (accessibilityViewIsModal).
    /// It always has a Save button; `closable` adds the Close button that lets a person out.
    private func dialog(_ heading: String, message: String, closable: Bool, tag: Int) {
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

        let save = UIButton(type: .system)
        save.setTitle("Save", for: .normal)
        save.frame = CGRect(x: 16, y: 72, width: 100, height: 44)
        dialog.addSubview(save)
        if closable {
            let close = UIButton(type: .system)
            close.setTitle("Close", for: .normal)
            close.frame = CGRect(x: 130, y: 72, width: 100, height: 44)
            dialog.addSubview(close)
        }
        place(dialog, height: 128, gap: 24)
    }

    override func build() {
        dialog("Share draft?", message: "Anyone with the link can read it.", closable: false, tag: 0)
    }
}
