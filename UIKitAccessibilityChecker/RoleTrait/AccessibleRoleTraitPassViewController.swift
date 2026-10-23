import UIKit

/// ROLE TRAIT — Pass tier.
///
/// Five native controls, each left alone, so each carries the role UIKit gives it: a button is
/// a button, a slider is adjustable, a switch toggles, a text field is not a button, a progress
/// bar is not interactive. Each reports BB40275 "Accessibility role trait correctly matches
/// element type".
///
/// Elements covered (5) — none is a defect:
///   1. Save changes   — UIButton, stock traits                  → BB40275 Pass
///   2. Volume         — UISlider, stock traits                  → BB40275 Pass
///   3. Notifications  — UISwitch, stock traits                  → BB40275 Pass
///   4. Email          — UITextField, no button trait            → BB40275 Pass
///   5. Upload         — UIProgressView, no interactive trait    → BB40275 Pass
final class AccessibleRoleTraitPassViewController: NewRuleScreen {

    override var screenTitle: String { "Role Trait (Pass)" }

    override func build() {
        let button = UIButton(type: .system).srcLine()
        button.setTitle("Save changes", for: .normal)
        place(button)

        let slider = UISlider().srcLine()
        slider.accessibilityLabel = "Volume"
        place(slider)

        let toggle = UISwitch().srcLine()
        toggle.accessibilityLabel = "Notifications"
        place(toggle, height: 31, width: 51)

        let field = UITextField().srcLine()
        field.borderStyle = .roundedRect
        field.placeholder = "Email"
        field.accessibilityLabel = "Email"
        place(field)

        let progress = UIProgressView(progressViewStyle: .default).srcLine()
        progress.progress = 0.4
        progress.accessibilityLabel = "Upload"
        place(progress, height: 4)
    }
}
