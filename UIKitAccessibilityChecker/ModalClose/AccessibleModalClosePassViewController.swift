import UIKit

/// MODAL CLOSE — Pass tier.
///
/// Elements covered (1) — none is a defect:
///   1. Delete draft? — Save and Close buttons   → BB40114 Pass (family modalClose); nothing in family modal
final class AccessibleModalClosePassViewController: NewRuleScreen {

    override var screenTitle: String { "Modal Close (Pass)" }

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
        dialog("Delete draft?", message: "This cannot be undone.", closable: true, tag: 0)
    }
}
