import UIKit

/// NON-TEXT CONTRAST — Fail tier.
///
/// The same five parts drawn in a pale grey, about 1.6:1 on white, so a person with low vision
/// cannot see where a field ends, that something is loading, or what a control's state is.
///
/// Elements covered (5) — every one fails:
///   1. Email field        — pale border                       → BB40062 Fail
///   2. Activity indicator — pale                              → BB40064 Fail
///   3. Progress bar       — pale fill                         → BB40064 Fail
///   4. Notifications      — switch with a pale on-colour      → BB40060 Fail
///   5. Volume             — slider with a pale track          → BB40060 Fail
final class AccessibleNonTextContrastFailViewController: NewRuleScreen {

    override var screenTitle: String { "Non Text Contrast (Fail)" }


    private let dark = UIColor(red: 0x1F/255, green: 0x2A/255, blue: 0x44/255, alpha: 1)   // about 14:1 on white
    private let light = UIColor(red: 0xC8/255, green: 0xC8/255, blue: 0xCC/255, alpha: 1)  // about 1.6:1 on white

    private func field(strong: Bool, tag: Int) -> UITextField {
        let field = UITextField().srcLine()
        field.tag = tag
        field.placeholder = "Email"
        field.accessibilityLabel = "Email"
        field.borderStyle = .none
        field.layer.borderWidth = 1.5
        field.layer.cornerRadius = 8
        field.layer.borderColor = (strong ? dark : light).cgColor
        return field
    }

    private func spinner(strong: Bool, tag: Int) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .medium).srcLine()
        spinner.tag = tag
        spinner.color = strong ? dark : light
        spinner.startAnimating()
        return spinner
    }

    private func progress(strong: Bool, tag: Int) -> UIProgressView {
        let bar = UIProgressView(progressViewStyle: .default).srcLine()
        bar.tag = tag
        bar.progress = 0.6
        bar.progressTintColor = strong ? dark : light
        bar.trackTintColor = .clear
        return bar
    }

    private func toggle(strong: Bool, tag: Int) -> UISwitch {
        let toggle = UISwitch().srcLine()
        toggle.tag = tag
        toggle.isOn = true
        toggle.onTintColor = strong ? dark : light
        toggle.accessibilityLabel = "Notifications"
        return toggle
    }

    private func slider(strong: Bool, tag: Int) -> UISlider {
        let slider = UISlider().srcLine()
        slider.tag = tag
        slider.value = 0.5
        slider.minimumTrackTintColor = strong ? dark : light
        slider.accessibilityLabel = "Volume"
        return slider
    }

    private func lay(_ strong: [Bool]) {
        view.backgroundColor = .white
        place(field(strong: strong[0], tag: 0))
        place(spinner(strong: strong[1], tag: 1), height: 30, width: 30)
        place(progress(strong: strong[2], tag: 2), height: 8)
        place(toggle(strong: strong[3], tag: 3), height: 31, width: 51)
        place(slider(strong: strong[4], tag: 4))
    }

    override func build() { lay([false, false, false, false, false]) }
}
