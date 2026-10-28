import UIKit

/// NON-TEXT CONTRAST — Partial tier.
///
/// Three parts are dark and two are pale.
///
/// Elements covered (5):
///   1. Email field        — dark border                       → no row
///   2. Activity indicator — pale                              → BB40064 Fail
///   3. Progress bar       — dark fill                         → no row
///   4. Notifications      — switch with a pale on-colour      → BB40060 Fail
///   5. Volume             — slider with a dark track          → no row
final class AccessibleNonTextContrastPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Non Text Contrast (Partial)" }


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

    override func build() { lay([true, false, true, false, true]) }
}
