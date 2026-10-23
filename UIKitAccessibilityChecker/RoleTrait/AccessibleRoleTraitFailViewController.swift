import UIKit

/// ROLE TRAIT — Fail tier.
///
/// Every native control has had its accessibility traits replaced, so what VoiceOver announces
/// no longer matches what the control is. Each reports BB40274 "Accessibility role trait does
/// not match element type".
///
/// Elements covered (5) — every one fails:
///   1. Save changes   — UIButton set to .staticText, no button role  → BB40274 Fail
///   2. Volume         — UISlider set to .staticText, not adjustable  → BB40274 Fail
///   3. Notifications  — UISwitch set to .staticText, no button role  → BB40274 Fail
///   4. Email          — UITextField set to .button                   → BB40274 Fail
///   5. Upload         — UIProgressView set to .button                → BB40274 Fail
final class AccessibleRoleTraitFailViewController: NewRuleScreen {

    override var screenTitle: String { "Role Trait (Fail)" }

    override func build() {
        let button = UIButton(type: .system).srcLine()
        button.setTitle("Save changes", for: .normal)
        button.accessibilityTraits = .staticText
        place(button)

        let slider = UISlider().srcLine()
        slider.accessibilityLabel = "Volume"
        slider.accessibilityTraits = .staticText
        place(slider)

        let toggle = UISwitch().srcLine()
        toggle.accessibilityLabel = "Notifications"
        toggle.accessibilityTraits = .staticText
        place(toggle, height: 31, width: 51)

        let field = UITextField().srcLine()
        field.borderStyle = .roundedRect
        field.placeholder = "Email"
        field.accessibilityLabel = "Email"
        field.accessibilityTraits = .button
        place(field)

        let progress = UIProgressView(progressViewStyle: .default).srcLine()
        progress.progress = 0.4
        progress.accessibilityLabel = "Upload"
        progress.isAccessibilityElement = true
        progress.accessibilityTraits = .button
        place(progress, height: 4)
    }
}
